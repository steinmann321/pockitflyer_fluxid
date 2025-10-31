#!/bin/bash

# progress-yaml.sh
# fluxid progress tracking operations using YAML
# Requires: yq (https://github.com/mikefarah/yq/)

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is not installed. Please install it: brew install yq"
    exit 1
fi

# ============================================================
# PROGRESS FILE PARSING
# ============================================================

# Get all task IDs from progress.yaml
# Args: progress_file_path
# Returns: space-separated list of task IDs (e.g., "m01-e01-t01 m01-e01-t02")
get_task_ids_from_progress() {
    local progress_file=$1
    yq '.milestones[].epics[].tasks[].id' "$progress_file" | tr '\n' ' ' | xargs
}

# Get all task files from progress.yaml by finding corresponding files in task directory
# Args: progress_file_path tasks_dir
# Returns: newline-separated list of task file paths
get_task_files_from_progress() {
    local progress_file=$1
    local tasks_dir=$2

    # Get task IDs from progress file
    local task_ids=$(get_task_ids_from_progress "$progress_file")

    # Find corresponding task files
    for task_id in $task_ids; do
        # Find file that starts with this task ID
        local task_file=$(find "$tasks_dir" -name "${task_id}-*.md" -type f | head -1)
        if [ -n "$task_file" ]; then
            echo "$task_file"
        fi
    done
}

# Count total and completed tasks from progress file
# Args: progress_file_path
# Returns: "completed/total" (e.g., "5/10")
count_progress_tasks() {
    local progress_file=$1

    local total=$(yq '[.milestones[].epics[].tasks[]] | length' "$progress_file")
    local completed=$(yq '[.milestones[].epics[].tasks[] | select(.complete == true)] | length' "$progress_file")

    echo "$completed/$total"
}

# Count with details (includes remaining count)
# Args: progress_file_path
# Returns: "completed/total completed (remaining remaining)"
count_progress_tasks_detailed() {
    local progress_file=$1
    local count=$(count_progress_tasks "$progress_file")
    local completed=$(echo "$count" | cut -d'/' -f1)
    local total=$(echo "$count" | cut -d'/' -f2)
    local remaining=$((total - completed))

    echo "$count completed ($remaining remaining)"
}

# ============================================================
# PROGRESS MODIFICATION
# ============================================================

# Mark task as completed in progress file
# Args: progress_file_path task_id
# Example: mark_task_complete "fluxid/progress.yaml" "m01-e01-t01"
mark_task_complete() {
    local progress_file=$1
    local task_id=$2

    # Update the complete flag to true for the matching task
    yq -i "(.milestones[].epics[].tasks[] | select(.id == \"$task_id\") | .complete) = true" "$progress_file"
}

# Mark task as incomplete in progress file (revert completion)
# Args: progress_file_path task_id
mark_task_incomplete() {
    local progress_file=$1
    local task_id=$2

    yq -i "(.milestones[].epics[].tasks[] | select(.id == \"$task_id\") | .complete) = false" "$progress_file"
}

# ============================================================
# PROGRESS QUERIES
# ============================================================

# Check if task is completed in progress file
# Args: progress_file_path task_id
# Returns: 0 if completed, 1 if not
is_task_complete() {
    local progress_file=$1
    local task_id=$2

    local complete=$(yq ".milestones[].epics[].tasks[] | select(.id == \"$task_id\") | .complete" "$progress_file")
    [ "$complete" = "true" ]
}

# Check if task exists in progress file
# Args: progress_file_path task_id
# Returns: 0 if exists, 1 if not
task_in_progress() {
    local progress_file=$1
    local task_id=$2

    local exists=$(yq ".milestones[].epics[].tasks[] | select(.id == \"$task_id\") | .id" "$progress_file")
    [ -n "$exists" ]
}

# Get completion status of task
# Args: progress_file_path task_id
# Returns: "complete", "incomplete", or "not-found"
get_task_status() {
    local progress_file=$1
    local task_id=$2

    if is_task_complete "$progress_file" "$task_id"; then
        echo "complete"
    elif task_in_progress "$progress_file" "$task_id"; then
        echo "incomplete"
    else
        echo "not-found"
    fi
}

# Get list of completed task IDs
# Args: progress_file_path
# Returns: space-separated list of completed task IDs
get_completed_tasks() {
    local progress_file=$1
    yq '.milestones[].epics[].tasks[] | select(.complete == true) | .id' "$progress_file" | tr '\n' ' ' | xargs
}

