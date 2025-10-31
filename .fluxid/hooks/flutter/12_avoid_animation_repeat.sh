#!/bin/bash

# Lint: Avoid AnimationController.repeat
# Detects AnimationController.repeat() which should be disabled in tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/test/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for AnimationController.repeat()...${NC}"

for file in $STAGED_FILES; do
    # Look for .repeat() calls after AnimationController
    if grep -E "controller.*\.repeat\(|_controller.*\.repeat\(|animationController.*\.repeat\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "controller.*\.repeat\(|_controller.*\.repeat\(|animationController.*\.repeat\(" "$file" | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    AnimationController.repeat() at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Disable in test mode or use explicit animation control${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  AnimationController.repeat() in tests detected${NC}"
    exit 1
fi

exit 0
