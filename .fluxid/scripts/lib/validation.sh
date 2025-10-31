#!/bin/bash

# validation.sh
# Shared validation functions for fluxid workflow scripts
#
# Provides reusable validation with review loop pattern:
# 1. Run validation command
# 2. Parse validation report for Status field (PASS or FAIL)
# 3. If FAIL: fix issues and retry (max iterations)
# 4. Cleanup review files on success
#
# Validation reports use template: .fluxid/templates/validation-report-template.md
# Report must include Summary section with:
#   - **Status**: PASS or FAIL
#   - **Total Checks**: [count]
#   - **Passed**: [count]
#   - **Failed**: [count]
#   - **Warnings**: [count]
#
# Usage:
#   source "$SCRIPT_DIR/lib/validation.sh"
#   validate_file_with_review_loop "$file" "fluxid.validate-milestone" "milestone"

# Configuration
VALIDATION_REVIEW_FILE="fluxid-validate-review.md"
STRUCTURE_REVIEW_FILE="fluxid-structure-review.md"
BATCH_VALIDATION_REVIEW_FILE="fluxid-batch-validate-review.md"
DEFAULT_MAX_ITERATIONS=3

# Generic file validation with review loop
# Args:
#   $1 - file_path: Path to file to validate
#   $2 - validation_command: Validation command name (e.g., "fluxid.validate-milestone")
#   $3 - type_name: Human-readable type for logging (e.g., "milestone", "epic", "task")
#   $4 - max_iterations (optional): Max retry iterations (default: 3)
validate_file_with_review_loop() {
    local file_path="$1"
    local validation_command="$2"
    local type_name="$3"
    local max_iterations="${4:-$DEFAULT_MAX_ITERATIONS}"
    local iteration=0

    local basename_file=$(basename "$file_path")
    log_info "Validating $type_name: $basename_file"

    while [ $iteration -lt $max_iterations ]; do
        iteration=$((iteration + 1))

        # Run validation command
        validation_success=0
        $STREAMING_SCRIPT "Read and execute validation from .fluxid/commands/$validation_command.md for file: $file_path. Write validation report to $VALIDATION_REVIEW_FILE using template .fluxid/templates/validation-report-template.md. Set Status to PASS or FAIL." || validation_success=$?

        if [ $validation_success -ne 0 ]; then
            log_error "Validation command failed"
            return 1
        fi

        # Check if review file was created
        if [ ! -f "$VALIDATION_REVIEW_FILE" ]; then
            log_error "Validation failed - no review file created"
            return 1
        fi

        # Parse validation status from report
        local validation_status=$(grep -E "^- \*\*Status\*\*:" "$VALIDATION_REVIEW_FILE" | sed 's/.*: *//' | tr -d ' ')

        if [ -z "$validation_status" ]; then
            log_error "Could not parse validation status from review file"
            log_info "Review preserved at: $VALIDATION_REVIEW_FILE"
            return 1
        fi

        # Check if validation passed
        if [ "$validation_status" = "PASS" ]; then
            log_success "Validation passed!"

            # Show summary stats
            local total_checks=$(grep -E "^- \*\*Total Checks\*\*:" "$VALIDATION_REVIEW_FILE" | sed 's/.*: *//')
            local passed=$(grep -E "^- \*\*Passed\*\*:" "$VALIDATION_REVIEW_FILE" | sed 's/.*: *//')
            local warnings=$(grep -E "^- \*\*Warnings\*\*:" "$VALIDATION_REVIEW_FILE" | sed 's/.*: *//')

            if [ -n "$total_checks" ]; then
                log_info "Checks: $passed/$total_checks passed$([ "$warnings" != "0" ] && echo ", $warnings warnings" || echo "")"
            fi

            rm -f "$VALIDATION_REVIEW_FILE"
            return 0
        fi

        # Validation failed - attempt to fix
        log_warning "Validation status: $validation_status (iteration $iteration/$max_iterations)"

        fix_success=0
        $STREAMING_SCRIPT "Fix validation issues from $VALIDATION_REVIEW_FILE for $file_path" || fix_success=$?

        if [ $fix_success -ne 0 ]; then
            log_error "Failed to fix validation issues"
            log_info "Review preserved at: $VALIDATION_REVIEW_FILE"
            return 1
        fi

        log_success "Issues fixed"
        rm -f "$VALIDATION_REVIEW_FILE"

        # Loop again to re-validate
    done

    # Max iterations reached
    log_warning "Max validation iterations ($max_iterations) reached for $basename_file"
    log_info "Review preserved at: $VALIDATION_REVIEW_FILE"
    return 1
}

