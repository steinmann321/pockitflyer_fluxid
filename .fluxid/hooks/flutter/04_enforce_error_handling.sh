#!/bin/bash


# Lint: Enforce error handling
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/(lib|test)/" || true)
[ -z "$STAGED_FILES" ] && exit 0
echo -e "${YELLOW}  Checking for missing error handling...${NC}"
for file in $STAGED_FILES; do
    [[ "$file" =~ _test\.dart$ ]] || [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]] && continue
    grep -q "@allowUncaught" "$file" && continue
    if grep -q "Future<" "$file" && grep -q "await" "$file"; then
        if ! grep -q "try {" "$file" && ! grep -q "catchError" "$file" && ! grep -q ".onError" "$file"; then
            line_num=$(grep -n "await" "$file" | head -1 | cut -d: -f1)
            echo -e "${RED}  ✗ ${file}:${line_num}${NC}"
            echo -e "    Async operation without error handling"
            FAILED=1
        fi
    fi
done
[ $FAILED -eq 1 ] && { echo ""; echo -e "${RED}  Missing error handling detected${NC}"; exit 1; }
exit 0