# Get list of incomplete task IDs
# Args: progress_file_path
# Returns: space-separated list of incomplete task IDs
get_incomplete_tasks() {
    local progress_file=$1
    yq '.milestones[].epics[].tasks[] | select(.complete == false) | .id' "$progress_file" | tr '\n' ' ' | xargs
}

# ============================================================
# EPIC/MILESTONE PROGRESS
# ============================================================

# Get all task IDs for a specific epic
# Args: progress_file_path epic_id
# Returns: space-separated list of task IDs belonging to this epic
get_epic_tasks() {
    local progress_file=$1
    local epic_id=$2

    yq ".milestones[].epics[] | select(.id == \"$epic_id\") | .tasks[].id" "$progress_file" | tr '\n' ' ' | xargs
}

# Check if all tasks in an epic are complete
# Args: progress_file_path epic_id
# Returns: 0 if all complete, 1 if any incomplete
is_epic_complete() {
    local progress_file=$1
    local epic_id=$2

    local epic_tasks=$(get_epic_tasks "$progress_file" "$epic_id")

    # If no tasks, epic is not complete
    [ -z "$epic_tasks" ] && return 1

    # Check if all tasks are complete
    for task_id in $epic_tasks; do
        if ! is_task_complete "$progress_file" "$task_id"; then
            return 1
        fi
    done

    return 0
}

# Get completion percentage for an epic
# Args: progress_file_path epic_id
# Returns: percentage (0-100)
get_epic_progress() {
    local progress_file=$1
    local epic_id=$2

    local total=$(yq ".milestones[].epics[] | select(.id == \"$epic_id\") | .tasks | length" "$progress_file")
    local completed=$(yq ".milestones[].epics[] | select(.id == \"$epic_id\") | .tasks[] | select(.complete == true)" "$progress_file" | grep -c "^id:" || echo "0")

    if [ "$total" -eq 0 ]; then
        echo "0"
    else
        echo $((completed * 100 / total))
    fi
}

# Mark epic as completed in progress file
# Args: progress_file_path epic_id
# Example: mark_epic_complete "fluxid/progress.yaml" "m01-e01"
mark_epic_complete() {
    local progress_file=$1
    local epic_id=$2

    yq -i "(.milestones[].epics[] | select(.id == \"$epic_id\") | .complete) = true" "$progress_file"
}

# Check if epic is marked complete in progress file
# Args: progress_file_path epic_id
# Returns: 0 if marked complete, 1 if not
is_epic_marked_complete() {
    local progress_file=$1
    local epic_id=$2

    local complete=$(yq ".milestones[].epics[] | select(.id == \"$epic_id\") | .complete" "$progress_file")
    [ "$complete" = "true" ]
}

# Get all epic IDs for a specific milestone
# Args: progress_file_path milestone_id
# Returns: space-separated list of epic IDs belonging to this milestone
get_milestone_epics() {
    local progress_file=$1
    local milestone_id=$2

    yq ".milestones[] | select(.id == \"$milestone_id\") | .epics[].id" "$progress_file" | tr '\n' ' ' | xargs
}

# Check if all epics in a milestone are complete
# Args: progress_file_path milestone_id
# Returns: 0 if all complete, 1 if any incomplete
is_milestone_complete() {
    local progress_file=$1
    local milestone_id=$2

    local milestone_epics=$(get_milestone_epics "$progress_file" "$milestone_id")

    # If no epics, milestone is not complete
    [ -z "$milestone_epics" ] && return 1

    # Check if all epics are complete (all tasks done AND epic marked complete)
    for epic_id in $milestone_epics; do
        if ! is_epic_complete "$progress_file" "$epic_id"; then
            return 1
        fi
        if ! is_epic_marked_complete "$progress_file" "$epic_id"; then
            return 1
        fi
    done

    return 0
}

# Mark milestone as completed in progress file
# Args: progress_file_path milestone_id
# Example: mark_milestone_complete "fluxid/progress.yaml" "m01"
mark_milestone_complete() {
    local progress_file=$1
    local milestone_id=$2

    yq -i "(.milestones[] | select(.id == \"$milestone_id\") | .complete) = true" "$progress_file"
}

# Check if milestone is marked complete in progress file
# Args: progress_file_path milestone_id
# Returns: 0 if marked complete, 1 if not
is_milestone_marked_complete() {
    local progress_file=$1
    local milestone_id=$2

    local complete=$(yq ".milestones[] | select(.id == \"$milestone_id\") | .complete" "$progress_file")
    [ "$complete" = "true" ]
}
