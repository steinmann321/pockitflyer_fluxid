#!/bin/bash

# progress.sh
# fluxid progress tracking operations
# Requires: id-utils.sh

# ============================================================
# PROGRESS FILE PARSING
# ============================================================

# Get all task IDs from progress.md
# Args: progress_file_path
# Returns: space-separated list of task IDs (e.g., "m01-e01-t01 m01-e01-t02")
get_task_ids_from_progress() {
    local progress_file=$1
    grep "^  - \[\([ x]\)\] \`m[0-9]\+-e[0-9]\+-t[0-9]\+\`" "$progress_file" | sed 's/^  - \[\([ x]\)\] `\(.*\)`.*/\2/'
}

# Get all task files from progress.md by finding corresponding files in task directory
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

    # Tasks are at 2nd level with backticks: `  - [ ] \`m01-e01-t01\``
    local total=$(grep -c "^  - \[\([ x]\)\] \`m[0-9]\+-e[0-9]\+-t[0-9]\+\`" "$progress_file" 2>/dev/null || echo "0")
    local completed=$(grep -c "^  - \[x\] \`m[0-9]\+-e[0-9]\+-t[0-9]\+\`" "$progress_file" 2>/dev/null || echo "0")

    # Ensure we have valid numbers and remove leading zeros
    total=$(echo "$total" | tr -d '[:space:]' | sed 's/^0*//')
    completed=$(echo "$completed" | tr -d '[:space:]' | sed 's/^0*//')

    # Default to 0 if empty
    total=${total:-0}
    completed=${completed:-0}

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
# Example: mark_task_complete "fluxid/progress.md" "m01-e01-t01"
mark_task_complete() {
    local progress_file=$1
    local task_id=$2

    # Escape special characters for sed
    local escaped_id=$(echo "$task_id" | sed 's/[\/&]/\\&/g')

    # Replace [ ] with [x] for the specific task ID
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed requires -i with extension
        sed -i '' "s/^  - \[ \] \`${escaped_id}\`/  - [x] \`${escaped_id}\`/" "$progress_file"
    else
        # Linux sed
        sed -i "s/^  - \[ \] \`${escaped_id}\`/  - [x] \`${escaped_id}\`/" "$progress_file"
    fi
}

