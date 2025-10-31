#!/bin/bash

# implement-tasks.sh
# Automated fluxid Task Implementation - Sequential Execution
#
# Reads tasks from fluxid/tasks/ folder, tracks progress in fluxid/progress.md,
# and executes each task with Claude synchronously. Includes iterative review loop
# to ensure complete implementation.
#
# Prerequisites:
#   - Tasks must be created via .fluxid/scripts/create-epics-and-tasks.sh
#   - Progress file must exist at fluxid/progress.md
#
# Features:
#   - Sequential task execution with progress tracking
#   - Automatic git commits after successful implementation
#   - Iterative review loop to validate completeness
#   - Pause/resume capability based on progress.md
#   - Review mode to resume review for last completed task
#
# Usage:
#   ./implement-tasks.sh                            # Normal mode: implement next incomplete task
#   ./implement-tasks.sh --review                   # Review mode: resume review for last completed task
#   ./implement-tasks.sh --agent claude|codex       # Select agent (default: claude)

set -e  # Exit on error

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/workflow.sh"
source "$SCRIPT_DIR/lib/id-utils.sh"
source "$SCRIPT_DIR/lib/progress-yaml.sh"
source "$SCRIPT_DIR/lib/fluxid-helpers.sh"
source "$SCRIPT_DIR/lib/git-sync.sh"

# Configuration
TASKS_DIR="fluxid/tasks"
PROGRESS_FILE="fluxid/progress.yaml"
STREAMING_SCRIPT="./.fluxid/scripts/run-claude-streaming.sh"
AGENT="claude"  # default agent
PAUSE_BETWEEN_TASKS=3  # Seconds to wait between tasks
REVIEW_FILE="fluxid-implement-review.md"

# Parse command line arguments
REVIEW_MODE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --review)
            REVIEW_MODE=true
            shift
            ;;
        --agent)
            if [[ -n "$2" ]]; then
                AGENT="$2"
                shift 2
            else
                log_error "--agent requires a value: claude|codex"
                exit 1
            fi
            ;;
        *)
            # Unknown flag or positional argument; ignore for now
            shift
            ;;
    esac
done

# Select streaming script based on agent
case "$AGENT" in
    claude)
        STREAMING_SCRIPT="./.fluxid/scripts/run-claude-streaming.sh"
        ;;
    codex)
        STREAMING_SCRIPT="./.fluxid/scripts/run-codex-streaming.sh"
        ;;
    *)
        log_error "Unsupported agent: $AGENT (supported: claude, codex)"
        exit 1
        ;;
esac

# Force unbuffered output (helps with Python-based CLIs)
export PYTHONUNBUFFERED=1

# Timing variables (used by workflow.sh functions)
WORKFLOW_START_TIME=""
WORKFLOW_END_TIME=""
TASK_START_TIME=""
TASK_END_TIME=""

# Check if tasks directory exists
if [ ! -d "$TASKS_DIR" ]; then
    log_error "Tasks directory '$TASKS_DIR' not found!"
    log_info "Run .fluxid/scripts/create-epics-and-tasks.sh first to create tasks"
    exit 1
fi

# Check if progress file exists
if [ ! -f "$PROGRESS_FILE" ]; then
    log_error "Progress file not found: $PROGRESS_FILE"
    log_info "Run .fluxid/scripts/create-epics-and-tasks.sh first to create progress file"
    exit 1
fi

# Function to check if sync check is needed
# Returns: 0 if sync check needed, 1 if not
should_check_branch_sync() {
    # Get the next incomplete task to determine if we need sync check
    local next_task=$(get_all_tasks | while read task_path; do
        if ! is_task_completed "$task_path"; then
            echo "$task_path"
            break
        fi
    done)

    if [ -n "$next_task" ]; then
        local next_task_id=$(extract_id_from_filename "$next_task")
        # Only check sync for first task of first epic (m*-e01-t01 pattern)
        if is_first_task_of_first_epic "$next_task_id"; then
            return 0
        fi
    fi
    return 1
}

# Ensure remote branch exists and is in sync (skip in review mode)
# Only check sync when starting first task of first epic in any milestone (m*-e01-t01)
if [ "$REVIEW_MODE" = false ]; then
    if should_check_branch_sync; then
        echo ""
        log_info "Starting first task of first epic - checking branch sync..."
        if ! ensure_remote_branch_sync "$STREAMING_SCRIPT"; then
            log_error "Branch sync check failed - cannot continue"
            exit 1
        fi
        echo ""
    fi