# Structural validation with review loop (cross-file validation)
# Args:
#   $1 - milestone_id: Milestone ID to validate (e.g., "m01")
#   $2 - max_iterations (optional): Max retry iterations (default: 3)
validate_structure() {
    local milestone_id="$1"
    local max_iterations="${2:-$DEFAULT_MAX_ITERATIONS}"
    local iteration=0

    log_info "Validating structure for milestone: $milestone_id"

    while [ $iteration -lt $max_iterations ]; do
        iteration=$((iteration + 1))

        # Run structural validation
        validation_success=0
        $STREAMING_SCRIPT "Read and execute structural validation from .fluxid/commands/fluxid.validate-structure.md for milestone: $milestone_id. Write validation report to $STRUCTURE_REVIEW_FILE using template .fluxid/templates/validation-report-template.md. Set Status to PASS or FAIL." || validation_success=$?

        if [ $validation_success -ne 0 ]; then
            log_error "Structural validation command failed"
            return 1
        fi

        # Check if review file was created
        if [ ! -f "$STRUCTURE_REVIEW_FILE" ]; then
            log_error "Structural validation failed - no review file created"
            return 1
        fi

        # Parse validation status from report
        local validation_status=$(grep -E "^- \*\*Status\*\*:" "$STRUCTURE_REVIEW_FILE" | sed 's/.*: *//' | tr -d ' ')

        if [ -z "$validation_status" ]; then
            log_error "Could not parse validation status from review file"
            log_info "Review preserved at: $STRUCTURE_REVIEW_FILE"
            return 1
        fi

        # Check if validation passed
        if [ "$validation_status" = "PASS" ]; then
            log_success "Structural validation passed!"

            # Show summary stats
            local total_checks=$(grep -E "^- \*\*Total Checks\*\*:" "$STRUCTURE_REVIEW_FILE" | sed 's/.*: *//')
            local passed=$(grep -E "^- \*\*Passed\*\*:" "$STRUCTURE_REVIEW_FILE" | sed 's/.*: *//')
            local warnings=$(grep -E "^- \*\*Warnings\*\*:" "$STRUCTURE_REVIEW_FILE" | sed 's/.*: *//')

            if [ -n "$total_checks" ]; then
                log_info "Checks: $passed/$total_checks passed$([ "$warnings" != "0" ] && echo ", $warnings warnings" || echo "")"
            fi

            rm -f "$STRUCTURE_REVIEW_FILE"
            return 0
        fi

        # Validation failed - attempt to fix
        log_warning "Structural validation status: $validation_status (iteration $iteration/$max_iterations)"

        fix_success=0
        $STREAMING_SCRIPT "Fix structural validation issues from $STRUCTURE_REVIEW_FILE for milestone $milestone_id" || fix_success=$?

        if [ $fix_success -ne 0 ]; then
            log_error "Failed to fix structural validation issues"
            log_info "Review preserved at: $STRUCTURE_REVIEW_FILE"
            return 1
        fi

        log_success "Structural issues fixed"
        rm -f "$STRUCTURE_REVIEW_FILE"

        # Loop again to re-validate
    done

    # Max iterations reached
    log_warning "Max structural validation iterations ($max_iterations) reached for $milestone_id"
    log_info "Review preserved at: $STRUCTURE_REVIEW_FILE"
    return 1
}

