#!/bin/bash

# Lint: Image fade duration
# Detects hardcoded fadeInDuration/fadeOutDuration in FadeInImage

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

echo -e "${YELLOW}  Checking for hardcoded image fade durations...${NC}"

for file in $STAGED_FILES; do
    # Check for fadeInDuration: Duration(
    if grep -nE "fadeInDuration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "fadeInDuration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    fadeInDuration with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.imageFadeInDuration instead${NC}"
        FAILED=1
    fi

    # Check for fadeOutDuration: Duration(
    if grep -nE "fadeOutDuration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "fadeOutDuration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    fadeOutDuration with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.imageFadeOutDuration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Image fade with hardcoded duration detected${NC}"
    echo -e "${YELLOW}  Why: Makes image loading tests flaky, durations should be configurable${NC}"
    exit 1
fi

exit 0
