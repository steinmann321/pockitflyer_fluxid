#!/bin/bash

# create-milestones.sh
# Creates milestones from refined product analysis
#
# Usage:
#   ./create-milestones.sh           # Normal execution
#   ./create-milestones.sh --dry-run # Dry run mode

set -e  # Exit on error

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
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
            echo "Creates milestones from refined product analysis."
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be executed without running Claude"
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
PRODUCT_FILE="fluxid/product/refined-product-analysis.md"
MILESTONES_DIR="fluxid/milestones"
STREAMING_SCRIPT="./.fluxid/scripts/run-claude-streaming.sh"

# Timing variables
WORKFLOW_START_TIME=""
WORKFLOW_END_TIME=""

# Main workflow
main() {
    print_box_header "fluxid Milestone Creation"
    log_info "Product → Milestones"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "Running in DRY-RUN mode - no Claude commands will be executed"
        echo ""
    fi

    # Start workflow timer
    WORKFLOW_START_TIME=$(get_timestamp)
    log_info "Start time: $(get_time_string)"
    echo ""

    # Verify prerequisites
    log_info "Verifying prerequisites..."

    if [ ! -f "$PRODUCT_FILE" ]; then
        log_error "Product file not found: $PRODUCT_FILE"
        log_error "Please run /fluxid.create-product first"
        exit 1
    fi

    log_success "Product file found: $PRODUCT_FILE"

    if [ ! -f "$STREAMING_SCRIPT" ]; then
        log_error "Streaming script not found: $STREAMING_SCRIPT"
        exit 1
    fi

    log_success "Streaming script found"

    # Create directory if it doesn't exist
    mkdir -p "$MILESTONES_DIR"
    log_success "Milestone directory verified"
    echo ""

    # Check if milestones already exist
    milestone_count=$(count_files "$MILESTONES_DIR" "m*.md")
    if [ "$milestone_count" -gt 0 ]; then
        log_warning "Found $milestone_count existing milestone(s)"
        log_info "Milestones will be reviewed and potentially updated"
        echo ""
    fi

    # Create milestones
    echo "=============================================================="
    log_info "Creating Milestones from Product Analysis"
    echo "=============================================================="
    echo ""

    log_info "Command: /fluxid.create-milestones"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        log_dryrun "Would execute: $STREAMING_SCRIPT \"/fluxid.create-milestones\""
        echo ""
        log_dryrun "Skipping actual execution (dry-run mode)"
        log_dryrun "Would create output: $MILESTONES_DIR"
        step_success=0
    else
        step_success=0
        $STREAMING_SCRIPT "/fluxid.create-milestones" || step_success=$?

        if [ $step_success -ne 0 ]; then
            log_error "Failed to create milestones"
            exit 1
        fi

        # Validate each created milestone with review loop
        echo ""
        echo "=============================================================="
        log_info "Validating Created Milestones"
        echo "=============================================================="
        echo ""

        milestone_files=($(ls "$MILESTONES_DIR"/m*.md 2>/dev/null | sort))
        if [ ${#milestone_files[@]} -eq 0 ]; then
            log_warning "No milestone files found to validate"
        else
            for milestone_file in "${milestone_files[@]}"; do
                validate_file_with_review_loop "$milestone_file" "fluxid.validate-milestone" "milestone"
                echo ""
            done
            log_success "All milestone validations passed"
        fi
    fi

    # End workflow timer
    WORKFLOW_END_TIME=$(get_timestamp)

    echo ""
    if [ "$DRY_RUN" = true ]; then
        log_dryrun "Milestone creation would complete successfully"
    else
        log_success "Milestone creation completed successfully"
    fi

    # Count final milestones
    milestone_count=$(count_files "$MILESTONES_DIR" "m*.md")
    echo ""
    log_info "Summary:"
    if [ "$DRY_RUN" = true ]; then
        log_info "  Milestones: ${milestone_count:-0} (existing - would process)"
    else
        log_info "  Milestones: $milestone_count"
    fi
    echo ""

    # Display total timing
    display_timing $WORKFLOW_START_TIME $WORKFLOW_END_TIME "TOTAL WORKFLOW TIMING"

    echo ""
    if [ "$DRY_RUN" = true ]; then
        log_info "This was a dry-run. No actual changes were made."
        log_info "Run without --dry-run to execute for real."
    else
        print_box_header "Next Steps"
        log_info "1. Review created milestones in: $MILESTONES_DIR/"
        log_info "2. Edit milestones if needed to refine scope and priorities"
        log_info "3. Run: .fluxid/scripts/create-epics-and-tasks.sh"
        log_info "   This will create epics and tasks for all milestones"
    fi
    echo ""
}

# Handle Ctrl+C gracefully
trap 'echo ""; log_warning "Workflow interrupted by user"; exit 130' INT TERM

# Run main
main
