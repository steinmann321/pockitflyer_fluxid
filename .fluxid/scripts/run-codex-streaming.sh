#!/bin/bash

# run-codex-streaming.sh
# Runs Codex CLI non-interactively, captures JSONL event stream,
# and renders a clean, human-friendly status with final output.
# Usage: ./run-codex-streaming.sh "your prompt here"

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PROMPT="$1"

if [ -z "$PROMPT" ]; then
    echo "ERROR: No prompt provided"
    echo "Usage: $0 \"your prompt here\""
    exit 1
fi

# Resolve repo root and Codex home
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
export CODEX_HOME="$REPO_ROOT/.codex"

# Temp file for capturing the last assistant message
TMP_OUT_FILE=$(mktemp /tmp/codex_last_msg.XXXXXX)
cleanup() { rm -f "$TMP_OUT_FILE" 2>/dev/null || true; }
trap cleanup EXIT

# If jq is missing, fall back to raw Codex output so user sees something
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ jq not found; showing raw Codex output${NC}"
    codex exec "$PROMPT" --sandbox danger-full-access -C "$REPO_ROOT" -o "$TMP_OUT_FILE"
    # Show last message if present
    if [ -s "$TMP_OUT_FILE" ]; then
        echo -e "${GREEN}╭─ RESPONSE${NC}"
        while IFS= read -r line_text; do
            echo -e "${GREEN}│${NC} ${line_text}"
        done < "$TMP_OUT_FILE"
        echo -e "${GREEN}╰─${NC}"
    fi
    exit $?
fi

# Start Codex and parse JSONL events (Codex CLI schema)
codex exec "$PROMPT" --json --sandbox danger-full-access -C "$REPO_ROOT" -o "$TMP_OUT_FILE" 2>&1 | while IFS= read -r line; do
    # Try to parse the event type; ignore non-JSON
    event_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)

    case "$event_type" in
        "thread.started")
            echo -e "${BLUE}╭─ CODEX SESSION${NC}"
            echo -e "${BLUE}╰─${NC}"
            ;;

        "turn.started")
            :
            ;;

        "item.started")
            item_type=$(echo "$line" | jq -r '.item.type // empty' 2>/dev/null)
            if [ "$item_type" = "command_execution" ]; then
                cmd=$(echo "$line" | jq -r '.item.command // empty' 2>/dev/null)
                if [ -n "$cmd" ] && [ "$cmd" != "null" ]; then
                    echo -e "${YELLOW}╭─ RUN${NC}"
                    echo -e "${YELLOW}│${NC} ${MAGENTA}$cmd${NC}"
                    echo -e "${YELLOW}╰─${NC}"
                fi
            fi
            ;;

        "item.completed")
            item_type=$(echo "$line" | jq -r '.item.type // empty' 2>/dev/null)
            case "$item_type" in
                "reasoning")
                    txt=$(echo "$line" | jq -r '.item.text // empty' 2>/dev/null)
                    if [ -n "$txt" ] && [ "$txt" != "null" ]; then
                        echo -e "${CYAN}╭─ REASONING${NC}"
                        while IFS= read -r t; do
                            echo -e "${CYAN}│${NC} $t"
                        done <<< "$txt"
                        echo -e "${CYAN}╰─${NC}"
                    fi
                    ;;
                "agent_message")
                    txt=$(echo "$line" | jq -r '.item.text // empty' 2>/dev/null)
                    if [ -n "$txt" ] && [ "$txt" != "null" ]; then
                        echo -e "${GREEN}╭─ RESPONSE${NC}"
                        while IFS= read -r t; do
                            echo -e "${GREEN}│${NC} $t"
                        done <<< "$txt"
                        echo -e "${GREEN}╰─${NC}"
                    fi
                    ;;
                "command_execution")
                    out=$(echo "$line" | jq -r '.item.aggregated_output // empty' 2>/dev/null)
                    exit_code=$(echo "$line" | jq -r '.item.exit_code // empty' 2>/dev/null)
                    if [ -n "$out" ] && [ "$out" != "null" ]; then
                        echo -e "${GREEN}╭─ COMMAND OUTPUT${NC}"
                        while IFS= read -r t; do
                            echo -e "${GREEN}│${NC} $t"
                        done <<< "$out"
                        echo -e "${GREEN}╰─${NC}"
                    fi
                    if [ -n "$exit_code" ] && [ "$exit_code" != "null" ]; then
                        if [ "$exit_code" -eq 0 ]; then
                            echo -e "${CYAN}✓${NC} Command exited 0"
                        else
                            echo -e "${RED}✗${NC} Command exited $exit_code"
                        fi
                    fi
                    ;;
            esac
            ;;

        "error")
            err_msg=$(echo "$line" | jq -r '.message // .error.message // "Unknown error"' 2>/dev/null)
            echo -e "${RED}╭─ ERROR${NC}"
            echo -e "${RED}│${NC} ${err_msg}"
            echo -e "${RED}╰─${NC}"
            ;;

        "turn.failed")
            err_msg=$(echo "$line" | jq -r '.error.message // "Unknown error"' 2>/dev/null)
            echo -e "${RED}╭─ ERROR${NC}"
            echo -e "${RED}│${NC} ${err_msg}"
            echo -e "${RED}╰─${NC}"
            ;;

        "turn.completed")
            :
            ;;

        *)
            # Unknown/non-JSON line; print raw for visibility
            if [ -n "$line" ]; then
                # If it's JSON but with unhandled fields, show minimal raw
                if echo "$line" | jq -e . >/dev/null 2>&1; then
                    raw_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
                    case "$raw_type" in
                        "item.updated")
                            # Try best-effort partial output keys
                            part=$(echo "$line" | jq -r '.item.partial_output // .delta.output // .delta.text // .data.output // .data.text // empty' 2>/dev/null)
                            if [ -n "$part" ] && [ "$part" != "null" ]; then
                                echo -e "${GREEN}│${NC} ${part}"
                            fi
                            ;;
                        *)
                            # Suppress overly chatty metadata; only show if clearly useful
                            :
                            ;;
                    esac
                else
                    echo "$line"
                fi
            fi
            ;;
    esac
done

# If no assistant message was printed, fall back to last message file
if [ -s "$TMP_OUT_FILE" ]; then
    echo -e "${GREEN}╭─ RESPONSE${NC}"
    while IFS= read -r line_text; do
        echo -e "${GREEN}│${NC} ${line_text}"
    done < "$TMP_OUT_FILE"
    echo -e "${GREEN}╰─${NC}"
fi

# Exit with Codex's exit code
exit ${PIPESTATUS[0]}
