#!/bin/bash

# create-epics-and-tasks.sh
# Automated fluxid Epic and Task Creation - Creates Epics and Tasks from Milestones
# Requires existing milestones to function
#
# Usage:
#   ./create-epics-and-tasks.sh           # Normal execution
#   ./create-epics-and-tasks.sh --dry-run # Dry run mode (show what would be executed)

set -e  # Exit on error

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/workflow.sh"
source "$SCRIPT_DIR/lib/id-utils.sh"
source "$SCRIPT_DIR/lib/fluxid-helpers.sh"
source "$SCRIPT_DIR/lib/validation.sh"

# Parse command line arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be executed without running Claude commands"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Configuration
MILESTONES_DIR="fluxid/milestones"
EPICS_DIR="fluxid/epics"
TASKS_DIR="fluxid/tasks"
PROGRESS_FILE="fluxid/progress.md"
STREAMING_SCRIPT="./.fluxid/scripts/run-claude-streaming.sh"

# Timing variables (used by workflow.sh functions)
WORKFLOW_START_TIME=""
WORKFLOW_END_TIME=""
STEP_START_TIME=""
STEP_END_TIME=""

# Track milestones that have been structurally validated after epic creation
declare -a VALIDATED_MILESTONES=()
MILESTONE_TASKS_DONE=""

# Verify prerequisites
verify_prerequisites() {
    log_info "Verifying prerequisites..."

    # Check if milestones exist
    local milestone_count=$(count_files "$MILESTONES_DIR" "m*.md")
    if [ "$milestone_count" -eq 0 ]; then
        echo ""
        log_error "No milestones found in $MILESTONES_DIR"
        echo ""
        print_box_header "Create and Review Milestones First!"
        log_info "Before creating epics and tasks, you need milestones."
        echo ""
        log_info "Run: .fluxid/scripts/create-milestones.sh"
        echo ""
        log_info "This will:"
        log_info "  1. Analyze your product definition"
        log_info "  2. Create milestone breakdown"
        log_info "  3. Allow you to review and refine milestones"
        echo ""
        log_info "Once milestones are reviewed and finalized,"
        log_info "re-run this script to generate epics and tasks."
        echo ""
        return 1
    fi

    log_success "Found $milestone_count milestone(s)"

    # Check if streaming script exists
    if [ ! -f "$STREAMING_SCRIPT" ]; then
        log_error "Streaming script not found: $STREAMING_SCRIPT"
        return 1
    fi

    log_success "Streaming script found"

    # Create directories if they don't exist
    mkdir -p "$EPICS_DIR" "$TASKS_DIR"
    log_success "Directory structure verified"

    echo ""
    return 0
}

