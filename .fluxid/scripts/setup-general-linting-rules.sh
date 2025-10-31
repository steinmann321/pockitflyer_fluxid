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

# 5. Detect direct timing operations (Timer, Future.delayed) in business logic
cat > "${HOOKS_DIR}/14_direct_timing_operation.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Direct timing operations in business logic
# Detects Timer, Future.delayed, Stream.periodic in non-service production code

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

echo -e "${YELLOW}  Checking for direct timing operations...${NC}"

# Exempt service files (contain keywords: service, timer, timing, debounce, throttle)
SERVICE_KEYWORDS="service|timer|timing|debounce|throttle|scheduler|delay"

for file in $STAGED_FILES; do
    # Skip if file is a timing service
    if echo "$file" | grep -iE "$SERVICE_KEYWORDS" > /dev/null 2>&1; then
        continue
    fi

    # Skip if file has timing-allowed comment
    if grep -q "// timing-allowed\|// lint:allow-timing" "$file" 2>/dev/null; then
        continue
    fi

    # Check for Timer, Future.delayed, Stream.periodic
    if grep -nE "Timer\(|Timer\.periodic|Future\.delayed|Stream\.periodic" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "Timer\(|Timer\.periodic|Future\.delayed|Stream\.periodic" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    Direct timing operation at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Encapsulate in a service class instead${NC}"
        echo -e "    ${YELLOW}Or add: // timing-allowed${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Direct timing operations detected${NC}"
    echo -e "${YELLOW}  Why: Hard to test, violates SRP, causes flaky tests${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/14_direct_timing_operation.sh"

# 6. Detect third-party timing operations
cat > "${HOOKS_DIR}/15_third_party_timing_operation.sh" << 'LINT_EOF'
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
LINT_EOF

chmod +x "${HOOKS_DIR}/15_third_party_timing_operation.sh"

# 7. Detect hardcoded Duration in timing operations
cat > "${HOOKS_DIR}/16_hardcoded_timing_duration.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Hardcoded Duration in timing operations
# Detects literal Duration in Timer/Future.delayed/Stream.periodic

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

echo -e "${YELLOW}  Checking for hardcoded Duration...${NC}"

SERVICE_KEYWORDS="service|timer|timing|config"

