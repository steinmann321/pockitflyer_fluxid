#!/bin/bash

# Maestro Pre-commit Hooks Setup
# Sets up custom lint rules to catch issues before Maestro tests
#
# Usage:
#   ./maestro-hooks-setup.sh [flutter-app-directory]
#
# Examples:
#   ./maestro-hooks-setup.sh                    # Auto-detect Flutter app
#   ./maestro-hooks-setup.sh my_app             # Specific directory name
#   ./maestro-hooks-setup.sh packages/mobile    # Monorepo structure

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

    # Direct check
    if [ -f "${search_dir}/pubspec.yaml" ]; then
        echo "$search_dir"
        return 0
    fi

    # Search common locations
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
    # User provided directory
    if [[ "$1" == /* ]]; then
        APP_DIR="$1"  # Absolute path
    else
        APP_DIR="${PROJECT_ROOT}/$1"  # Relative path
    fi
else
    # Auto-detect
    APP_DIR=$(find_flutter_app "$PROJECT_ROOT")
    if [ -z "$APP_DIR" ]; then
        echo -e "${RED}Error: Could not auto-detect Flutter app directory${NC}"
        echo -e "${YELLOW}Usage: $0 [flutter-app-directory]${NC}"
        echo ""
        echo "Examples:"
        echo "  $0 my_app"
        echo "  $0 packages/mobile"
        exit 1
    fi
fi

echo -e "${BLUE}=== Maestro Pre-commit Hooks Setup ===${NC}"
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
    echo -e "${YELLOW}Directory: ${APP_DIR}${NC}"
    exit 1
fi

# Get relative path for hooks to use
APP_DIR_REL=$(python3 -c "import os; print(os.path.relpath('$APP_DIR', '$PROJECT_ROOT'))" 2>/dev/null || realpath --relative-to="$PROJECT_ROOT" "$APP_DIR" 2>/dev/null || basename "$APP_DIR")

echo -e "${GREEN}✓ Flutter app detected: ${APP_DIR_REL}${NC}"
echo ""

# Create hook scripts
echo -e "${YELLOW}Creating custom lint hook scripts...${NC}"

# Create hooks directory
mkdir -p "${HOOKS_DIR}"

# 1. Main pre-commit hook
cat > "${GIT_HOOKS_DIR}/pre-commit" << 'HOOK_EOF'
#!/bin/bash

# Pre-commit hook: Run custom Flutter lints for Maestro testability

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="${PROJECT_ROOT}/.fluxid/hooks/flutter"

echo -e "${YELLOW}Running Maestro-focused lints...${NC}"

# Run each lint check
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
echo -e "${GREEN}✓ All pre-commit checks passed${NC}"
exit 0
HOOK_EOF

chmod +x "${GIT_HOOKS_DIR}/pre-commit"

# Helper function to create lint scripts
create_lint_script() {
    local script_name="$1"
    local script_content="$2"

    cat > "${HOOKS_DIR}/${script_name}" << LINT_EOF
#!/bin/bash

${script_content}
LINT_EOF

    chmod +x "${HOOKS_DIR}/${script_name}"
}

# 2. Enforce test identifiers
create_lint_script "01_enforce_test_identifiers.sh" "
# Lint: Enforce test identifiers (key or Semantics)
# Ensures interactive widgets are findable in Maestro tests

PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

# Get staged Dart files
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/(lib|test)/\" || true)

if [ -z \"\$STAGED_FILES\" ]; then
    exit 0
fi

echo -e \"\${YELLOW}  Checking for missing keys/semantics...\${NC}\"

# Interactive widgets that need identification
INTERACTIVE_WIDGETS=(
    \"ElevatedButton\"
    \"TextButton\"
    \"OutlinedButton\"
    \"IconButton\"
    \"FloatingActionButton\"
    \"TextField\"
    \"TextFormField\"
    \"GestureDetector\"
    \"InkWell\"
    \"Checkbox\"
    \"Radio\"
    \"Switch\"
    \"Slider\"
    \"DropdownButton\"
)

for file in \$STAGED_FILES; do
    # Skip test files and generated files
    if [[ \"\$file\" =~ _test\\.dart\$ ]] || [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]]; then
        continue
    fi

    for widget in \"\${INTERACTIVE_WIDGETS[@]}\"; do
        # Look for widget declarations without key parameter
        if grep -n \"\${widget}(\" \"\$file\" | grep -v \"key:\" | grep -v \"Key(\" | grep -v \"Semantics\" | grep -v \"//\" > /dev/null 2>&1; then
            line_nums=\$(grep -n \"\${widget}(\" \"\$file\" | grep -v \"key:\" | grep -v \"Key(\" | grep -v \"Semantics\" | grep -v \"//\" | cut -d: -f1 || true)

            if [ -n \"\$line_nums\" ]; then
                echo -e \"\${RED}  ✗ \${file}\${NC}\"
                echo -e \"    \${widget} without key or Semantics at line(s): \${line_nums}\"
                echo -e \"    \${YELLOW}Add: key: Key('unique-identifier')\${NC}\"
                echo -e \"    \${YELLOW}Or wrap with: Semantics(identifier: 'unique-id', ...)\${NC}\"
                FAILED=1
            fi
        fi
    done
done

if [ \$FAILED -eq 1 ]; then
    echo \"\"
    echo -e \"\${RED}  Missing test identifiers detected\${NC}\"
    echo -e \"\${YELLOW}  Why: Maestro can't find widgets without keys or semantic identifiers\${NC}\"
    echo \"\"
    exit 1
fi

exit 0
"

# 3. Enforce input validation
create_lint_script "02_enforce_input_validation.sh" "
# Lint: Enforce input validation
# Ensures all TextFormField widgets have validators

PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/(lib|test)/\" || true)

if [ -z \"\$STAGED_FILES\" ]; then
    exit 0
fi

echo -e \"\${YELLOW}  Checking for missing form validation...\${NC}\"

for file in \$STAGED_FILES; do
    # Skip test files and generated files
    if [[ \"\$file\" =~ _test\\.dart\$ ]] || [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]]; then
        continue
    fi

    # Check for TextFormField without validator
    if grep -q \"TextFormField\" \"\$file\"; then
        # Extract TextFormField blocks and check for validator
        line_num=\$(grep -n \"TextFormField(\" \"\$file\" | cut -d: -f1 || true)

        for line in \$line_num; do
            # Check if validator exists within next 20 lines
            context=\$(sed -n \"\${line},\$((line+20))p\" \"\$file\")

            if ! echo \"\$context\" | grep -q \"validator:\" && ! echo \"\$context\" | grep -q \"@allowUnvalidated\"; then
                echo -e \"\${RED}  ✗ \${file}:\${line}\${NC}\"
                echo -e \"    TextFormField without validator\"
                echo -e \"    \${YELLOW}Add: validator: (value) => value?.isEmpty ?? true ? 'Required' : null\${NC}\"
                echo -e \"    \${YELLOW}Or annotate: @allowUnvalidated\${NC}\"
                FAILED=1
            fi
        done
    fi
done

if [ \$FAILED -eq 1 ]; then
    echo \"\"
    echo -e \"\${RED}  Missing form validation detected\${NC}\"
    echo -e \"\${YELLOW}  Why: Maestro can't easily test validation edge cases\${NC}\"
    echo \"\"
    exit 1
fi

exit 0
"

# Create remaining scripts with generic APP_DIR
for script_num in 03 04 05 06 07 08; do
    case $script_num in
        03)
            create_lint_script "03_enforce_loading_states.sh" "
# Lint: Enforce loading states
PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/(lib|test)/\" || true)
[ -z \"\$STAGED_FILES\" ] && exit 0
echo -e \"\${YELLOW}  Checking for missing loading states...\${NC}\"
for file in \$STAGED_FILES; do
    [[ \"\$file\" =~ _test\\.dart\$ ]] || [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]] && continue
    [[ ! \"\$file\" =~ (screen|page|widget|view)\\.dart\$ ]] && continue
    if grep -q \"Future<void>\" \"\$file\" && grep -q \"setState\" \"\$file\"; then
        if ! grep -q \"isLoading\\|_isLoading\\|@allowNoLoading\" \"\$file\"; then
            line_num=\$(grep -n \"Future<void>\" \"\$file\" | head -1 | cut -d: -f1)
            echo -e \"\${RED}  ✗ \${file}:\${line_num}\${NC}\"
            echo -e \"    Async method with setState but no loading state\"
            echo -e \"    \${YELLOW}Add: bool _isLoading = false;\${NC}\"
            FAILED=1
        fi
    fi
done
[ \$FAILED -eq 1 ] && { echo \"\"; echo -e \"\${RED}  Missing loading states detected\${NC}\"; exit 1; }
exit 0
"
            ;;
        04)
            create_lint_script "04_enforce_error_handling.sh" "
# Lint: Enforce error handling
PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/(lib|test)/\" || true)
[ -z \"\$STAGED_FILES\" ] && exit 0
echo -e \"\${YELLOW}  Checking for missing error handling...\${NC}\"
for file in \$STAGED_FILES; do
    [[ \"\$file\" =~ _test\\.dart\$ ]] || [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]] && continue
    grep -q \"@allowUncaught\" \"\$file\" && continue
    if grep -q \"Future<\" \"\$file\" && grep -q \"await\" \"\$file\"; then
        if ! grep -q \"try {\" \"\$file\" && ! grep -q \"catchError\" \"\$file\" && ! grep -q \".onError\" \"\$file\"; then
            line_num=\$(grep -n \"await\" \"\$file\" | head -1 | cut -d: -f1)
            echo -e \"\${RED}  ✗ \${file}:\${line_num}\${NC}\"
            echo -e \"    Async operation without error handling\"
            FAILED=1
        fi
    fi
done
[ \$FAILED -eq 1 ] && { echo \"\"; echo -e \"\${RED}  Missing error handling detected\${NC}\"; exit 1; }
exit 0
"
            ;;
        05)
            create_lint_script "05_no_hardcoded_text.sh" "
# Lint: No hardcoded text
PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/lib/\" || true)
[ -z \"\$STAGED_FILES\" ] && exit 0
echo -e \"\${YELLOW}  Checking for hardcoded text...\${NC}\"
for file in \$STAGED_FILES; do
    [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]] && continue
    if grep -n \"Text(['\\\"]\" \"\$file\" | grep -v \"context.l10n\\|AppStrings\\|//\" > /dev/null 2>&1; then
        line_nums=\$(grep -n \"Text(['\\\"]\" \"\$file\" | grep -v \"context.l10n\\|AppStrings\\|//\" | cut -d: -f1 || true)
        [ -n \"\$line_nums\" ] && { echo -e \"\${RED}  ✗ \${file}\${NC}\"; echo -e \"    Hardcoded text at line(s): \${line_nums}\"; FAILED=1; }
    fi
done
[ \$FAILED -eq 1 ] && { echo \"\"; echo -e \"\${RED}  Hardcoded text detected\${NC}\"; exit 1; }
exit 0
"
            ;;
        06)
            create_lint_script "06_enforce_semantics.sh" "
# Lint: Enforce semantics
PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/lib/\" || true)
[ -z \"\$STAGED_FILES\" ] && exit 0
echo -e \"\${YELLOW}  Checking for missing semantics...\${NC}\"
for file in \$STAGED_FILES; do
    [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]] && continue
    if grep -n \"IconButton(\" \"\$file\" | grep -v \"tooltip:\" | grep -v \"semanticLabel:\" | grep -v \"//\" > /dev/null 2>&1; then
        line_nums=\$(grep -n \"IconButton(\" \"\$file\" | grep -v \"tooltip:\" | grep -v \"semanticLabel:\" | grep -v \"//\" | cut -d: -f1 || true)
        for line in \$line_nums; do
            context=\$(sed -n \"\${line},\$((line+10))p\" \"\$file\")
            if ! echo \"\$context\" | grep -q \"tooltip:\\|semanticLabel:\"; then
                echo -e \"\${RED}  ✗ \${file}:\${line}\${NC}\"
                echo -e \"    IconButton without tooltip\"
                FAILED=1
            fi
        done
    fi
done
[ \$FAILED -eq 1 ] && { echo \"\"; echo -e \"\${RED}  Missing semantics detected\${NC}\"; exit 1; }
exit 0
"
            ;;
        07)
            create_lint_script "07_no_direct_api_calls.sh" "
# Lint: No direct API calls
PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/lib/(screens|pages|widgets|views)/\" || true)
[ -z \"\$STAGED_FILES\" ] && exit 0
echo -e \"\${YELLOW}  Checking for direct API calls...\${NC}\"
for file in \$STAGED_FILES; do
    [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]] && continue
    if grep -n \"import 'package:http/\\|import 'package:dio/\" \"\$file\" > /dev/null 2>&1; then
        line_num=\$(grep -n \"import 'package:http/\\|import 'package:dio/\" \"\$file\" | head -1 | cut -d: -f1)
        echo -e \"\${RED}  ✗ \${file}:\${line_num}\${NC}\"
        echo -e \"    Direct HTTP import in UI layer\"
        FAILED=1
    fi
done
[ \$FAILED -eq 1 ] && { echo \"\"; echo -e \"\${RED}  Direct API calls detected\${NC}\"; exit 1; }
exit 0
"
            ;;
        08)
            create_lint_script "08_no_setstate_in_build.sh" "
# Lint: No setState in build
PROJECT_ROOT=\"\$(git rev-parse --show-toplevel)\"
APP_DIR=\"\${PROJECT_ROOT}/${APP_DIR_REL}\"
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'; FAILED=0
APP_DIR_NAME=\$(basename \"\$APP_DIR\")
STAGED_FILES=\$(git diff --cached --name-only --diff-filter=ACM | grep '\\.dart\$' | grep -E \"^\${APP_DIR_NAME}/lib/\" || true)
[ -z \"\$STAGED_FILES\" ] && exit 0
echo -e \"\${YELLOW}  Checking for setState in build...\${NC}\"
for file in \$STAGED_FILES; do
    [[ \"\$file\" =~ \\.g\\.dart\$ ]] || [[ \"\$file\" =~ \\.freezed\\.dart\$ ]] && continue
    if grep -q \"Widget build(\" \"\$file\"; then
        build_start=\$(grep -n \"Widget build(\" \"\$file\" | head -1 | cut -d: -f1)
        [ -n \"\$build_start\" ] && {
            context=\$(sed -n \"\${build_start},\$((build_start+50))p\" \"\$file\")
            if echo \"\$context\" | grep -n \"setState(\" | grep -v \"//\" > /dev/null 2>&1; then
                line_offset=\$(echo \"\$context\" | grep -n \"setState(\" | grep -v \"//\" | head -1 | cut -d: -f1)
                actual_line=\$((build_start + line_offset - 1))
                echo -e \"\${RED}  ✗ \${file}:\${actual_line}\${NC}\"
                echo -e \"    setState in build method\"
                FAILED=1
            fi
        }
    fi
done
[ \$FAILED -eq 1 ] && { echo \"\"; echo -e \"\${RED}  setState in build detected\${NC}\"; exit 1; }
exit 0
"
            ;;
    esac
done

# Create README
cat > "${HOOKS_DIR}/README.md" << 'README_EOF'
# Flutter Custom Lint Hooks for Maestro Testability

These lint scripts run as pre-commit hooks to catch issues before they break Maestro tests.

## Rules (All Blocking ❌)

1. **Enforce Test Identifiers** - All interactive widgets must have `key` or `Semantics`
2. **Enforce Input Validation** - All `TextFormField` must have `validator` or `@allowUnvalidated`
3. **Enforce Loading States** - Async methods with `setState` must have loading boolean or `@allowNoLoading`
4. **Enforce Error Handling** - Async methods must have try-catch or be marked `@allowUncaught`
5. **No Hardcoded Text** - Text widgets must use constants or l10n
6. **Enforce Semantics** - `IconButton` must have `tooltip` or `semanticLabel`
7. **No Direct API Calls** - UI layer can't import `package:http` or `package:dio`
8. **No setState in Build** - No `setState` calls in `build` method

## Quick Fixes

```dart
// 1. Missing key
ElevatedButton(key: Key('login-btn'), ...)

// 2. Missing validator
TextFormField(validator: (v) => v?.isEmpty ?? true ? 'Required' : null)

// 3. Missing loading state
bool _isLoading = false;
Future<void> fetch() async {
  setState(() => _isLoading = true);
  try { ... } finally { setState(() => _isLoading = false); }
}

// 4. Missing error handling
try { await api.call(); } catch (e) { /* handle */ }

// 5. Hardcoded text
Text(context.l10n.welcomeText) // or AppStrings.welcomeText

// 6. Missing tooltip
IconButton(tooltip: 'Delete', ...)

// 7. Direct API - use service layer instead
final AuthService authService; // injected

// 8. setState in build - move to initState/didUpdateWidget
```

## Bypass

```bash
# Skip all hooks
git commit --no-verify

# Or use annotations
// @allowUnvalidated
// @allowUncaught
// @allowNoLoading
```

## Testing

```bash
# Trigger without committing
git commit --dry-run

# Test specific hook
.fluxid/hooks/flutter/01_enforce_test_identifiers.sh
```
README_EOF

echo -e "${GREEN}✓ Lint hook scripts created${NC}"
echo ""

# Update analysis_options.yaml
echo -e "${YELLOW}Updating analysis_options.yaml...${NC}"

ANALYSIS_FILE="${APP_DIR}/analysis_options.yaml"

if [ -f "$ANALYSIS_FILE" ]; then
    cp "$ANALYSIS_FILE" "${ANALYSIS_FILE}.backup"

    if ! grep -q "unawaited_futures" "$ANALYSIS_FILE"; then
        cat >> "$ANALYSIS_FILE" << 'YAML_EOF'

# Maestro testability lints
linter:
  rules:
    - unawaited_futures
    - avoid_void_async
    - cancel_subscriptions
    - prefer_null_aware_operators
    - unnecessary_null_checks
    - prefer_const_constructors
    - avoid_print
    - use_key_in_widget_constructors
YAML_EOF
        echo -e "${GREEN}✓ Added lints to analysis_options.yaml${NC}"
    else
        echo -e "${YELLOW}  Lints already present${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${BLUE}Pre-commit hooks installed (all blocking):${NC}"
echo "  ✓ Enforce test identifiers"
echo "  ✓ Enforce input validation"
echo "  ✓ Enforce loading states"
echo "  ✓ Enforce error handling"
echo "  ✓ No hardcoded text"
echo "  ✓ Enforce semantics"
echo "  ✓ No direct API calls"
echo "  ✓ No setState in build"
echo ""
echo -e "${BLUE}Flutter app: ${APP_DIR_REL}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Test the hooks: git commit --dry-run"
echo "  2. Read the docs: ${HOOKS_DIR}/README.md"
echo "  3. Run Flutter analyze: cd ${APP_DIR_REL} && flutter analyze"
echo ""
echo -e "${YELLOW}Note:${NC} All checks will block commits if they fail."
echo "To skip: git commit --no-verify"
echo "Or use annotations: @allowUnvalidated, @allowUncaught, @allowNoLoading"
echo ""
