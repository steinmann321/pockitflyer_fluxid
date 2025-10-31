#!/bin/bash

# Lint: Avoid NetworkImage in tests
# Detects NetworkImage usage which causes flaky/hanging tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/(test|integration_test)/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for NetworkImage in tests...${NC}"

for file in $STAGED_FILES; do
    if grep -n "NetworkImage(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -n "NetworkImage(" "$file" | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    NetworkImage at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use: Image.memory(Uint8List(0)) or Image.asset()${NC}"
        echo -e "    ${YELLOW}Why: NetworkImage causes hanging tests (HTTP 400 in test env)${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  NetworkImage in tests detected${NC}"
    exit 1
fi

exit 0
