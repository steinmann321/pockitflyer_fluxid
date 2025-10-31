#!/bin/bash


# Lint: No direct API calls
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/lib/(screens|pages|widgets|views)/" || true)
[ -z "$STAGED_FILES" ] && exit 0
echo -e "${YELLOW}  Checking for direct API calls...${NC}"
for file in $STAGED_FILES; do
    [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]] && continue
    if grep -n "import 'package:http/\|import 'package:dio/" "$file" > /dev/null 2>&1; then
        line_num=$(grep -n "import 'package:http/\|import 'package:dio/" "$file" | head -1 | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}:${line_num}${NC}"
        echo -e "    Direct HTTP import in UI layer"
        FAILED=1
    fi
done
[ $FAILED -eq 1 ] && { echo ""; echo -e "${RED}  Direct API calls detected${NC}"; exit 1; }
exit 0

