#!/bin/bash


# Lint: No hardcoded text
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/pockitflyer_app"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/lib/" || true)
[ -z "$STAGED_FILES" ] && exit 0
echo -e "${YELLOW}  Checking for hardcoded text...${NC}"
for file in $STAGED_FILES; do
    [[ "$file" =~ \.g\.dart$ ]] || [[ "$file" =~ \.freezed\.dart$ ]] && continue
    if grep -n "Text(['\"]" "$file" | grep -v "context.l10n\|AppStrings\|//" > /dev/null 2>&1; then
        line_nums=$(grep -n "Text(['\"]" "$file" | grep -v "context.l10n\|AppStrings\|//" | cut -d: -f1 || true)
        [ -n "$line_nums" ] && { echo -e "${RED}  ✗ ${file}${NC}"; echo -e "    Hardcoded text at line(s): ${line_nums}"; FAILED=1; }
    fi
done
[ $FAILED -eq 1 ] && { echo ""; echo -e "${RED}  Hardcoded text detected${NC}"; exit 1; }
exit 0

