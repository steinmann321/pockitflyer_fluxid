#!/bin/bash

# Lint: ScrollController with hardcoded animation duration
# Detects literal Duration in animateTo

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

echo -e "${YELLOW}  Checking for ScrollController with hardcoded duration...${NC}"

for file in $STAGED_FILES; do
    # Check for animateTo with duration: Duration(
    # Match: scrollController.animateTo(..., duration: Duration(...), ...)
    if grep -nE "animateTo\([^)]*duration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "animateTo\([^)]*duration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    ScrollController.animateTo with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.scrollAnimationDuration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  ScrollController with hardcoded duration detected${NC}"
    echo -e "${YELLOW}  Why: Makes scroll animation tests flaky, durations should be configurable${NC}"
    exit 1
fi

exit 0
