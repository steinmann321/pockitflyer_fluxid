#!/bin/bash


# Lint: No setState in build
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/lib/" || true)
[ -z "$STAGED_FILES" ] && exit 0
echo -e "${YELLOW}  Checking for setState in build...${NC}"
for file in $STAGED_FILES; do
    [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]] && continue
    if grep -q "Widget build(" "$file"; then
        build_start=$(grep -n "Widget build(" "$file" | head -1 | cut -d: -f1)
        [ -n "$build_start" ] && {
            context=$(sed -n "${build_start},$((build_start+50))p" "$file")
            if echo "$context" | grep -n "setState(" | grep -v "//" > /dev/null 2>&1; then
                line_offset=$(echo "$context" | grep -n "setState(" | grep -v "//" | head -1 | cut -d: -f1)
                actual_line=$((build_start + line_offset - 1))
                echo -e "${RED}  ✗ ${file}:${actual_line}${NC}"
                echo -e "    setState in build method"
                FAILED=1
            fi
        }
    fi
done
[ $FAILED -eq 1 ] && { echo ""; echo -e "${RED}  setState in build detected${NC}"; exit 1; }
exit 0

