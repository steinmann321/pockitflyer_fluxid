#!/bin/bash

# Lint: Third-party timing operations
# Detects rxdart, async, quiver timing utilities in non-service code

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

echo -e "${YELLOW}  Checking for third-party timing operations...${NC}"

SERVICE_KEYWORDS="service|timer|timing|debounce|throttle|scheduler"

for file in $STAGED_FILES; do
    # Skip service files
    if echo "$file" | grep -iE "$SERVICE_KEYWORDS" > /dev/null 2>&1; then
        continue
    fi

    if grep -q "// timing-allowed" "$file" 2>/dev/null; then
        continue
    fi

    # Check for third-party timing imports
    has_timing_import=false
    if grep -E "import 'package:rxdart|import 'package:async|import 'package:quiver" "$file" > /dev/null 2>&1; then
        has_timing_import=true
    fi

    if [ "$has_timing_import" = true ]; then
        # Check for timing methods
        if grep -nE "debounceTime|throttleTime|interval|RestartableTimer|Metronome" "$file" > /dev/null 2>&1; then
            line_nums=$(grep -nE "debounceTime|throttleTime|interval|RestartableTimer|Metronome" "$file" | cut -d: -f1 | head -5)
            echo -e "${RED}  ✗ ${file}${NC}"
            echo -e "    Third-party timing operation at line(s): ${line_nums}"
            echo -e "    ${YELLOW}Use timer service abstraction instead${NC}"
            FAILED=1
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Third-party timing operations detected${NC}"
    exit 1
fi

exit 0
