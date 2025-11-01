#!/bin/bash

# git-sync.sh
# Git branch synchronization utilities for fluxid scripts
#
# Functions to ensure local and remote branches are in sync before
# executing automated workflows.
#
# Sync Check Policy:
# - Only performed when starting the FIRST task of the FIRST epic in any milestone
# - Pattern: m*-e01-t01 (e.g., m01-e01-t01, m02-e01-t01, m03-e01-t01)
# - Skipped for all other tasks to allow interrupted runs to resume
# - Skipped in review mode

# Check if remote branch exists
# Args: branch_name
# Returns: 0 if exists, 1 if not
remote_branch_exists() {
    local branch_name="$1"

    if [ -z "$branch_name" ]; then
        log_error "remote_branch_exists: branch_name is required"
        return 2
    fi

    # Check if remote branch exists
    if git ls-remote --heads origin "$branch_name" | grep -q "refs/heads/$branch_name"; then
        return 0
    else
        return 1
    fi
}

# Get current branch name
get_current_branch() {
    git branch --show-current
}

# Ensure remote branch exists and is in sync with local
# Creates remote branch if it doesn't exist (via Claude to handle pre-commit hooks)
# Verifies local and remote are in sync if it does exist
# Args: streaming_script (path to Claude streaming wrapper)
# Returns: 0 on success, 1 on error
ensure_remote_branch_sync() {
    local streaming_script="$1"
    local current_branch=$(get_current_branch)

    if [ -z "$current_branch" ]; then
        log_error "Not on a branch (detached HEAD?)"
        return 1
    fi

    if [ -z "$streaming_script" ]; then
        log_error "ensure_remote_branch_sync: streaming_script path is required"
        return 1
    fi

    log_info "Checking remote branch sync for: $current_branch"

    # Check if remote branch exists
    if remote_branch_exists "$current_branch"; then
        log_info "Remote branch exists, checking sync status..."

        # Fetch latest from remote
        if ! git fetch origin "$current_branch" 2>/dev/null; then
            log_warning "Could not fetch from remote, continuing anyway..."
        fi

        # Check if local is ahead, behind, or diverged
        local local_commit=$(git rev-parse HEAD)
        local remote_commit=$(git rev-parse "origin/$current_branch" 2>/dev/null)

        if [ -z "$remote_commit" ]; then
            log_warning "Could not find remote tracking branch"
            log_info "Will set up tracking via Claude (to handle any pre-commit hooks)..."
            echo ""

            push_success=0
            $streaming_script "Push current branch to remote with upstream tracking: git push -u origin $current_branch. Fix any pre-commit hook failures." || push_success=$?

            if [ $push_success -ne 0 ]; then
                echo ""
                log_error "Failed to push and set up tracking"
                return 1
            fi

            echo ""
            log_success "Branch tracking set up successfully"
            return 0
        fi

        if [ "$local_commit" = "$remote_commit" ]; then
            log_success "Local and remote branches are in sync"
            return 0
        fi

        # Check ahead/behind status
        local ahead=$(git rev-list --count "origin/$current_branch..HEAD" 2>/dev/null || echo "0")
        local behind=$(git rev-list --count "HEAD..origin/$current_branch" 2>/dev/null || echo "0")

        if [ "$behind" -gt 0 ] && [ "$ahead" -gt 0 ]; then
            log_error "Branch has diverged from remote ($ahead ahead, $behind behind)"
            log_error "Please resolve manually before continuing"
            return 1
        elif [ "$behind" -gt 0 ]; then
            log_error "Branch is $behind commits behind remote"
            log_error "Please pull changes before continuing: git pull origin $current_branch"
            return 1
        elif [ "$ahead" -gt 0 ]; then
            log_info "Branch is $ahead commits ahead of remote"
            log_info "Will push changes at milestone completion"
            return 0
        fi
    else
        log_info "Remote branch does not exist, will create via Claude (to handle any pre-commit hooks)..."
        echo ""

        push_success=0
        $streaming_script "Push current branch to remote with upstream tracking: git push -u origin $current_branch. Fix any pre-commit hook failures." || push_success=$?

        if [ $push_success -ne 0 ]; then
            echo ""
            log_error "Failed to create remote branch"
            return 1
        fi

        echo ""
        log_success "Remote branch created and tracking set up"
        return 0
    fi

    return 0
}

# Push all changes to remote (used at milestone completion)
# Uses Claude to handle push so pre-commit hooks can be fixed automatically
# Args: streaming_script (path to Claude streaming wrapper)
# Returns: 0 on success, 1 on error
push_to_remote() {
    local streaming_script="$1"
    local current_branch=$(get_current_branch)

    if [ -z "$current_branch" ]; then
        log_error "Not on a branch (detached HEAD?)"
        return 1
    fi

    if [ -z "$streaming_script" ]; then
        log_error "push_to_remote: streaming_script path is required"
        return 1
    fi

    log_info "Pushing changes to remote via Claude (to handle any pre-commit hooks)..."

    # Check if branch has upstream configured
    if ! git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
        log_info "No upstream configured, will use: git push -u origin $current_branch"
        push_cmd="git push -u origin $current_branch"
    else
        push_cmd="git push"
    fi

    push_success=0
    $streaming_script "Push all changes to remote: $push_cmd. Fix any pre-commit hook failures." || push_success=$?

    if [ $push_success -ne 0 ]; then
        log_error "Push failed"
        return 1
    fi

    log_success "Changes pushed successfully"
    return 0
}

# Verify that local branch is not ahead of remote
# Used after push to confirm success
# Args: none (uses current branch)
# Returns: 0 if in sync, 1 if ahead
verify_push_success() {
    local current_branch=$(get_current_branch)

    if [ -z "$current_branch" ]; then
        log_error "Not on a branch (detached HEAD?)"
        return 1
    fi

    # Check git status for "ahead" indication
    if git status | grep -q "Your branch is ahead"; then
        return 1
    fi

    return 0
}

# Create snapshot branch after epic completion
# Creates a branch named: <current-branch>-snapshot-YYYYMMDD-HHMMSS
# Args: none (uses current branch)
# Returns: 0 on success, 1 on error
create_epic_snapshot_branch() {
    local current_branch=$(get_current_branch)

    if [ -z "$current_branch" ]; then
        log_error "Not on a branch (detached HEAD?)"
        return 1
    fi

    # Generate timestamp in format: YYYYMMDD-HHMMSS
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local snapshot_branch="${current_branch}-snapshot-${timestamp}"

    log_info "Creating snapshot branch: $snapshot_branch"

    # Create the snapshot branch (just creates the ref, doesn't switch to it)
    if git branch "$snapshot_branch" 2>/dev/null; then
        log_success "Snapshot branch created: $snapshot_branch"
        return 0
    else
        log_error "Failed to create snapshot branch: $snapshot_branch"
        return 1
    fi
}
