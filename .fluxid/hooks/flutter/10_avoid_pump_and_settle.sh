#!/bin/bash

# Lint: Avoid pumpAndSettle in tests
# Detects usage of pumpAndSettle() which causes flaky tests

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

echo -e "${YELLOW}  Checking for pumpAndSettle()...${NC}"

for file in $STAGED_FILES; do
    if grep -n "pumpAndSettle()" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -n "pumpAndSettle()" "$file" | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    pumpAndSettle() at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use: await tester.pump() with explicit Duration instead${NC}"
        echo -e "    ${YELLOW}Why: pumpAndSettle() causes flaky tests with async ops${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  pumpAndSettle() detected${NC}"
    exit 1
fi

exit 0