# Main workflow
main() {
    print_box_header "fluxid Epic and Task Creation"
    log_info "Milestones → Epics → Tasks → Progress"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "Running in DRY-RUN mode - no Claude commands will be executed"
        echo ""
    fi

    # Start workflow timer
    WORKFLOW_START_TIME=$(get_timestamp)
    log_info "Workflow start time: $(get_time_string)"
    echo ""

    # Verify prerequisites
    if ! verify_prerequisites; then
        exit 1
    fi

    # Detect resume point
    RESUME_FROM=$(detect_resume_point)
    if ! show_resume_info "$RESUME_FROM"; then
        # All steps already completed
        exit 0
    fi

    # Count milestones
    milestone_count=$(count_files "$MILESTONES_DIR" "m*.md")
    log_info "Processing $milestone_count milestone(s)"
    echo ""
    sleep 2

    # Step 1: Create Epics for each milestone
    if [ "$RESUME_FROM" -le 1 ]; then
        echo ""
        echo "=============================================================="
        log_info "Step 1/3: Create Epics for Milestones"
        echo "=============================================================="
        echo ""

        # Start step timer for all epics
        STEP_START_TIME=$(get_timestamp)

        # Get milestones that need epics
        milestone_files=($(get_milestones_needing_epics))

        if [ ${#milestone_files[@]} -eq 0 ]; then
            log_info "All milestones already have epics - nothing to do"
        else
            current_milestone=0
            total_milestones=${#milestone_files[@]}

            for milestone_file in "${milestone_files[@]}"; do
                current_milestone=$((current_milestone + 1))
                milestone_basename=$(basename "$milestone_file")

                echo ""
                log_info "[$current_milestone/$total_milestones] Creating epics for: $milestone_basename"
                echo ""

                if [ "$DRY_RUN" = true ]; then
                    log_dryrun "Would execute: $STREAMING_SCRIPT \"/fluxid.create-epics $milestone_file\""
                    log_dryrun "Epics would be created for $milestone_basename"
                    epic_success=0
                else
                    epic_success=0
                    $STREAMING_SCRIPT "/fluxid.create-epics $milestone_file" || epic_success=$?

                    if [ $epic_success -ne 0 ]; then
                        log_error "Failed to create epics for $milestone_basename"
                        exit 1
                    fi

                    log_success "Epics created for $milestone_basename"

                    # Extract milestone ID
                    milestone_id=$(basename "$milestone_file" | cut -d'-' -f1)

                    # Store milestone ID for later structural validation after tasks
                    VALIDATED_MILESTONES+=("$milestone_id")
                fi
            done
        fi

        # End step timer
        STEP_END_TIME=$(get_timestamp)

        echo ""
        if [ "$DRY_RUN" = true ]; then
            log_dryrun "All epics would be created successfully"
        else
            log_success "All epics created successfully"
        fi
        display_timing $STEP_START_TIME $STEP_END_TIME "STEP 2 TIMING (ALL EPICS)"

        # Count epics
        epic_count=$(count_files "$EPICS_DIR" "m*-e*.md")
        if [ "$DRY_RUN" = true ]; then
            log_dryrun "Would have created epics (simulated: ${epic_count:-0} existing)"
        else
            log_info "Total epics created: $epic_count"
        fi

        if [ "$DRY_RUN" = false ] && [ "$epic_count" -eq 0 ]; then
            log_error "No epics were created!"
            exit 1
        fi

        echo ""
        sleep 2
    else
        log_info "Skipping Step 1/3 - Epics already exist"
        epic_count=$(count_files "$EPICS_DIR" "m*-e*.md")
        echo ""
    fi

    # Step 3: Create Tasks for each epic
    if [ "$RESUME_FROM" -le 3 ]; then
        echo ""
        echo "=============================================================="
        log_info "Step 2/3: Create Tasks for Epics"
        echo "=============================================================="
        echo ""

        # Start step timer for all tasks
        STEP_START_TIME=$(get_timestamp)

        # Get epics that need tasks
        epic_files=($(get_epics_needing_tasks))

        if [ ${#epic_files[@]} -eq 0 ]; then
            log_info "All epics already have tasks - nothing to do"
        else
            current_epic=0
            total_epics=${#epic_files[@]}

            for epic_file in "${epic_files[@]}"; do
                current_epic=$((current_epic + 1))
                epic_basename=$(basename "$epic_file")

                echo ""
                log_info "[$current_epic/$total_epics] Creating tasks for: $epic_basename"
                echo ""

                if [ "$DRY_RUN" = true ]; then
                    log_dryrun "Would execute: $STREAMING_SCRIPT \"/fluxid.create-tasks $epic_file\""
                    log_dryrun "Tasks would be created for $epic_basename"
                    task_success=0
                else
                    task_success=0
                    $STREAMING_SCRIPT "/fluxid.create-tasks $epic_file" || task_success=$?

                    if [ $task_success -ne 0 ]; then
                        log_error "Failed to create tasks for $epic_basename"
                        exit 1
                    fi

                    log_success "Tasks created for $epic_basename"

                    # Extract epic and milestone IDs
                    epic_id=$(basename "$epic_file" | cut -d'-' -f1,2,3)
                    milestone_id=$(echo "$epic_id" | cut -d'-' -f1)

                    # Mark tasks done for this epic's milestone
                    if [[ ! " $MILESTONE_TASKS_DONE " =~ " $milestone_id " ]]; then
                        MILESTONE_TASKS_DONE="$MILESTONE_TASKS_DONE $milestone_id"
                    fi
                fi
            done
        fi

        # End step timer
        STEP_END_TIME=$(get_timestamp)

        echo ""
        if [ "$DRY_RUN" = true ]; then
            log_dryrun "All tasks would be created successfully"
        else
            log_success "All tasks created successfully"

            # Final structural validation for each milestone that had tasks created
            if [ -n "$MILESTONE_TASKS_DONE" ]; then
                echo ""
                echo "=============================================================="
                log_info "Final Structural Validation"
                echo "=============================================================="
                echo ""

                for milestone_id in $MILESTONE_TASKS_DONE; do
                    log_info "Re-validating structure for $milestone_id after all tasks..."
                    echo ""
                    validate_structure "$milestone_id"
                    echo ""
                done

                log_success "All structural validations passed"
            fi
        fi
        display_timing $STEP_START_TIME $STEP_END_TIME "STEP 3 TIMING (ALL TASKS)"

        # Count tasks
        task_count=$(count_files "$TASKS_DIR" "m*-e*-t*.md")
        if [ "$DRY_RUN" = true ]; then
            log_dryrun "Would have created tasks (simulated: ${task_count:-0} existing)"
        else
            log_info "Total tasks created: $task_count"
        fi

        if [ "$DRY_RUN" = false ] && [ "$task_count" -eq 0 ]; then
            log_error "No tasks were created!"
            exit 1
        fi

        echo ""
        sleep 2
    else
        log_info "Skipping Step 2/3 - Tasks already exist"
        task_count=$(count_files "$TASKS_DIR" "m*-e*-t*.md")
        echo ""
    fi

    # Step 3: Create Progress Tracking
    if [ "$RESUME_FROM" -le 3 ]; then
        if ! execute_step \
            "3/3" \
            "Create Progress Tracking File" \
            "Read and execute the instructions from .fluxid/commands/fluxid.create-progress.md" \
            "$PROGRESS_FILE"; then
            log_error "Failed to create progress tracking"
            exit 1
        fi
    else
        log_info "Skipping Step 3/3 - Progress file already exists"
    fi

    echo ""
    sleep 2

    # End workflow timer
    WORKFLOW_END_TIME=$(get_timestamp)

    # Display summary
    if [ "$DRY_RUN" = true ]; then
        print_box_header "fluxid Task Breakdown Dry-Run Complete!"
    else
        print_box_header "fluxid Task Breakdown Complete!"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "Dry-run workflow completed successfully!"
    else
        log_success "Workflow completed successfully!"
    fi
    echo ""
    log_info "Summary:"
    if [ "$DRY_RUN" = true ]; then
        log_info "  Milestones: ${milestone_count:-0} (existing)"
        log_info "  Epics:      ${epic_count:-0} (would process)"
        log_info "  Tasks:      ${task_count:-0} (would process)"
        log_info "  Progress:   $PROGRESS_FILE (would create/update)"
    else
        log_info "  Milestones: $milestone_count (processed)"
        log_info "  Epics:      $epic_count"
        log_info "  Tasks:      $task_count"
        log_info "  Progress:   $PROGRESS_FILE"
    fi
    echo ""

    # Display total timing
    display_timing $WORKFLOW_START_TIME $WORKFLOW_END_TIME "TOTAL WORKFLOW TIMING"

    echo ""
    if [ "$DRY_RUN" = true ]; then
        log_info "This was a dry-run. No actual changes were made."
        log_info "Run without --dry-run to execute the workflow for real."
    else
        print_box_header "Next Steps"
        log_info "1. Review created files:"
        log_info "   - Epics:    $EPICS_DIR/"
        log_info "   - Tasks:    $TASKS_DIR/"
        log_info "   - Progress: $PROGRESS_FILE"
        echo ""
        log_info "2. Start implementation:"
        log_info "   .fluxid/scripts/implement-tasks.sh"
    fi
    echo ""
}

# Handle Ctrl+C gracefully
trap 'echo ""; log_warning "Workflow interrupted by user"; exit 130' INT TERM

# Run main
main
