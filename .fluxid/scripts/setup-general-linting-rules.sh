#!/bin/bash

# General Flutter Linting Rules Setup
# Sets up pre-commit hooks for test quality and timing-related patterns
#
# Usage:
#   ./setup-general-linting-rules.sh [flutter-app-directory]
#
# Examples:
#   ./setup-general-linting-rules.sh                    # Auto-detect Flutter app
#   ./setup-general-linting-rules.sh my_app             # Specific directory
#   ./setup-general-linting-rules.sh packages/mobile    # Monorepo structure

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

echo -e "${BLUE}=== General Flutter Linting Rules Setup ===${NC}"
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
echo -e "${YELLOW}Creating lint hook scripts...${NC}"
mkdir -p "${HOOKS_DIR}"

# Update or create pre-commit hook
if [ -f "${GIT_HOOKS_DIR}/pre-commit" ]; then
    echo -e "${YELLOW}  Pre-commit hook exists, will add general lint checks${NC}"
else
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
fi

# 1. Avoid pumpAndSettle in tests
cat > "${HOOKS_DIR}/10_avoid_pump_and_settle.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Avoid pumpAndSettle in tests
# Detects usage of pumpAndSettle() which causes flaky tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/test/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for pumpAndSettle()...${NC}"

for file in $STAGED_FILES; do
    if grep -n "pumpAndSettle()" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -n "pumpAndSettle()" "$file" | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    pumpAndSettle() at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use: await tester.pump() with explicit Duration instead${NC}"
        echo -e "    ${YELLOW}Why: pumpAndSettle() causes flaky tests with async ops${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  pumpAndSettle() detected${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/10_avoid_pump_and_settle.sh"

# 2. Avoid NetworkImage in tests
cat > "${HOOKS_DIR}/11_avoid_network_image_in_tests.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Avoid NetworkImage in tests
# Detects NetworkImage usage which causes flaky/hanging tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/(test|integration_test)/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for NetworkImage in tests...${NC}"