for file in $STAGED_FILES; do
    # Skip service/config files
    if echo "$file" | grep -iE "$SERVICE_KEYWORDS" > /dev/null 2>&1; then
        continue
    fi

    # Check for Timer/Future.delayed/Stream.periodic with Duration(
    if grep -nE "Timer\(.*Duration\(|Future\.delayed\(.*Duration\(|Stream\.periodic\(.*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "Timer\(.*Duration\(|Future\.delayed\(.*Duration\(|Stream\.periodic\(.*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    Hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig duration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Hardcoded Duration in timing operations detected${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/16_hardcoded_timing_duration.sh"

# 8. Detect hardcoded Duration in Animated widgets
cat > "${HOOKS_DIR}/17_animation_without_config.sh" << 'LINT_EOF'
#!/bin/bash

# Lint: Animated widgets without TimingConfig
# Detects hardcoded Duration in AnimatedContainer, AnimatedOpacity, etc.

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

echo -e "${YELLOW}  Checking for animated widgets without config...${NC}"

for file in $STAGED_FILES; do
    # Check for Animated* widgets with duration: Duration(
    if grep -nE "Animated.*\(.*duration:.*Duration\(" "$file" > /dev/null 2>&1; then
        line_nums=$(grep -nE "Animated.*\(.*duration:.*Duration\(" "$file" | cut -d: -f1 | head -5)
        echo -e "${RED}  ✗ ${file}${NC}"
        echo -e "    Animated widget with hardcoded Duration at line(s): ${line_nums}"
        echo -e "    ${YELLOW}Use TimingConfig.animationDuration instead${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo -e "${RED}  Animated widgets without config detected${NC}"
    exit 1
fi

exit 0
LINT_EOF

chmod +x "${HOOKS_DIR}/17_animation_without_config.sh"

# Create README
cat > "${HOOKS_DIR}/GENERAL_LINT_RULES.md" << 'README_EOF'
# General Flutter Lint Rules

These pre-commit hooks enforce test quality and timing-related patterns.

## Rules (All Blocking ❌)

### Test Quality Rules

#### 1. Avoid pumpAndSettle (❌ Blocking)
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

#### 2. Avoid NetworkImage in Tests (❌ Blocking)
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

#### 3. Avoid AnimationController.repeat (❌ Blocking)
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

#### 4. Avoid await Future Constructor (❌ Blocking)
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

### Timing Pattern Rules

#### 5. Direct Timing Operations (❌ Blocking)
**File:** `14_direct_timing_operation.sh`
**Scope:** lib/ files (production code), excludes service files

**Detects:** `Timer`, `Timer.periodic`, `Future.delayed`, `Stream.periodic` in non-service code

**Why:** Hard to test, violates single responsibility, causes flaky tests.

**Exemptions:**
- Files containing keywords: `service`, `timer`, `timing`, `debounce`, `throttle`, `scheduler`, `delay`
- Files with `// timing-allowed` or `// lint:allow-timing` comment

**Fix:**
```dart
// ❌ Bad (in widget or business logic)
Timer(Duration(seconds: 1), () => doSomething());

// ✅ Good (create service)
class DebounceService {
  Timer? _timer;
  void call(VoidCallback cb, Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, cb);
  }
}

// Use in widget
final _debouncer = DebounceService();
_debouncer.call(() => doSomething(), config.debounceTime);
```

#### 6. Third-Party Timing Operations (❌ Blocking)
**File:** `15_third_party_timing_operation.sh`
**Scope:** lib/ files, excludes service files

**Detects:** rxdart/async/quiver timing methods in non-service code

**Methods checked:**
- rxdart: `debounceTime`, `throttleTime`, `interval`, `timer`
- async: `RestartableTimer`, `CancelableOperation`
- quiver: `Metronome`, `Clock`

**Fix:** Same as rule 5 - encapsulate in service layer.

#### 7. Hardcoded Timing Duration (❌ Blocking)
**File:** `16_hardcoded_timing_duration.sh`
**Scope:** lib/ files, excludes service/config files

**Detects:** Literal `Duration(...)` in Timer/Future.delayed/Stream.periodic

**Why:** Durations should be configurable for testability.

**Fix:**
```dart
// ❌ Bad
Timer(Duration(seconds: 1), () => action());

// ✅ Good
class MyService {
  final TimingConfig config;
  MyService(this.config);

  void scheduleAction() {
    Timer(config.actionDelay, () => action());
  }
}
```

#### 8. Animation Without Config (❌ Blocking)
**File:** `17_animation_without_config.sh`
**Scope:** lib/ files

**Detects:** Hardcoded `duration: Duration(...)` in Animated* widgets

**Widgets checked:** AnimatedContainer, AnimatedOpacity, AnimatedPositioned, etc.

**Fix:**
```dart
// ❌ Bad
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  child: ...
)

// ✅ Good
AnimatedContainer(
  duration: config.animationDuration,
  child: ...
)
```

## Summary

| Category | Rules | Focus |
|----------|-------|-------|
| **Test Quality** | 4 rules | Prevent flaky test patterns |
| **Timing Patterns** | 4 rules | Enforce testable timing abstractions |

## Bypass

```bash
# Skip hooks temporarily
git commit --no-verify

# Or add exemption comment
// timing-allowed
Timer(Duration(seconds: 1), () => action());
```

## Testing

```bash
# Test specific hook
.fluxid/hooks/flutter/10_avoid_pump_and_settle.sh

# Trigger all hooks
git commit --dry-run
```
README_EOF

echo -e "${GREEN}✓ Lint hook scripts created${NC}"
echo ""

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${BLUE}Pre-commit hooks installed (all blocking):${NC}"
echo "  Test Quality Rules:"
echo "    ✓ Avoid pumpAndSettle"
echo "    ✓ Avoid NetworkImage in tests"
echo "    ✓ Avoid AnimationController.repeat"
echo "    ✓ Avoid await Future constructor"
echo "  Timing Pattern Rules:"
echo "    ✓ Direct timing operations"
echo "    ✓ Third-party timing operations"
echo "    ✓ Hardcoded timing duration"
echo "    ✓ Animation without config"
echo ""
echo -e "${BLUE}Flutter app: ${APP_DIR_REL}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Test the hooks: git commit --dry-run"
echo "  2. Read the docs: ${HOOKS_DIR}/GENERAL_LINT_RULES.md"
echo "  3. For timing services, add: // timing-allowed"
echo ""
echo -e "${YELLOW}Note:${NC} All checks will block commits if they fail."
echo "To skip: git commit --no-verify"
echo "Service files are automatically exempted (contain keywords: service, timer, timing, etc.)"
echo ""
