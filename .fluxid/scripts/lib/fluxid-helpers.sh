#!/bin/bash

# fluxid-helpers.sh
# fluxid-specific workflow helpers
# Requires: common.sh, id-utils.sh

# Source dependencies
_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LIB_DIR/id-utils.sh"

# ============================================================
# MILESTONE/EPIC/TASK DETECTION
# ============================================================

# Check which milestones need epics
# Args: none (uses global MILESTONES_DIR, EPICS_DIR)
# Returns: space-separated list of milestone file paths needing epics
get_milestones_needing_epics() {
    local milestones_needing_epics=()

    # Get all milestone files
    for milestone_file in "$MILESTONES_DIR"/m*.md; do
        [ -f "$milestone_file" ] || continue

        local milestone_id=$(get_id "$milestone_file")
        [ -z "$milestone_id" ] && continue

        # Check if any epic exists for this milestone (look for id: m01-e* in epic frontmatter)
        local has_epic=0
        for epic_file in "$EPICS_DIR"/*.md; do
            [ -f "$epic_file" ] || continue
            local epic_id=$(get_id "$epic_file")
            # Check if epic belongs to this milestone (e.g., m01-e01 starts with m01-)
            if [[ "$epic_id" == ${milestone_id}-e* ]]; then
                has_epic=1
                break
            fi
        done

        if [ "$has_epic" -eq 0 ]; then
            milestones_needing_epics+=("$milestone_file")
        fi
    done

    echo "${milestones_needing_epics[@]}"
}

# Check which epics need tasks
# Args: none (uses global EPICS_DIR, TASKS_DIR)
# Returns: space-separated list of epic file paths needing tasks
get_epics_needing_tasks() {
    local epics_needing_tasks=()

    # Get all epic files
    for epic_file in "$EPICS_DIR"/*.md; do
        [ -f "$epic_file" ] || continue

        local epic_id=$(get_id "$epic_file")
        [ -z "$epic_id" ] && continue

        # Check if any task exists for this epic (look for id: m01-e01-t* in task frontmatter)
        local has_task=0
        for task_file in "$TASKS_DIR"/*.md; do
            [ -f "$task_file" ] || continue
            local task_id=$(get_id "$task_file")
            # Check if task belongs to this epic (e.g., m01-e01-t01 starts with m01-e01-)
            if [[ "$task_id" == ${epic_id}-t* ]]; then
                has_task=1
                break
            fi
        done

        if [ "$has_task" -eq 0 ]; then
            epics_needing_tasks+=("$epic_file")
        fi
    done

    echo "${epics_needing_tasks[@]}"
}

# ============================================================
# WORKFLOW RESUME DETECTION
# ============================================================

# Detect which step to resume from
# Args: none (uses global MILESTONES_DIR, EPICS_DIR, TASKS_DIR, PROGRESS_FILE)
# Returns: step number (1=epics, 2=tasks, 3=progress, 4=done)
detect_resume_point() {
    local has_progress=0
    [ -f "$PROGRESS_FILE" ] && has_progress=1

    # Check what needs to be created (regardless of progress file existence)
    # This allows adding new epics/tasks after initial setup

    # Check if we need to create epics for some milestones
    local milestones_needing_epics=($(get_milestones_needing_epics))
    if [ ${#milestones_needing_epics[@]} -gt 0 ]; then
        echo "1"  # Some milestones need epics
        return
    fi

    # Check if we need to create tasks for some epics
    local epics_needing_tasks=($(get_epics_needing_tasks))
    if [ ${#epics_needing_tasks[@]} -gt 0 ]; then
        echo "2"  # Some epics need tasks
        return
    fi

    # Check if progress file needs to be created/updated
    if [ "$has_progress" -eq 0 ]; then
        echo "3"  # Need progress
        return
    fi

    # Everything is up to date
    echo "4"  # All complete
}

# Display resume information
# Args: resume_step
# Uses global: MILESTONES_DIR, EPICS_DIR, TASKS_DIR, PROGRESS_FILE
# Returns: 0 if should continue, 1 if all complete
show_resume_info() {
    local resume_step=$1
    local milestone_count=$(count_files "$MILESTONES_DIR" "m*.md")
    local epic_count=$(count_files "$EPICS_DIR" "m*-e*.md")
    local task_count=$(count_files "$TASKS_DIR" "m*-e*-t*.md")

    echo ""
    log_info "Detected existing workflow progress:"
    echo ""
    log_info "  Milestones: $milestone_count files"
    log_info "  Epics:      $epic_count files"
    log_info "  Tasks:      $task_count files"
    log_info "  Progress:   $([ -f "$PROGRESS_FILE" ] && echo "exists" || echo "missing")"
    echo ""

    case $resume_step in
        1)
            local milestones_needing_epics=($(get_milestones_needing_epics))
            log_warning "Resuming from: Step 1 - Create Epics"
            log_info "  Milestones needing epics: ${#milestones_needing_epics[@]}"
            if [ ${#milestones_needing_epics[@]} -gt 0 ]; then
                for ms in "${milestones_needing_epics[@]}"; do
                    log_info "    - $(basename "$ms")"
                done
            fi
            ;;
        2)
            local epics_needing_tasks=($(get_epics_needing_tasks))
            log_warning "Resuming from: Step 2 - Create Tasks"
            log_info "  Epics needing tasks: ${#epics_needing_tasks[@]}"
            if [ ${#epics_needing_tasks[@]} -gt 0 ]; then
                for ep in "${epics_needing_tasks[@]}"; do
                    log_info "    - $(basename "$ep")"
                done
            fi
            ;;
        3)
            log_warning "Resuming from: Step 3 - Create Progress"
            log_info "  All milestones have epics, all epics have tasks"
            ;;
        4)
            log_success "All steps completed! Nothing to do."
            return 1
            ;;
    esac
    echo ""
    return 0
}
