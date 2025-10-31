#!/bin/bash


# Lint: Enforce input validation
# Ensures all TextFormField widgets have validators

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/(lib|test)/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for missing form validation...${NC}"

for file in $STAGED_FILES; do
    # Skip test files and generated files
    if [[ "$file" =~ _test\.dart$ ]] || [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]]; then
        continue
    fi

    # Check for TextFormField without validator
    if grep -q "TextFormField" "$file"; then
        # Extract TextFormField blocks and check for validator
        line_num=$(grep -n "TextFormField(" "$file" | cut -d: -f1 || true)

        for line in $line_num; do
            # Check if validator exists within next 20 lines
            context=$(sed -n "${line},$((line+20))p" "$file")

            if ! echo "$context" | grep -q "validator:" && ! echo "$context" | grep -q "@allowUnvalidated"; then
                echo -e "${RED}  ✗ ${file}:${line}${NC}"
                echo -e "    TextFormField without validator"
                echo -e "    ${YELLOW}Add: validator: (value) => value?.isEmpty ?? true ? 'Required' : null${NC}"
                echo -e "    ${YELLOW}Or annotate: @allowUnvalidated${NC}"
                FAILED=1
            fi
        done
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Missing form validation detected${NC}"
    echo -e "${YELLOW}  Why: Maestro can't easily test validation edge cases${NC}"
    echo ""
    exit 1
fi

exit 0

