#!/bin/bash

# Lint: Direct timing operations in business logic
# Detects Timer, Future.delayed, Stream.periodic in non-service production code

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

echo -e "${YELLOW}  Checking for direct timing operations...${NC}"

# Exempt service files (contain keywords: service, timer, timing, debounce, throttle)
SERVICE_KEYWORDS="service|timer|timing|debounce|throttle|scheduler|delay"

for file in $STAGED_FILES; do
    # Skip if file is a timing service
    if echo "$file" | grep -iE "$SERVICE_KEYWORDS" > /dev/null 2>&1; then
        continue
    fi

    # Skip if file has timing-allowed comment
    if grep -q "// timing-allowed\|// lint:allow-timing" "$file" 2>/dev/null; then
        continue
    fi

    # Check for Timer, Future.delayed, Stream.periodic
    if grep -nE "Timer\(|Timer\.periodic|Future\.delayed|Stream\.periodic" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "Timer\(|Timer\.periodic|Future\.delayed|Stream\.periodic" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    Direct timing operation at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Encapsulate in a service class instead${NC}"
        echo -e "    ${YELLOW}Or add: // timing-allowed${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Direct timing operations detected${NC}"
    echo -e "${YELLOW}  Why: Hard to test, violates SRP, causes flaky tests${NC}"
    exit 1
fi

exit 0
