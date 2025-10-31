#!/bin/bash

# Lint: Avoid await on Future constructors
# Detects await Future(...) patterns in tests

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

echo -e "${YELLOW}  Checking for await Future constructors...${NC}"

for file in $STAGED_FILES; do
    if grep -n "await Future(" "$file" | grep -v "Future.delayed" | grep -v "Future.value" > /dev/null 2>&1; then
        line_nums=$(grep -n "await Future(" "$file" | grep -v "Future.delayed" | grep -v "Future.value" | cut -d: -f1)
        if [ -n "$line_nums" ]; then
            echo -e "${RED}  ✗ ${file}${NC}"
            echo -e "    await Future() at line(s): ${line_nums}"
            echo -e "    ${YELLOW}Use tester.pump() to advance time instead${NC}"
            FAILED=1
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  await Future constructor detected${NC}"
    exit 1
fi

exit 0
