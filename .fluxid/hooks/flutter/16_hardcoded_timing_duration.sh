#!/bin/bash

# Lint: Hardcoded Duration in timing operations
# Detects literal Duration in Timer/Future.delayed/Stream.periodic

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

echo -e "${YELLOW}  Checking for hardcoded Duration...${NC}"

SERVICE_KEYWORDS="service|timer|timing|config"

for file in $STAGED_FILES; do
    # Skip service/config files
    if echo "$file" | grep -iE "$SERVICE_KEYWORDS" > /dev/null 2>&1; then
        continue
    fi

    # Check for Timer/Future.delayed/Stream.periodic with Duration(
    if grep -nE "Timer\(.*Duration\(|Future\.delayed\(.*Duration\(|Stream\.periodic\(.*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "Timer\(.*Duration\(|Future\.delayed\(.*Duration\(|Stream\.periodic\(.*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    Hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig duration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Hardcoded Duration in timing operations detected${NC}"
    exit 1
fi

exit 0