for file in $STAGED_FILES; do
    if grep -n "NetworkImage(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -n "NetworkImage(" "$file" | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    NetworkImage at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use: Image.memory(Uint8List(0)) or Image.asset()${NC}"
        echo -e "    ${YELLOW}Why: NetworkImage causes hanging tests (HTTP 400 in test env)${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  NetworkImage in tests detected${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/11_avoid_network_image_in_tests.sh"

# 3. Avoid AnimationController.repeat in tests
cat > "${HOOKS_DIR}/12_avoid_animation_repeat.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Avoid AnimationController.repeat
# Detects AnimationController.repeat() which should be disabled in tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/test/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for AnimationController.repeat()...${NC}"

for file in $STAGED_FILES; do
    # Look for .repeat() calls after AnimationController
    if grep -E "controller.*\.repeat\(|_controller.*\.repeat\(|animationController.*\.repeat\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "controller.*\.repeat\(|_controller.*\.repeat\(|animationController.*\.repeat\(" "$file" | cut -d: -f1)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    AnimationController.repeat() at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Disable in test mode or use explicit animation control${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  AnimationController.repeat() in tests detected${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/12_avoid_animation_repeat.sh"

# 4. Avoid await on Future constructors in tests
cat > "${HOOKS_DIR}/13_avoid_await_future_constructor.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Avoid await on Future constructors
# Detects await Future(...) patterns in tests

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
APP_DIR="${PROJECT_ROOT}/${APP_DIR_REL}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=$(basename "$APP_DIR")
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | grep -E "^${APP_DIR_NAME}/test/" || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}  Checking for await Future constructors...${NC}"

for file in $STAGED_FILES; do
    if grep -n "await Future(" "$file" | grep -v "Future.delayed" | grep -v "Future.value" > /dev/null 2>&1; then
        line_nums=$(grep -n "await Future(" "$file" | grep -v "Future.delayed" | grep -v "Future.value" | cut -d: -f1)
        if [ -n "$line_nums" ]; then
            echo -e "${RED}  ✗ ${file}${NC}"
            echo -e "    await Future() at line(s): ${line_nums}"
            echo -e "    ${YELLOW}Use tester.pump() to advance time instead${NC}"
            FAILED=1
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  await Future constructor detected${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/13_avoid_await_future_constructor.sh"

# Note: Timing-related rules (14-24) are now managed by setup-timing-linting-rules.sh
# Run that script separately to install timing enforcement rules

# Create README for test quality rules only
cat > "${HOOKS_DIR}/TEST_QUALITY_RULES.md" << 'README_EOF'
# Test Quality Rules for Flutter

These pre-commit hooks enforce test quality patterns to prevent flaky tests.

## Rules (All Blocking ❌)

### 1. Avoid pumpAndSettle (❌ Blocking)
**File:** `10_avoid_pump_and_settle.sh`
**Scope:** Test files only

**Detects:** Usage of `pumpAndSettle()` in tests

**Why:** Causes flaky tests with async operations and NetworkImage. Waits indefinitely for animations/timers, causing timeouts.

**Fix:**
```dart
// ❌ Bad
await tester.pumpAndSettle();

// ✅ Good
await tester.pump(); // Initial build
await tester.pump(const Duration(milliseconds: 100)); // Wait
await tester.pump(); // Rebuild
```

### 2. Avoid NetworkImage in Tests (❌ Blocking)
**File:** `11_avoid_network_image_in_tests.sh`
**Scope:** Test/integration_test files only

**Detects:** `NetworkImage()` in test files

**Why:** Makes HTTP requests that fail in test environment (returns 400), causes flaky/hanging tests.

**Fix:**
```dart
// ❌ Bad
Image(image: NetworkImage('https://example.com/image.png'))

// ✅ Good
Image.memory(Uint8List(0), key: const Key('test_image'))
// Or
Image.asset('assets/test_image.png')
```

### 3. Avoid AnimationController.repeat (❌ Blocking)
**File:** `12_avoid_animation_repeat.sh`
**Scope:** Test files only

**Detects:** `AnimationController.repeat()` in tests

**Why:** Infinite animations should be disabled in test mode.

**Fix:**
```dart
// ❌ Bad
controller.repeat();

// ✅ Good
if (!isTesting) {
  controller.repeat();
}
```

### 4. Avoid await Future Constructor (❌ Blocking)
**File:** `13_avoid_await_future_constructor.sh`
**Scope:** Test files only

**Detects:** `await Future(...)` patterns (not Future.delayed or Future.value)

**Why:** Use pump() to advance time, not real async waits.

**Fix:**
```dart
// ❌ Bad
await Future(() => someAction());

// ✅ Good
someAction();
await tester.pump();
```

## Summary

| Category | Rules | Focus |
|----------|-------|-------|
| **Test Quality** | 4 rules | Prevent flaky test patterns |

**Note:** For timing-related rules (11 additional rules), see `GENERAL_LINT_RULES.md` and run `setup-timing-linting-rules.sh`

## Bypass

```bash
# Skip hooks temporarily
git commit --no-verify
```

## Testing

```bash
# Test specific hook
.fluxid/hooks/flutter/10_avoid_pump_and_settle.sh

# Trigger all hooks
git commit --dry-run
```
README_EOF

echo -e "${GREEN}✓ Test quality lint scripts created${NC}"
echo ""

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${BLUE}Pre-commit hooks installed (test quality rules):${NC}"
echo "  ✓ Avoid pumpAndSettle"
echo "  ✓ Avoid NetworkImage in tests"
echo "  ✓ Avoid AnimationController.repeat"
echo "  ✓ Avoid await Future constructor"
echo ""
echo -e "${BLUE}Flutter app: ${APP_DIR_REL}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. For timing rules, run: .fluxid/scripts/setup-timing-linting-rules.sh"
echo "  2. Test the hooks: git commit --dry-run"
echo "  3. Read the docs: ${HOOKS_DIR}/TEST_QUALITY_RULES.md"
echo ""
echo -e "${YELLOW}Note:${NC} All checks will block commits if they fail."
echo "To skip: git commit --no-verify"
echo ""
