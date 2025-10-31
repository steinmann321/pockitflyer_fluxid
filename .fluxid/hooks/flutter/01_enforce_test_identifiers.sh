#!/bin/bash


# Lint: Enforce test identifiers (key or Semantics)
# Ensures interactive widgets are findable in Maestro tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

# Get staged Dart files
APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/(lib|test)/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for missing keys/semantics...${NC}"

# Interactive widgets that need identification
INTERACTIVE_WIDGETS=(
    "ElevatedButton"
    "TextButton"
    "OutlinedButton"
    "IconButton"
    "FloatingActionButton"
    "TextField"
    "TextFormField"
    "GestureDetector"
    "InkWell"
    "Checkbox"
    "Radio"
    "Switch"
    "Slider"
    "DropdownButton"
)

for file in $STAGED_FILES; do
    # Skip test files and generated files
    if [[ "$file" =~ _test\.dart$ ]] || [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]]; then
        continue
    fi

    for widget in "${INTERACTIVE_WIDGETS[@]}"; do
        # Look for widget declarations without key parameter
        if grep -n "${widget}(" "$file" | grep -v "key:" | grep -v "Key(" | grep -v "Semantics" | grep -v "//" > /dev/null 2>&1; then
            line_nums=$(grep -n "${widget}(" "$file" | grep -v "key:" | grep -v "Key(" | grep -v "Semantics" | grep -v "//" | cut -d: -f1 || true)

            if [ -n "$line_nums" ]; then
                echo -e "${RED}  ✗ ${file}${NC}"
                echo -e "    ${widget} without key or Semantics at line(s): ${line_nums}"
                echo -e "    ${YELLOW}Add: key: Key('unique-identifier')${NC}"
                echo -e "    ${YELLOW}Or wrap with: Semantics(identifier: 'unique-id', ...)${NC}"
                FAILED=1
            fi
        fi
    done
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Missing test identifiers detected${NC}"
    echo -e "${YELLOW}  Why: Maestro can't find widgets without keys or semantic identifiers${NC}"
    echo ""
    exit 1
fi

exit 0

