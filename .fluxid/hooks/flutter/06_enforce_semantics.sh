#!/bin/bash


# Lint: Enforce semantics
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/lib/" || true)
[ -z "$STAGED_FILES" ] && exit 0
echo -e "${YELLOW}  Checking for missing semantics...${NC}"
for file in $STAGED_FILES; do
    [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]] && continue
    if grep -n "IconButton(" "$file" | grep -v "tooltip:" | grep -v "semanticLabel:" | grep -v "//" > /dev/null 2>&1; then
        line_nums=$(grep -n "IconButton(" "$file" | grep -v "tooltip:" | grep -v "semanticLabel:" | grep -v "//" | cut -d: -f1 || true)
        for line in $line_nums; do
            context=$(sed -n "${line},$((line+10))p" "$file")
            if ! echo "$context" | grep -q "tooltip:\|semanticLabel:"; then
                echo -e "${RED}  ✗ ${file}:${line}${NC}"
                echo -e "    IconButton without tooltip"
                FAILED=1
            fi
        done
    fi
done
[ $FAILED -eq 1 ] && { echo ""; echo -e "${RED}  Missing semantics detected${NC}"; exit 1; }
exit 0