fi

# Mark task as completed in progress file
# Args: task_file_path (e.g., "fluxid/tasks/m01-e01-t01-name.md")
mark_completed() {
    local task_file="$1"
    local task_id=$(extract_id_from_filename "$task_file")

    mark_task_complete "$PROGRESS_FILE" "$task_id"
    log_success "Marked as completed: $task_id"
}

# Check and mark epic completion after task completion
# Args: task_id (e.g., "m01-e01-t03")
# Returns: epic_id if epic is now complete, empty string otherwise
check_epic_completion() {
    local task_id="$1"
    local epic_id=$(get_epic_from_task_id "$task_id")

    if [ -z "$epic_id" ]; then
        return 1
    fi

    # Check if all tasks in epic are complete
    if is_epic_complete "$PROGRESS_FILE" "$epic_id"; then
        # Check if epic is not already marked complete
        if ! is_epic_marked_complete "$PROGRESS_FILE" "$epic_id"; then
            mark_epic_complete "$PROGRESS_FILE" "$epic_id"
            log_success "✅ Epic completed: $epic_id"

            # Validate pre-commit hooks after epic completion
            echo ""
            log_info "Validating pre-commit hooks..."
            echo ""

            hook_validation_success=0
            $STREAMING_SCRIPT "Read and execute the instructions from .fluxid/commands/fluxid.validate-hooks.md" || hook_validation_success=$?

            if [ $hook_validation_success -eq 0 ]; then
                echo ""
                log_success "Hook validation complete"

                # If hooks were modified, commit the changes
                if git status --porcelain | grep -q -E "(pre-commit-config\.yaml|scripts/check_)"; then
                    echo ""
                    log_info "Hooks modified, committing changes..."
                    echo ""

                    commit_hooks_success=0
                    $STREAMING_SCRIPT "commit hook validation changes and fix all pre-commit hook issues" || commit_hooks_success=$?

                    if [ $commit_hooks_success -eq 0 ]; then
                        echo ""
                        log_success "Hook changes committed successfully"
                    else
                        echo ""
                        log_warning "Hook commit failed, but continuing..."
                    fi
                fi
            else
                echo ""
                log_warning "Hook validation had issues, but continuing..."
            fi

            # Run architecture review after first epic completion
            if [[ "$epic_id" == *"-e01" ]]; then
                echo ""
                log_info "First epic completed - running application structure review..."
                echo ""

                arch_review_success=0
                $STREAMING_SCRIPT "Read and execute the instructions from .fluxid/commands/fluxid.review-architecture.md" || arch_review_success=$?

                if [ $arch_review_success -eq 0 ]; then
                    echo ""

                    # Check if review file exists and has content
                    local review_file="fluxid-architecture-review.md"
                    if [ -f "$review_file" ]; then
                        local file_size=$(wc -c < "$review_file" | tr -d ' ')

                        if [ "$file_size" -eq 0 ]; then
                            log_success "Architecture review passed - structure approved"
                            rm -f "$review_file"
                        else
                            echo ""
                            log_error "❌ ARCHITECTURE REVIEW FAILED"
                            log_error "Critical structural issues found in $review_file"
                            log_error "Process BLOCKED - fix architecture issues before continuing"
                            echo ""
                            log_info "Review findings saved in: $review_file"
                            exit 1
                        fi
                    else
                        log_success "Architecture review complete - no findings file created"
                    fi
                else
                    echo ""
                    log_warning "Architecture review had issues, but continuing..."
                fi
            fi

            echo ""
            echo "$epic_id"
            return 0
        fi
    fi

    return 1
}

