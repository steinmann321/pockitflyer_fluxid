#!/bin/bash

# workflow.sh
# Workflow execution utilities for fluxid scripts
# Requires: common.sh

# ============================================================
# WORKFLOW EXECUTION
# ============================================================

# Execute a workflow step with timing and error handling
# Args: step_number step_name command expected_output
# Uses global: DRY_RUN, STREAMING_SCRIPT, STEP_START_TIME, STEP_END_TIME
execute_step() {
    local step_number=$1
    local step_name=$2
    local command=$3
    local expected_output=$4

    echo ""
    echo "=============================================================="
    log_info "Step $step_number: $step_name"
    echo "=============================================================="
    echo ""

    # Start step timer
    STEP_START_TIME=$(get_timestamp)
    log_info "Step start time: $(get_time_string)"
    echo ""

    # Execute command using streaming wrapper
    log_info "Command: $command"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "Would execute: $STREAMING_SCRIPT \"$command\""
        echo ""
        log_dryrun "Skipping actual execution (dry-run mode)"

        # Show what would be created
        if [ -n "$expected_output" ]; then
            echo ""
            log_dryrun "Would create output: $expected_output"
        fi

        # Simulate success
        step_success=0
    else
        step_success=0
        $STREAMING_SCRIPT "$command" || step_success=$?
    fi

    # End step timer
    STEP_END_TIME=$(get_timestamp)

    if [ $step_success -eq 0 ]; then
        echo ""
        if [ "$DRY_RUN" = true ]; then
            log_dryrun "Step would complete successfully"
        else
            log_success "Step completed successfully"
        fi

        # Display step timing
        display_timing $STEP_START_TIME $STEP_END_TIME "STEP $step_number TIMING"

        # Show what was created
        if [ "$DRY_RUN" = false ] && [ -n "$expected_output" ]; then
            echo ""
            log_info "Created output: $expected_output"

            # Count files if it's a directory
            if [ -d "$expected_output" ]; then
                local file_count=$(count_files "$expected_output")
                log_info "Files created: $file_count"
            fi
        fi

        return 0
    else
        echo ""
        log_error "Step failed (exit code: $step_success)"

        # Display step timing even on failure
        display_timing $STEP_START_TIME $STEP_END_TIME "STEP $step_number TIMING (FAILED)"

        return 1
    fi
}

# Run Claude streaming command
# This is a placeholder for future refactoring if streaming logic needs to move here
# Currently, scripts call $STREAMING_SCRIPT directly
run_claude_streaming() {
    local command=$1
    $STREAMING_SCRIPT "$command"
}
