# fluxid Scripts Library

Modular bash utilities for the fluxid workflow. Target ~300 lines per file.

## Libraries

### `common.sh`
Generic utilities - logging, timing, UI, file ops. No dependencies.
```bash
log_info "msg" | log_success | log_error | log_warning | log_dryrun
print_box_header "title"
countdown N
get_timestamp | get_time_string | display_timing START END "label"
count_files DIR "pattern"
```

### `id-utils.sh`
ID extraction/validation. No dependencies. Filename parsing > file I/O.
```bash
# Extraction
get_id_from_frontmatter FILE    # Parse YAML (slow)
extract_id_from_filename FILE   # Regex (fast)
get_id FILE                     # Smart: filename first, frontmatter fallback

# Validation
is_milestone_id ID | is_epic_id ID | is_task_id ID

# Relationships
get_milestone_from_id ID
get_epic_from_task_id ID
epic_belongs_to_milestone EPIC_ID MS_ID
task_belongs_to_epic TASK_ID EPIC_ID
```

### `progress.sh`
Progress tracking (fluxid/progress.md). Requires: id-utils.sh
```bash
# Parsing
get_task_ids_from_progress PROGRESS_FILE
get_task_files_from_progress PROGRESS_FILE TASKS_DIR
count_progress_tasks PROGRESS_FILE           # "completed/total"
count_progress_tasks_detailed PROGRESS_FILE  # "completed/total (remaining remaining)"

# Modification
mark_task_complete PROGRESS_FILE TASK_ID
mark_task_incomplete PROGRESS_FILE TASK_ID

# Queries
is_task_complete PROGRESS_FILE TASK_ID
task_in_progress PROGRESS_FILE TASK_ID
get_task_status PROGRESS_FILE TASK_ID       # complete/incomplete/not-found
get_completed_tasks PROGRESS_FILE
get_incomplete_tasks PROGRESS_FILE

# Epic/Milestone
get_epic_tasks PROGRESS_FILE EPIC_ID
is_epic_complete PROGRESS_FILE EPIC_ID
get_epic_progress PROGRESS_FILE EPIC_ID     # 0-100%
```

### `fluxid-helpers.sh`
Workflow detection/resume. Requires: common.sh, id-utils.sh
```bash
get_milestones_needing_epics    # Uses globals: MILESTONES_DIR, EPICS_DIR
get_epics_needing_tasks         # Uses globals: EPICS_DIR, TASKS_DIR
detect_resume_point             # Returns: 1=epics, 2=tasks, 3=progress, 4=done
show_resume_info RESUME_STEP
```

### `workflow.sh`
Workflow execution. Requires: common.sh
```bash
execute_step STEP_NUM STEP_NAME COMMAND EXPECTED_OUTPUT
run_claude_streaming COMMAND
# Uses globals: DRY_RUN, STREAMING_SCRIPT
```

## Import Order

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/workflow.sh"
source "$SCRIPT_DIR/lib/id-utils.sh"
source "$SCRIPT_DIR/lib/progress.sh"
source "$SCRIPT_DIR/lib/fluxid-helpers.sh"
```
