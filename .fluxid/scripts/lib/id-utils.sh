#!/bin/bash

# id-utils.sh
# fluxid ID extraction and manipulation utilities
# Requires: none (standalone)

# ============================================================
# ID EXTRACTION
# ============================================================

# Extract ID from YAML frontmatter
# Args: file_path
# Returns: ID value from frontmatter (e.g., "m01", "m01-e02", "m01-e02-t03")
get_id_from_frontmatter() {
    local file=$1
    # Extract the id: field from YAML frontmatter
    grep -A 1 '^---$' "$file" | grep '^id:' | sed 's/^id: *//' | tr -d ' '
}

# Extract ID from filename using regex pattern
# More efficient than parsing frontmatter - use when filename follows convention
# Args: filename or filepath
# Returns: ID extracted from filename (e.g., "m01-e02-t03")
# Examples:
#   m01-browse-flyers.md -> m01
#   m01-e02-location.md -> m01-e02
#   m01-e02-t03-implement-api.md -> m01-e02-t03
extract_id_from_filename() {
    local filename=$(basename "$1" .md)

    # Try to extract task ID first (most specific)
    local task_id=$(echo "$filename" | grep -oE "^m[0-9]+-e[0-9]+-t[0-9]+")
    if [ -n "$task_id" ]; then
        echo "$task_id"
        return
    fi

    # Try epic ID
    local epic_id=$(echo "$filename" | grep -oE "^m[0-9]+-e[0-9]+")
    if [ -n "$epic_id" ]; then
        echo "$epic_id"
        return
    fi

    # Try milestone ID
    local milestone_id=$(echo "$filename" | grep -oE "^m[0-9]+")
    if [ -n "$milestone_id" ]; then
        echo "$milestone_id"
        return
    fi

    # No ID found
    return 1
}

# Get ID from file (tries filename first, then frontmatter)
# Most efficient approach - filename parsing is faster than file I/O
# Args: file_path
# Returns: ID value
get_id() {
    local file=$1

    # Try filename first (faster)
    local id=$(extract_id_from_filename "$file")
    if [ -n "$id" ]; then
        echo "$id"
        return
    fi

    # Fall back to frontmatter
    get_id_from_frontmatter "$file"
}

# ============================================================
# ID VALIDATION
# ============================================================

# Check if string is a valid milestone ID
# Args: id_string
# Returns: 0 if valid, 1 if invalid
is_milestone_id() {
    local id=$1
    [[ "$id" =~ ^m[0-9]+$ ]]
}

# Check if string is a valid epic ID
# Args: id_string
# Returns: 0 if valid, 1 if invalid
is_epic_id() {
    local id=$1
    [[ "$id" =~ ^m[0-9]+-e[0-9]+$ ]]
}

# Check if string is a valid task ID
# Args: id_string
# Returns: 0 if valid, 1 if invalid
is_task_id() {
    local id=$1
    [[ "$id" =~ ^m[0-9]+-e[0-9]+-t[0-9]+$ ]]
}

# ============================================================
# ID RELATIONSHIPS
# ============================================================

# Extract milestone ID from epic or task ID
# Args: epic_or_task_id (e.g., "m01-e02" or "m01-e02-t03")
# Returns: milestone_id (e.g., "m01")
get_milestone_from_id() {
    local id=$1
    echo "$id" | grep -oE "^m[0-9]+"
}

# Extract epic ID from task ID
# Args: task_id (e.g., "m01-e02-t03")
# Returns: epic_id (e.g., "m01-e02")
get_epic_from_task_id() {
    local id=$1
    echo "$id" | grep -oE "^m[0-9]+-e[0-9]+"
}

# Check if epic belongs to milestone
# Args: epic_id milestone_id
# Returns: 0 if belongs, 1 if not
epic_belongs_to_milestone() {
    local epic_id=$1
    local milestone_id=$2
    [[ "$epic_id" == ${milestone_id}-e* ]]
}

# Check if task belongs to epic
# Args: task_id epic_id
# Returns: 0 if belongs, 1 if not
task_belongs_to_epic() {
    local task_id=$1
    local epic_id=$2
    [[ "$task_id" == ${epic_id}-t* ]]
}

# Check if task is the first task of its epic
# Args: task_id (e.g., "m01-e05-t01")
# Returns: 0 if first task (t01), 1 if not
is_first_task_of_epic() {
    local task_id=$1
    [[ "$task_id" =~ -t01$ ]]
}

# Check if task is the first task of the first epic in its milestone
# Args: task_id (e.g., "m01-e01-t01")
# Returns: 0 if pattern matches m*-e01-t01, 1 if not
is_first_task_of_first_epic() {
    local task_id=$1
    [[ "$task_id" =~ ^m[0-9]+-e01-t01$ ]]
}
