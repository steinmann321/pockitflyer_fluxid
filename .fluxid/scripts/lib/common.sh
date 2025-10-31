#!/bin/bash

# common.sh
# Shared utilities for fluxid scripts
# Source this file in your scripts with: source "$(dirname "$0")/lib/common.sh"

# ============================================================
# COLOR DEFINITIONS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ============================================================
# LOGGING FUNCTIONS
# ============================================================

# Print colored informational message
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Print colored success message
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Print colored warning message
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Print colored error message
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print colored timing message
log_timing() {
    echo -e "${CYAN}[TIMING]${NC} $1"
}

# Print colored dry-run message
log_dryrun() {
    echo -e "${MAGENTA}[DRY-RUN]${NC} $1"
}

# ============================================================
# TIMING UTILITIES
# ============================================================

# Get current timestamp in seconds
get_timestamp() {
    date +%s
}

# Get formatted time string
# Returns: YYYY-MM-DD HH:MM:SS
get_time_string() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Calculate duration between two timestamps
# Args: start_timestamp end_timestamp
# Returns: duration in seconds
calculate_duration() {
    local start=$1
    local end=$2
    local duration=$((end - start))
    echo "$duration"
}

# Format duration in seconds to HH:MM
# Args: duration_in_seconds
# Returns: formatted string HH:MM
format_duration_hhmm() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    printf "%02d:%02d" $hours $minutes
}

# Format duration in seconds to decimal hours
# Args: duration_in_seconds
# Returns: decimal hours (e.g., 1.50)
format_duration_decimal() {
    local total_seconds=$1
    local decimal=$(awk "BEGIN {printf \"%.2f\", $total_seconds/3600}")
    echo "$decimal"
}

# Display timing information with formatted output
# Args: start_timestamp end_timestamp label [style]
# style: "box" (default) or "simple"
display_timing() {
    local start=$1
    local end=$2
    local label=$3
    local style=${4:-"simple"}

    local start_time=$(date -r $start "+%Y-%m-%d %H:%M:%S")
    local end_time=$(date -r $end "+%Y-%m-%d %H:%M:%S")
    local duration=$(calculate_duration $start $end)
    local duration_hhmm=$(format_duration_hhmm $duration)
    local duration_decimal=$(format_duration_decimal $duration)

    echo ""
    if [ "$style" = "box" ]; then
        echo -e "${CYAN}+- ${label}${NC}"
        log_timing "Start:    ${start_time}"
        log_timing "End:      ${end_time}"
        log_timing "Duration: ${duration_hhmm} (${duration_decimal}h)"
        echo -e "${CYAN}+-${NC}"
    else
        echo -e "${CYAN}--- ${label} ---${NC}"
        log_timing "Start:    ${start_time}"
        log_timing "End:      ${end_time}"
        log_timing "Duration: ${duration_hhmm} (${duration_decimal}h)"
        echo -e "${CYAN}---${NC}"
    fi
}

# ============================================================
# FILE UTILITIES
# ============================================================

# Count files in directory matching pattern
# Args: directory [pattern]
# Returns: count of matching files
count_files() {
    local dir=$1
    local pattern=${2:-"*.md"}

    if [ ! -d "$dir" ]; then
        echo "0"
        return
    fi

    local count=$(find "$dir" -maxdepth 1 -name "$pattern" -type f | wc -l | tr -d ' ')
    echo "${count:-0}"
}

# ============================================================
# VISUAL/UI UTILITIES
# ============================================================

# Countdown with visual feedback
# Args: seconds
countdown() {
    local seconds=$1
    for ((i=seconds; i>0; i--)); do
        echo -ne "${YELLOW}Next task in ${i}s...${NC}\r"
        sleep 1
    done
    echo -ne "\033[K"  # Clear the line
}

# Print a visual separator line
print_separator() {
    echo "=============================================================="
}

# Print a box header with text
# Args: text
print_box_header() {
    local text=$1
    echo ""
    print_separator
    echo "        $text"
    print_separator
    echo ""
}

# ============================================================
# GIT WORKTREE UTILITIES
# ============================================================

# Create a git worktree for milestone review
# Args: milestone_id (e.g., "m01")
# Returns: 0 on success, 1 on failure
create_milestone_worktree() {
    local milestone_id=$1
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local worktree_path="../pockitflyer_fluxid-${milestone_id}-review"
    local worktree_branch="${milestone_id}-review"

    log_info "Creating worktree for milestone review: $milestone_id"

    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        log_warning "Worktree already exists at: $worktree_path"
        log_info "Removing existing worktree..."
        git worktree remove "$worktree_path" --force 2>/dev/null || {
            log_error "Failed to remove existing worktree"
            return 1
        }
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/${worktree_branch}"; then
        log_warning "Branch ${worktree_branch} already exists"
        log_info "Deleting existing branch..."
        git branch -D "${worktree_branch}" 2>/dev/null || {
            log_error "Failed to delete existing branch"
            return 1
        }
    fi

    # Create new worktree from current branch
    log_info "Creating worktree at: $worktree_path"
    log_info "Using current branch: $current_branch"

    if git worktree add -b "${worktree_branch}" "$worktree_path" "$current_branch"; then
        log_success "Worktree created successfully"
        log_info "Worktree location: $worktree_path"
        log_info "Worktree branch: $worktree_branch"
        return 0
    else
        log_error "Failed to create worktree"
        return 1
    fi
}

# Pause for user milestone review
# Args: milestone_id duration_seconds
pause_for_milestone_review() {
    local milestone_id=$1
    local duration=${2:-60}  # Default 60 seconds

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "🎉 MILESTONE COMPLETE: $milestone_id"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "All epics in $milestone_id are complete!"
    log_info "A review worktree has been created for your inspection."
    echo ""
    log_warning "⏸️  PAUSING FOR USER REVIEW"
    echo ""
    log_info "Please review the milestone deliverables and quality."
    log_info "The workflow will automatically continue in $duration seconds."
    echo ""
    log_info "Press Ctrl+C to stop if you need more time for review."
    echo ""

    # Countdown with visual feedback
    for ((i=duration; i>0; i--)); do
        echo -ne "${CYAN}[REVIEW PAUSE]${NC} Continuing in ${i}s... (Press Ctrl+C to stop)\r"
        sleep 1
    done
    echo -ne "\033[K"  # Clear the line

    echo ""
    log_info "✅ Review period complete - continuing with next milestone..."
    echo ""
}