# Mark task as incomplete in progress file (revert completion)
# Args: progress_file_path task_id
mark_task_incomplete() {
    local progress_file=$1
    local task_id=$2

    # Escape special characters for sed
    local escaped_id=$(echo "$task_id" | sed 's/[\/&]/\\&/g')

    # Replace [x] with [ ] for the specific task ID
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^  - \[x\] \`${escaped_id}\`/  - [ ] \`${escaped_id}\`/" "$progress_file"
    else
        sed -i "s/^  - \[x\] \`${escaped_id}\`/  - [ ] \`${escaped_id}\`/" "$progress_file"
    fi
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
    grep -q "^  - \[x\] \`${task_id}\`" "$progress_file"
}

# Check if task exists in progress file
# Args: progress_file_path task_id
# Returns: 0 if exists, 1 if not
task_in_progress() {
    local progress_file=$1
    local task_id=$2
    grep -q "^  - \[\([ x]\)\] \`${task_id}\`" "$progress_file"
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
    grep "^  - \[x\] \`m[0-9]\+-e[0-9]\+-t[0-9]\+\`" "$progress_file" | sed 's/^  - \[x\] `\(.*\)`.*/\1/'
}

# Get list of incomplete task IDs
# Args: progress_file_path
# Returns: space-separated list of incomplete task IDs
get_incomplete_tasks() {
    local progress_file=$1
    grep "^  - \[ \] \`m[0-9]\+-e[0-9]\+-t[0-9]\+\`" "$progress_file" | sed 's/^  - \[ \] `\(.*\)`.*/\1/'
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

    # Escape special characters for grep
    local escaped_epic=$(echo "$epic_id" | sed 's/[\/&]/\\&/g')

    # Find all tasks that start with epic_id-t
    grep "^  - \[\([ x]\)\] \`${escaped_epic}-t[0-9]\+\`" "$progress_file" | sed 's/^  - \[\([ x]\)\] `\(.*\)`.*/\2/'
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

    local epic_tasks=$(get_epic_tasks "$progress_file" "$epic_id")
    local total=0
    local completed=0

    for task_id in $epic_tasks; do
        total=$((total + 1))
        if is_task_complete "$progress_file" "$task_id"; then
            completed=$((completed + 1))
        fi
    done

    if [ $total -eq 0 ]; then
        echo "0"
    else
        echo $((completed * 100 / total))
    fi
}

# Mark epic as completed in progress file
# Args: progress_file_path epic_id
# Example: mark_epic_complete "fluxid/progress.md" "m01-e01"
mark_epic_complete() {
    local progress_file=$1
    local epic_id=$2

    # Escape special characters for sed
    local escaped_id=$(echo "$epic_id" | sed 's/[\/&]/\\&/g')

    # Replace [ ] with [x] for the epic checkbox
    # Supports both formats:
    #   - [ ] **Epic Description (m01-e01)
    #   - [ ] **Epic 05**: Description (m01-e05)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' -E "s/^- \[ \] (\*\*Epic .*(: |\().* \(${escaped_id}\))/- [x] \1/" "$progress_file"
    else
        sed -i -E "s/^- \[ \] (\*\*Epic .*(: |\().* \(${escaped_id}\))/- [x] \1/" "$progress_file"
    fi
}

# Check if epic is marked complete in progress file
# Args: progress_file_path epic_id
# Returns: 0 if marked complete, 1 if not
is_epic_marked_complete() {
    local progress_file=$1
    local epic_id=$2
    # Supports both formats:
    #   - [x] **Epic Description (m01-e01)
    #   - [x] **Epic 05**: Description (m01-e05)
    grep -qE "^- \[x\] \*\*Epic .*(: |\().*\(${epic_id}\)" "$progress_file"
}

# Get all epic IDs for a specific milestone
# Args: progress_file_path milestone_id
# Returns: space-separated list of epic IDs belonging to this milestone
get_milestone_epics() {
    local progress_file=$1
    local milestone_id=$2

    # Escape special characters for grep
    local escaped_milestone=$(echo "$milestone_id" | sed 's/[\/&]/\\&/g')

    # Find all epics that start with milestone_id-e
    # Format supports both:
    #   - [ ] **Epic Description (m01-e01)
    #   - [ ] **Epic 05**: Description (m01-e05)
    grep -E "^- \[[x ]\] \*\*Epic .* \(${escaped_milestone}-e[0-9]+\)|^- \[[x ]\] \*\*Epic [0-9]+\*\*: .* \(${escaped_milestone}-e[0-9]+\)" "$progress_file" | \
        sed -E 's/.*\((m[0-9]+-e[0-9]+)\).*/\1/'
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
# Example: mark_milestone_complete "fluxid/progress.md" "m01"
mark_milestone_complete() {
    local progress_file=$1
    local milestone_id=$2

    # Escape special characters for sed
    local escaped_id=$(echo "$milestone_id" | sed 's/[\/&]/\\&/g')

    # Replace [ ] with [x] for the milestone completion checkbox
    # Format: - [ ] **Milestone XX Complete** - Ship...
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^- \[ \] \*\*Milestone [0-9]\+ Complete\*\*/- [x] **Milestone Complete**/" "$progress_file"
    else
        sed -i "s/^- \[ \] \*\*Milestone [0-9]\+ Complete\*\*/- [x] **Milestone Complete**/" "$progress_file"
    fi
}

# Check if milestone is marked complete in progress file
# Args: progress_file_path milestone_id
# Returns: 0 if marked complete, 1 if not
is_milestone_marked_complete() {
    local progress_file=$1
    local milestone_id=$2

    # Look for the milestone section and check if its completion checkbox is marked
    # The format is: - [x] **Milestone XX Complete** - Ship...
    grep -q "^- \[x\] \*\*Milestone [0-9]\+ Complete\*\*" "$progress_file"
}
