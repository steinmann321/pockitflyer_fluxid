#!/bin/bash

# Timing-Related Flutter Linting Rules Setup
# Sets up pre-commit hooks for ALL timing/duration enforcement
#
# Enforces zero durations in tests, configurable durations in production
# Covers: AnimationController, PageController, ScrollController, Timers, etc.
#
# Usage:
#   ./setup-timing-linting-rules.sh [flutter-app-directory]
#
# Examples:
#   ./setup-timing-linting-rules.sh                    # Auto-detect Flutter app
#   ./setup-timing-linting-rules.sh my_app             # Specific directory
#   ./setup-timing-linting-rules.sh packages/mobile    # Monorepo structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
HOOKS_DIR="${PROJECT_ROOT}/.fluxid/hooks/flutter"
GIT_HOOKS_DIR="${PROJECT_ROOT}/.git/hooks"

# Function to find Flutter app
find_flutter_app() {
    local search_dir="$1"

    if [ -f "${search_dir}/pubspec.yaml" ]; then
        echo "$search_dir"
        return 0
    fi

    for candidate in "app" "mobile" "flutter_app" "my_app" */; do
        candidate="${search_dir}/${candidate}"
        if [ -f "${candidate}/pubspec.yaml" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

# Determine Flutter app directory
if [ -n "$1" ]; then
    if [[ "$1" == /* ]]; then
        APP_DIR="$1"
    else
        APP_DIR="${PROJECT_ROOT}/$1"
    fi
else
    APP_DIR=$(find_flutter_app "$PROJECT_ROOT")
    if [ -z "$APP_DIR" ]; then
        echo -e "${RED}Error: Could not auto-detect Flutter app directory${NC}"
        echo -e "${YELLOW}Usage: $0 [flutter-app-directory]${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}=== Timing-Related Linting Rules Setup ===${NC}"
echo ""
echo "Project root: ${PROJECT_ROOT}"
echo "Flutter app:  ${APP_DIR}"
echo "Flutter hooks: ${HOOKS_DIR}"
echo "Git hooks: ${GIT_HOOKS_DIR}"
echo ""

# Validations
if [ ! -d "${PROJECT_ROOT}/.git" ]; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    echo -e "${YELLOW}Initialize git first: git init${NC}"
    exit 1
fi

if [ ! -d "${APP_DIR}" ]; then
    echo -e "${RED}Error: Flutter app not found at ${APP_DIR}${NC}"
    echo -e "${YELLOW}Specify correct path: $0 path/to/flutter/app${NC}"
    exit 1
fi

if [ ! -f "${APP_DIR}/pubspec.yaml" ]; then
    echo -e "${RED}Error: Not a Flutter app (no pubspec.yaml found)${NC}"
    exit 1
fi

APP_DIR_REL=$(python3 -c "import os; print(os.path.relpath('$APP_DIR', '$PROJECT_ROOT'))" 2>/dev/null || realpath --relative-to="$PROJECT_ROOT" "$APP_DIR" 2>/dev/null || basename "$APP_DIR")

echo -e "${GREEN}✓ Flutter app detected: ${APP_DIR_REL}${NC}"
echo ""

# Create hook scripts
echo -e "${YELLOW}Creating timing lint hook scripts...${NC}"
mkdir -p "${HOOKS_DIR}"

# Ensure pre-commit hook exists
if [ ! -f "${GIT_HOOKS_DIR}/pre-commit" ]; then
    cat > "${GIT_HOOKS_DIR}/pre-commit" << 'HOOK_EOF'
#!/bin/bash

# Pre-commit hook: Run Flutter lints

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="${PROJECT_ROOT}/.fluxid/hooks/flutter"

echo -e "${YELLOW}Running Flutter lint checks...${NC}"

FAILED=0

for lint_script in "${HOOKS_DIR}"/*.sh; do
    if [ -f "$lint_script" ] && [ -x "$lint_script" ]; then
        script_name=$(basename "$lint_script")
        echo -e "${YELLOW}→ ${script_name}${NC}"

        if ! "$lint_script"; then
            FAILED=1
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}✗ Pre-commit checks failed${NC}"
    echo -e "${YELLOW}Fix the issues above or use 'git commit --no-verify' to skip${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ All lint checks passed${NC}"
exit 0
HOOK_EOF
    chmod +x "${GIT_HOOKS_DIR}/pre-commit"
    echo -e "${GREEN}✓ Created pre-commit hook${NC}"
fi

# Copy existing timing rules (14-17) - already exist, just ensure they're executable
for script_num in 14 15 16 17; do
    script_path="${HOOKS_DIR}/${script_num}_*.sh"
    if ls $script_path 1> /dev/null 2>&1; then
        chmod +x $script_path
    fi
done

# Create new timing rules (18-24)
echo -e "${YELLOW}  Creating rule 18: AnimationController duration...${NC}"
cp "${HOOKS_DIR}/18_animation_controller_duration.sh" "${HOOKS_DIR}/18_animation_controller_duration.sh.bak" 2>/dev/null || true
cat > "${HOOKS_DIR}/18_animation_controller_duration.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: AnimationController with hardcoded duration
# Detects literal Duration in AnimationController constructor

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

echo -e "${YELLOW}  Checking for AnimationController with hardcoded duration...${NC}"

for file in $STAGED_FILES; do
    # Check for AnimationController with duration: Duration(
    if grep -nE "AnimationController\([^)]*duration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "AnimationController\([^)]*duration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    AnimationController with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.animationDuration instead${NC}"
        FAILED=1
    fi

    # Also check for reverseDuration
    if grep -nE "AnimationController\([^)]*reverseDuration:\s*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "AnimationController\([^)]*reverseDuration:\s*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    AnimationController with hardcoded reverseDuration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.reverseAnimationDuration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  AnimationController with hardcoded duration detected${NC}"
    echo -e "${YELLOW}  Why: Makes tests flaky, durations should be configurable${NC}"
    exit 1
fi

exit 0
LINT_EOF

# Replace APP_DIR_REL placeholder
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/18_animation_controller_duration.sh"
rm "${HOOKS_DIR}/18_animation_controller_duration.sh.bak"
chmod +x "${HOOKS_DIR}/18_animation_controller_duration.sh"

echo -e "${YELLOW}  Creating rule 19: PageController duration...${NC}"
cp "${HOOKS_DIR}/19_page_controller_duration.sh" "${HOOKS_DIR}/19_page_controller_duration.sh.bak" 2>/dev/null || true
# Script already exists from previous creation, just ensure APP_DIR_REL is set
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/19_page_controller_duration.sh" 2>/dev/null || true
rm "${HOOKS_DIR}/19_page_controller_duration.sh.bak" 2>/dev/null || true
chmod +x "${HOOKS_DIR}/19_page_controller_duration.sh"

echo -e "${YELLOW}  Creating rule 20: ScrollController duration...${NC}"
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/20_scroll_controller_duration.sh" 2>/dev/null || true
rm "${HOOKS_DIR}/20_scroll_controller_duration.sh.bak" 2>/dev/null || true
chmod +x "${HOOKS_DIR}/20_scroll_controller_duration.sh"

echo -e "${YELLOW}  Creating rule 21: Image fade duration...${NC}"
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/21_image_fade_duration.sh" 2>/dev/null || true
rm "${HOOKS_DIR}/21_image_fade_duration.sh.bak" 2>/dev/null || true
chmod +x "${HOOKS_DIR}/21_image_fade_duration.sh"

echo -e "${YELLOW}  Creating rule 22: Dismissible duration...${NC}"
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/22_dismissible_duration.sh" 2>/dev/null || true
rm "${HOOKS_DIR}/22_dismissible_duration.sh.bak" 2>/dev/null || true
chmod +x "${HOOKS_DIR}/22_dismissible_duration.sh"

echo -e "${YELLOW}  Creating rule 23: TweenAnimationBuilder duration...${NC}"
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/23_tween_animation_builder_duration.sh" 2>/dev/null || true
rm "${HOOKS_DIR}/23_tween_animation_builder_duration.sh.bak" 2>/dev/null || true
chmod +x "${HOOKS_DIR}/23_tween_animation_builder_duration.sh"

echo -e "${YELLOW}  Creating rule 24: TabController duration...${NC}"
sed -i.bak "s|\${APP_DIR_REL}|${APP_DIR_REL}|g" "${HOOKS_DIR}/24_tab_controller_duration.sh" 2>/dev/null || true
rm "${HOOKS_DIR}/24_tab_controller_duration.sh.bak" 2>/dev/null || true
chmod +x "${HOOKS_DIR}/24_tab_controller_duration.sh"

echo -e "${GREEN}✓ All timing lint scripts created and configured${NC}"
echo ""

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${BLUE}Timing lint rules installed (all blocking):${NC}"
echo "  ✓ Rule 14: Direct timing operations (Timer, Future.delayed)"
echo "  ✓ Rule 15: Third-party timing (rxdart, async, quiver)"
echo "  ✓ Rule 16: Hardcoded timing duration"
echo "  ✓ Rule 17: Animated widgets without config"
echo "  ✓ Rule 18: AnimationController duration"
echo "  ✓ Rule 19: PageController duration"
echo "  ✓ Rule 20: ScrollController duration"
echo "  ✓ Rule 21: Image fade duration"
echo "  ✓ Rule 22: Dismissible duration"
echo "  ✓ Rule 23: TweenAnimationBuilder duration"
echo "  ✓ Rule 24: TabController duration"
echo ""
echo -e "${BLUE}Total: 11 timing-related rules${NC}"
echo ""
echo -e "${BLUE}Flutter app: ${APP_DIR_REL}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Create TimingConfig class: lib/config/timing_config.dart"
echo "     See: .fluxid/hooks/flutter/TIMING_CONFIG_REFERENCE.md"
echo "  2. Set up dependency injection (Provider recommended)"
echo "  3. Test the hooks: git commit --dry-run"
echo "  4. Read the docs: ${HOOKS_DIR}/GENERAL_LINT_RULES.md"
echo ""
echo -e "${YELLOW}Key principle:${NC} Zero durations in tests, production durations in Maestro E2E"
echo ""
echo -e "${YELLOW}Note:${NC} All checks will block commits if they fail."
echo "To skip: git commit --no-verify"
echo "Service/config files are automatically exempted"
echo ""
