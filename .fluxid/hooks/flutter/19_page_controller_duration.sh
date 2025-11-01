#!/bin/bash

# Lint: PageController with hardcoded animation duration
# Detects literal Duration in animateToPage, nextPage, previousPage

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/lib/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for PageController with hardcoded duration...${NC}"

for file in $STAGED_FILES; do
    # Check for animateToPage with duration: Duration(
    if grep -nE "animateToPage\([^)]*duration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "animateToPage\([^)]*duration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    animateToPage with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.pageTransitionDuration instead${NC}"
        FAILED=1
    fi

    # Check for nextPage with duration: Duration(
    if grep -nE "nextPage\([^)]*duration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "nextPage\([^)]*duration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    nextPage with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.pageTransitionDuration instead${NC}"
        FAILED=1
    fi

    # Check for previousPage with duration: Duration(
    if grep -nE "previousPage\([^)]*duration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "previousPage\([^)]*duration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    previousPage with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.pageTransitionDuration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  PageController with hardcoded duration detected${NC}"
    echo -e "${YELLOW}  Why: Makes carousel/swipe tests flaky, durations should be configurable${NC}"
    exit 1
fi

exit 0