# Batch validation for multiple files in a single Claude session
# Args:
#   $1 - validation_command: Validation command name (e.g., "fluxid.validate-epic")
#   $2 - type_name: Human-readable type for logging (e.g., "epic", "task")
#   $3+ - file_paths: Paths to files to validate
# Returns: 0 if all pass, 1 if any fail
validate_batch_with_review_loop() {
    local validation_command="$1"
    local type_name="$2"
    shift 2
    local file_paths=("$@")
    local max_iterations="${DEFAULT_MAX_ITERATIONS}"
    local iteration=0

    if [ ${#file_paths[@]} -eq 0 ]; then
        log_warning "No files provided for batch validation"
        return 0
    fi

    log_info "Batch validating ${#file_paths[@]} ${type_name}(s)"

    while [ $iteration -lt $max_iterations ]; do
        iteration=$((iteration + 1))

        # Build file list for prompt
        local file_list=""
        for file_path in "${file_paths[@]}"; do
            file_list="$file_list- $file_path\n"
        done

        # Run batch validation command
        validation_success=0
        $STREAMING_SCRIPT "Read and execute validation from .fluxid/commands/$validation_command.md for ALL of these files:\n${file_list}\nWrite a SINGLE validation report to $BATCH_VALIDATION_REVIEW_FILE using template .fluxid/templates/validation-report-template.md. Include a section for EACH file with its individual Status (PASS/FAIL). At the top, include an overall Summary with overall Status (PASS only if ALL files pass, FAIL if ANY file fails)." || validation_success=$?

        if [ $validation_success -ne 0 ]; then
            log_error "Batch validation command failed"
            return 1
        fi

        # Check if review file was created
        if [ ! -f "$BATCH_VALIDATION_REVIEW_FILE" ]; then
            log_error "Batch validation failed - no review file created"
            return 1
        fi

        # Parse overall validation status
        local validation_status=$(grep -E "^- \*\*Status\*\*:" "$BATCH_VALIDATION_REVIEW_FILE" | head -1 | sed 's/.*: *//' | tr -d ' ')

        if [ -z "$validation_status" ]; then
            log_error "Could not parse validation status from batch review file"
            log_info "Review preserved at: $BATCH_VALIDATION_REVIEW_FILE"
            return 1
        fi

        # Check if validation passed
        if [ "$validation_status" = "PASS" ]; then
            log_success "Batch validation passed!"

            # Show summary stats
            local total_checks=$(grep -E "^- \*\*Total Checks\*\*:" "$BATCH_VALIDATION_REVIEW_FILE" | head -1 | sed 's/.*: *//')
            local passed=$(grep -E "^- \*\*Passed\*\*:" "$BATCH_VALIDATION_REVIEW_FILE" | head -1 | sed 's/.*: *//')
            local failed=$(grep -E "^- \*\*Failed\*\*:" "$BATCH_VALIDATION_REVIEW_FILE" | head -1 | sed 's/.*: *//')
            local warnings=$(grep -E "^- \*\*Warnings\*\*:" "$BATCH_VALIDATION_REVIEW_FILE" | head -1 | sed 's/.*: *//')

            if [ -n "$total_checks" ]; then
                log_info "Checks: $passed/$total_checks passed$([ "$warnings" != "0" ] && echo ", $warnings warnings" || echo "")"
            fi

            log_info "All ${#file_paths[@]} ${type_name}(s) validated successfully"

            rm -f "$BATCH_VALIDATION_REVIEW_FILE"
            return 0
        fi

        # Validation failed - attempt to fix
        log_warning "Batch validation status: $validation_status (iteration $iteration/$max_iterations)"

        # Build file list for fix prompt
        local failed_files=$(grep -B 2 "Status\*\*: FAIL" "$BATCH_VALIDATION_REVIEW_FILE" | grep "File\*\*:" | sed 's/.*: *//')

        fix_success=0
        $STREAMING_SCRIPT "Fix validation issues from $BATCH_VALIDATION_REVIEW_FILE. Focus on files that failed: $failed_files" || fix_success=$?

        if [ $fix_success -ne 0 ]; then
            log_error "Failed to fix batch validation issues"
            log_info "Review preserved at: $BATCH_VALIDATION_REVIEW_FILE"
            return 1
        fi

        log_success "Issues fixed"
        rm -f "$BATCH_VALIDATION_REVIEW_FILE"

        # Loop again to re-validate
    done

    # Max iterations reached
    log_warning "Max batch validation iterations ($max_iterations) reached"
    log_info "Review preserved at: $BATCH_VALIDATION_REVIEW_FILE"
    return 1
}

# Cleanup all validation review files
# Useful for cleanup in trap handlers or final cleanup
cleanup_validation_review_files() {
    local cleaned=0

    if [ -f "$VALIDATION_REVIEW_FILE" ]; then
        rm -f "$VALIDATION_REVIEW_FILE"
        log_info "Cleaned up validation review file: $VALIDATION_REVIEW_FILE"
        cleaned=1
    fi

    if [ -f "$STRUCTURE_REVIEW_FILE" ]; then
        rm -f "$STRUCTURE_REVIEW_FILE"
        log_info "Cleaned up structure review file: $STRUCTURE_REVIEW_FILE"
        cleaned=1
    fi

    if [ -f "$BATCH_VALIDATION_REVIEW_FILE" ]; then
        rm -f "$BATCH_VALIDATION_REVIEW_FILE"
        log_info "Cleaned up batch validation review file: $BATCH_VALIDATION_REVIEW_FILE"
        cleaned=1
    fi

    return $cleaned
}