# Check and handle milestone completion after epic completion
# Args: epic_id (e.g., "m01-e02")
# Returns: milestone_id if milestone is now complete, empty string otherwise
check_milestone_completion() {
    local epic_id="$1"
    local milestone_id=$(get_milestone_from_id "$epic_id")

    if [ -z "$milestone_id" ]; then
        return 1
    fi

    # Check if all epics in milestone are complete
    if is_milestone_complete "$PROGRESS_FILE" "$milestone_id"; then
        # Check if milestone is not already marked complete
        if ! is_milestone_marked_complete "$PROGRESS_FILE" "$milestone_id"; then
            log_success "🎉 All epics complete for milestone: $milestone_id"

            # Run comprehensive test suite
            echo ""
            log_info "Running comprehensive tests for milestone $milestone_id..."
            echo ""

            test_success=0
            $STREAMING_SCRIPT "Run ALL backend and Flutter tests (including integration/e2e)." || test_success=$?

            if [ $test_success -ne 0 ]; then
                echo ""
                log_error "Test execution failed for milestone $milestone_id"
                return 1
            fi

            echo ""
            log_success "✅ All tests passed!"

            # Push changes using library function
            echo ""
            if ! push_to_remote "$STREAMING_SCRIPT"; then
                echo ""
                log_error "❌ PUSH FAILED"
                log_error "Milestone $milestone_id BLOCKED"
                log_error "Process interrupted - fix push issues before continuing"
                exit 1
            fi

            # Verify push was successful
            echo ""
            log_info "Verifying push was successful..."

            if ! verify_push_success; then
                echo ""
                log_error "❌ PUSH VERIFICATION FAILED - Branch still ahead of remote"
                log_error "Milestone $milestone_id BLOCKED"
                log_error "Process interrupted - fix push issues before continuing"
                exit 1
            fi

            echo ""
            log_success "✅ Changes pushed successfully!"

            # Mark milestone as complete
            echo ""
            mark_milestone_complete "$PROGRESS_FILE" "$milestone_id"
            log_success "Marked milestone as completed: $milestone_id"

            # Display milestone completion summary and exit
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_success "🎉 MILESTONE COMPLETE: $milestone_id"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            log_info "Summary:"
            log_info "  • All epics in milestone $milestone_id completed"
            log_info "  • All tests passed successfully"
            log_info "  • Changes pushed to remote"
            log_info "  • Progress saved to $PROGRESS_FILE"
            echo ""
            log_info "Process complete. Resume implementation by running this script again."
            echo ""
            exit 0
        fi
    fi

    return 1
}

# Count tasks from progress file
count_tasks() {
    count_progress_tasks_detailed "$PROGRESS_FILE"
}

# Get all task files from progress.md
# Returns list of task file paths in order
get_all_tasks() {
    get_task_files_from_progress "$PROGRESS_FILE" "$TASKS_DIR"
}

# Check if task is completed in progress file
# Args: task_file_path (e.g., "fluxid/tasks/m01-e01-t01-name.md")
is_task_completed() {
    local task_file="$1"
    local task_id=$(extract_id_from_filename "$task_file")

    is_task_complete "$PROGRESS_FILE" "$task_id"
}

# Review loop - iteratively review and fix implementation
# Args: task_path
review_loop() {
    local task_path="$1"
    local review_file="$REVIEW_FILE"
    local max_iterations=5
    local iteration=0

    log_info "Starting implementation review loop..."
    echo ""

    while [ $iteration -lt $max_iterations ]; do
        iteration=$((iteration + 1))

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Review Iteration $iteration/$max_iterations"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Run implementation review
        log_info "Running implementation review for: $task_path"
        echo ""

        review_success=0
        $STREAMING_SCRIPT "Read and execute the instructions from .fluxid/commands/fluxid.review-implementation.md for task file: $task_path" || review_success=$?

        if [ $review_success -ne 0 ]; then
            log_error "Review generation failed"
            return 1
        fi

        # Check if review file exists and get its size
        if [ ! -f "$review_file" ]; then
            log_warning "Review file not created: $review_file"
            log_info "Assuming implementation is complete"
            return 0
        fi

        local file_size=$(wc -c < "$review_file" | tr -d ' ')
        log_info "Review file size: $file_size bytes"

        # If review file is empty (0 bytes), we're done!
        if [ "$file_size" -eq 0 ]; then
            echo ""
            log_success "Review passed! No gaps found."
            log_info "Removing empty review file..."
            rm -f "$review_file"
            return 0
        fi

        # Review has content - show summary
        echo ""
        log_warning "Review found gaps to address"
        echo ""

        # Implement the review findings
        log_info "Implementing review findings..."
        echo ""

        implement_success=0
        $STREAMING_SCRIPT "Implement the findings from the implementation review $review_file" || implement_success=$?

        if [ $implement_success -ne 0 ]; then
            log_error "Failed to implement review findings"
            log_info "Review file preserved at: $review_file"
            return 1
        fi

        echo ""
        log_success "Review findings implemented"
        echo ""

        # Remove review file before committing (so it's not included in commit)
        log_info "Removing review file before commit..."
        rm -f "$review_file"

        # Commit the review fixes
        log_info "Committing review fixes (iteration $iteration)..."
        echo ""

        commit_success=0
        $STREAMING_SCRIPT "commit the review fixes with message 'review iteration $iteration fixes for $task_path'" || commit_success=$?

        if [ $commit_success -eq 0 ]; then
            echo ""
            log_success "Review fixes committed"
        else
            echo ""
            log_warning "Commit failed, but continuing review loop..."
        fi

        echo ""
        log_info "Proceeding to next review iteration..."
        echo ""
        sleep 2
    done

    # Max iterations reached
    echo ""
    log_warning "Maximum review iterations ($max_iterations) reached"
    log_info "Review file preserved at: $review_file"
    log_info "You may want to manually review remaining gaps"

    return 0
}

