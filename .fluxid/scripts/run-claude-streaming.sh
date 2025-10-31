#!/bin/bash

# run-claude-streaming.sh
# Runs Claude with streaming JSON output and displays clean real-time status messages
# Usage: ./run-claude-streaming.sh "your prompt here"

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PROMPT="$1"

if [ -z "$PROMPT" ]; then
    echo "ERROR: No prompt provided"
    echo "Usage: $0 \"your prompt here\""
    exit 1
fi

# Track state
show_thinking=false
current_text=""
current_tool_name=""
current_tool_desc=""
in_text_block=false
in_tool_block=false
text_block_index=-1
text_block_has_content=false

# Run Claude with partial messages enabled and parse JSON stream
claude --dangerously-skip-permissions \
    --output-format stream-json \
    --verbose \
    --include-partial-messages \
    -p "$PROMPT" 2>&1 | while IFS= read -r line; do

    # Parse JSON fields
    event_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)

    case "$event_type" in
        "system")
            subtype=$(echo "$line" | jq -r '.subtype // empty' 2>/dev/null)
            if [ "$subtype" = "init" ]; then
                model=$(echo "$line" | jq -r '.model // empty' 2>/dev/null)
                echo -e "${BLUE}╭─ CLAUDE SESSION${NC}"
                echo -e "${BLUE}│${NC} Model: ${CYAN}$model${NC}"
                echo -e "${BLUE}╰─${NC}"
            fi
            ;;

        "stream_event")
            stream_type=$(echo "$line" | jq -r '.event.type // empty' 2>/dev/null)

            case "$stream_type" in
                "message_start")
                    # New message starting - don't show header yet
                    current_text=""
                    text_block_has_content=false
                    ;;

                "content_block_start")
                    # New content block starting
                    content_type=$(echo "$line" | jq -r '.event.content_block.type // empty' 2>/dev/null)
                    block_index=$(echo "$line" | jq -r '.event.index // empty' 2>/dev/null)

                    if [ "$content_type" = "text" ]; then
                        in_text_block=true
                        text_block_index="$block_index"
                        text_block_has_content=false
                        # Don't show header yet - wait for actual content
                    elif [ "$content_type" = "tool_use" ]; then
                        in_tool_block=true
                        current_tool_name=$(echo "$line" | jq -r '.event.content_block.name // empty' 2>/dev/null)
                    fi
                    ;;

                "content_block_delta")
                    # Partial content update
                    block_index=$(echo "$line" | jq -r '.event.index // empty' 2>/dev/null)
                    delta_type=$(echo "$line" | jq -r '.event.delta.type // empty' 2>/dev/null)

                    if [ "$delta_type" = "text_delta" ]; then
                        # Stream text as it arrives
                        text_delta=$(echo "$line" | jq -r '.event.delta.text // empty' 2>/dev/null)
                        if [ -n "$text_delta" ] && [ "$text_delta" != "null" ]; then
                            # Show header on first content
                            if [ "$text_block_has_content" = false ]; then
                                echo -e "${GREEN}╭─ RESPONSE${NC}"
                                echo -ne "${GREEN}│${NC} "
                                text_block_has_content=true
                            fi

                            # Process line by line and add border prefix
                            first_line=true
                            while IFS= read -r line_text; do
                                if [ "$first_line" = false ]; then
                                    echo ""  # Newline from previous line
                                    echo -ne "${GREEN}│${NC} "
                                fi
                                echo -n "$line_text"
                                first_line=false
                            done <<< "$text_delta"

                            current_text="${current_text}${text_delta}"
                        fi
                    elif [ "$delta_type" = "input_json_delta" ]; then
                        # Tool input being constructed (we'll show it when complete)
                        :
                    fi
                    ;;

                "content_block_stop")
                    # Content block finished
                    if [ "$in_text_block" = true ]; then
                        # Only show closing if we had content
                        if [ "$text_block_has_content" = true ]; then
                            # Remove trailing colon if present
                            if [[ "$current_text" =~ :\ *$ ]]; then
                                # Count characters to backspace (colon + any trailing spaces)
                                trailing="${current_text##*[^: ]}"
                                chars_to_remove=${#trailing}
                                # Output backspaces to erase the trailing colon and spaces
                                for ((i=0; i<chars_to_remove; i++)); do
                                    echo -ne "\b \b"
                                done
                            fi
                            echo ""  # Newline after text block
                            echo -e "${GREEN}╰─${NC}"
                        fi
                        in_text_block=false
                        text_block_has_content=false
                        current_text=""
                    elif [ "$in_tool_block" = true ]; then
                        in_tool_block=false
                    fi
                    ;;

                "message_delta")
                    # Message metadata update
                    :
                    ;;

                "message_stop")
                    # Message complete - no action needed now
                    ;;
            esac
            ;;

        "assistant")
            # Legacy format (when not using partial messages) or final message
            # Check if this has tool calls
            tool_name=$(echo "$line" | jq -r '.tool_call.name // empty' 2>/dev/null)
            tool_desc=$(echo "$line" | jq -r '.tool_call.description // empty' 2>/dev/null)

            if [ -n "$tool_name" ] && [ "$tool_name" != "null" ]; then
                # Show tool usage
                echo -e "${YELLOW}╭─ TOOL${NC}"
                echo -e "${YELLOW}│${NC} ${MAGENTA}${tool_name}${NC}"
                if [ -n "$tool_desc" ] && [ "$tool_desc" != "null" ]; then
                    echo -e "${YELLOW}│${NC} ${tool_desc}"
                fi
                echo -e "${YELLOW}╰─${NC}"
            fi
            ;;

        "tool_result")
            tool_name=$(echo "$line" | jq -r '.tool_call.name // empty' 2>/dev/null)
            if [ -n "$tool_name" ] && [ "$tool_name" != "null" ]; then
                echo -e "${CYAN}✓${NC} ${tool_name} completed"
            fi
            ;;

        "result")
            subtype=$(echo "$line" | jq -r '.subtype // empty' 2>/dev/null)
            duration_ms=$(echo "$line" | jq -r '.duration_ms // empty' 2>/dev/null)
            num_turns=$(echo "$line" | jq -r '.num_turns // empty' 2>/dev/null)
            cost=$(echo "$line" | jq -r '.total_cost_usd // empty' 2>/dev/null)

            echo ""
            if [ "$subtype" = "success" ]; then
                echo -e "${GREEN}╭─ SUCCESS${NC}"
                echo -e "${GREEN}│${NC} Duration: ${duration_ms}ms"
                echo -e "${GREEN}│${NC} Turns: ${num_turns}"
                echo -e "${GREEN}│${NC} Cost: \$${cost}"
                echo -e "${GREEN}╰─${NC}"
            else
                error_msg=$(echo "$line" | jq -r '.error // "Unknown error"' 2>/dev/null)
                echo -e "${RED}╭─ ERROR${NC}"
                echo -e "${RED}│${NC} ${error_msg}"
                echo -e "${RED}╰─${NC}"
            fi
            ;;
    esac
done

# Capture exit code
exit_code=${PIPESTATUS[0]}

# Return exit code from Claude
exit $exit_code