# Cleanup review file
cleanup_review_file() {
    if [ -f "$REVIEW_FILE" ]; then
        log_info "Cleaning up review file..."
        rm -f "$REVIEW_FILE"
    fi
}

# Get last completed task path
# Returns: path to last completed task, or empty if none
get_last_completed_task() {
    local all_tasks=($(get_all_tasks))
    local last_completed=""

    for task_path in "${all_tasks[@]}"; do
        if is_task_completed "$task_path"; then
            last_completed="$task_path"
        else
            # Once we hit an incomplete task, we're done
            break
        fi
    done

    echo "$last_completed"
}

# Main loop
main() {
    # Start workflow timer
    WORKFLOW_START_TIME=$(get_timestamp)

    print_box_header "fluxid Task Implementation"

    # Check for review mode
    if [ "$REVIEW_MODE" = true ]; then
        log_info "Review mode activated"

        # Find last completed task
        local last_completed=$(get_last_completed_task)

        if [ -z "$last_completed" ]; then
            log_error "No completed tasks found for review"
            log_info "Run without --review to start implementation"
            exit 1
        fi

        log_info "Target task: $(basename "$last_completed")"
        log_info "Start time: $(get_time_string)"
        echo ""

        # Run review loop for the last completed task
        # The review loop will generate the review file in its first iteration if it doesn't exist
        review_loop_success=0
        review_loop "$last_completed" || review_loop_success=$?

        if [ $review_loop_success -eq 0 ]; then
            echo ""
            log_success "Review complete for: $(basename "$last_completed")"
        else
            echo ""
            log_error "Review loop failed"
            exit 1
        fi

        # End workflow timer
        WORKFLOW_END_TIME=$(get_timestamp)

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_success "Review mode complete!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        # Display timing
        display_timing $WORKFLOW_START_TIME $WORKFLOW_END_TIME "REVIEW TIMING"

        echo ""
        cleanup_review_file
        exit 0
    fi

    log_info "Starting automated task implementation..."
    log_info "Start time: $(get_time_string)"
    log_info "Progress: $(count_tasks)"
    echo ""

    # Get all task file paths from progress file
    local all_tasks=($(get_all_tasks))
    local total_tasks=${#all_tasks[@]}
    local current_idx=0

    if [ $total_tasks -eq 0 ]; then
        log_warning "No tasks found in $PROGRESS_FILE"
        exit 0
    fi

    # Iterate through all tasks
    for task_path in "${all_tasks[@]}"; do
        current_idx=$((current_idx + 1))

        # Skip if already completed
        if is_task_completed "$task_path"; then
            log_info "[$current_idx/$total_tasks] Skipping completed task: $(basename "$task_path")"
            continue
        fi

        if [ ! -f "$task_path" ]; then
            log_error "Task file not found: $task_path"
            log_warning "Skipping..."
            continue
        fi

        # Extract task title from markdown frontmatter or first H1
        task_title=$(head -20 "$task_path" | grep -E "^(title: |# )" | head -1 | sed 's/^title: //;s/^# //')

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "[$current_idx/$total_tasks] Implementing: $task_title"
        log_info "File: $task_path"
        log_info "Progress: $(count_tasks)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Start task timer
        TASK_START_TIME=$(get_timestamp)
        log_info "Task start time: $(get_time_string)"
        echo ""

        # Check if this is the first task of an epic and create git tag
        local task_id=$(extract_id_from_filename "$task_path")
        if is_first_task_of_epic "$task_id"; then
            local epic_id=$(get_epic_from_task_id "$task_id")
            local tag_name="start-epic-${epic_id}"

            log_info "First task of epic detected - creating git tag: $tag_name"
            if git tag "$tag_name" 2>/dev/null; then
                log_success "Git tag created: $tag_name"
            else
                log_warning "Git tag '$tag_name' already exists or could not be created"
            fi
            echo ""
        fi

        # Execute selected agent synchronously (no background mode)
        log_info "Executing task with $AGENT..."
        echo ""

        # Run agent using streaming wrapper for real-time status
        # Execute TDD implementation workflow from command file
        claude_success=0
        $STREAMING_SCRIPT "Read and execute the instructions from .fluxid/commands/fluxid.implement.md for task file: $task_path" || claude_success=$?

        # End task timer
        TASK_END_TIME=$(get_timestamp)

        if [ $claude_success -eq 0 ]; then
            # Task succeeded
            echo ""
            log_success "Task completed successfully"

            # Display task timing
            display_timing $TASK_START_TIME $TASK_END_TIME "TASK TIMING"

            # Mark task as completed
            mark_completed "$task_path"
            local task_id=$(extract_id_from_filename "$task_path")
            log_info "Updated progress: $(count_tasks)"
            echo ""

            # Check if epic is now complete
            local completed_epic=$(check_epic_completion "$task_id")
            if [ -n "$completed_epic" ]; then
                echo ""
                log_info "Epic $completed_epic is now complete!"

                # Check if milestone is now complete (will exit if true)
                check_milestone_completion "$completed_epic" || true
            fi
            echo ""

            # Commit the changes
            log_info "Committing changes..."
            echo ""

            # Use streaming wrapper for commit too
            commit_success=0
            $STREAMING_SCRIPT "commit with message referencing task file '$task_path' and fix all pre-commit hook issues" || commit_success=$?

            if [ $commit_success -eq 0 ]; then
                echo ""
                log_success "Changes committed successfully"

                # Run review loop to ensure complete implementation
                echo ""
                log_info "Starting implementation review process..."
                echo ""

                review_loop_success=0
                review_loop "$task_path" || review_loop_success=$?

                if [ $review_loop_success -eq 0 ]; then
                    echo ""
                    log_success "Implementation review complete"
                else
                    echo ""
                    log_warning "Review loop had issues, but task is marked complete"
                fi
            else
                echo ""
                log_warning "Commit failed, skipping review loop..."
            fi

            echo ""

            # Countdown before next task
            if [ $current_idx -lt $total_tasks ]; then
                countdown $PAUSE_BETWEEN_TASKS
            fi
        else
            # Task failed
            echo ""
            log_error "Task failed (exit code: $?)"

            # Display task timing even on failure
            display_timing $TASK_START_TIME $TASK_END_TIME "TASK TIMING (FAILED)"

            log_warning "Task NOT marked as completed - will remain for retry"
            log_info "Continuing to next task..."
            echo ""

            # Countdown before next task
            if [ $current_idx -lt $total_tasks ]; then
                countdown $PAUSE_BETWEEN_TASKS
            fi
        fi
    done

    # End workflow timer
    WORKFLOW_END_TIME=$(get_timestamp)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Task implementation run complete!"
    log_info "Final progress: $(count_tasks)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Display total timing
    display_timing $WORKFLOW_START_TIME $WORKFLOW_END_TIME "TOTAL WORKFLOW TIMING"

    # Final cleanup - ensure review file is removed
    echo ""
    cleanup_review_file

    echo ""
    print_box_header "Next Steps"
    log_info "Continue implementing remaining tasks or review completed work"
    echo ""
}

# Handle Ctrl+C gracefully
trap 'echo ""; log_warning "Interrupted by user"; log_info "Progress saved in $PROGRESS_FILE"; cleanup_review_file; exit 130' INT TERM

# Run main
main
