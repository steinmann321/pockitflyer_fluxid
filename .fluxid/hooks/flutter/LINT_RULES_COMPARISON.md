# Flutter Lint Rules Comparison

## Summary

The `pockitflyer_fluxid` project contains **two types** of custom lint rules:

1. **Custom Dart Linters** (`.fluxid/hooks/flutter/lint/`) - 14 rules using `custom_lint_builder`
2. **Shell-based Pre-commit Hooks** (`.fluxid/hooks/flutter/*.sh`) - 3 test quality scripts
3. **Python Pre-commit Hooks** (`.fluxid/hooks/flutter/*.py`) - 1 TDD tag enforcer

## NEW: Maestro-Focused Rules

The newly added **Maestro pre-commit hooks** (from `maestro-hooks-setup.sh`) focus on **e2e test reliability**.

---

## Detailed Comparison

### Category 1: Test Finder Reliability

| Rule | Type | Focus | Overlap? |
|------|------|-------|----------|
| **prefer_keys_over_text_finders** | Custom Lint | ❌ Blocks `find.text()` in test files | **YES - OVERLAPS** |
| **Maestro: enforce_test_identifiers** | Shell Script | ❌ Requires `key` or `Semantics` on widgets | **YES - OVERLAPS** |

**Overlap Analysis:**
- ✅ **COMPLEMENTARY** - They work together!
- `prefer_keys_over_text_finders`: Prevents using `find.text()` in **test code**
- `enforce_test_identifiers`: Enforces `key`/`Semantics` in **widget code**
- Together they ensure: widgets have identifiers AND tests use them correctly

**Recommendation:** **Keep both** - they cover different sides of the same problem.

---

### Category 2: Test Timing & Flakiness

| Rule | Type | Focus | Overlap? |
|------|------|-------|----------|
| **avoid_pump_and_settle** | Custom Lint | ❌ Blocks `pumpAndSettle()` | **NO - Test-specific** |
| **direct_timing_operation** | Custom Lint | ❌ Blocks `Future.delayed`, `Timer` | **NO - Production code** |
| **third_party_timing_operation** | Custom Lint | ❌ Blocks unconfigured `http` timeouts | **NO - Production code** |
| **timing_extension_method** | Custom Lint | ❌ Blocks `.delayed()` extensions | **NO - Production code** |
| **completer_timer_pattern** | Custom Lint | ⚠️ Warns about `Completer` + `Timer` | **NO - Production code** |
| **hardcoded_timing_duration** | Custom Lint | ❌ Blocks hardcoded `Duration` | **NO - Production code** |
| **animation_without_config** | Custom Lint | ❌ Requires `AnimationConfig` injection | **NO - Production code** |
| **service_missing_config_injection** | Custom Lint | ❌ Requires `TimingConfig` in services | **NO - Production code** |
| **Maestro: enforce_loading_states** | Shell Script | ❌ Requires `isLoading` for async ops | **NO - Different concern** |

**Overlap Analysis:**
- ❌ **NO OVERLAP**
- Existing rules focus on **testable timing patterns** (dependency injection)
- Maestro rules focus on **UI state management** for e2e tests

**Recommendation:** **Keep all** - they address different aspects of reliability.

---

### Category 3: Test Quality & Practices

| Rule | Type | Focus | Overlap? |
|------|------|-------|----------|
| **avoid_animation_repeat** | Custom Lint | ❌ Blocks `AnimationController.repeat()` | **NO** |
| **avoid_await_future_constructor** | Custom Lint | ❌ Blocks awaiting Future constructors | **NO** |
| **avoid_network_image_in_tests** | Custom Lint | ❌ Blocks `NetworkImage` in tests | **NO** |
| **check_dart_test_tags.py** | Python Hook | ❌ Enforces TDD tags (`tdd_green`, etc.) | **NO** |
| **flutter_coverage_enforce.sh** | Shell Hook | ❌ Enforces 90% code coverage | **NO** |
| **flutter_all_tests.sh** | Shell Hook | Runs all Flutter tests | **NO** |
| **Maestro: enforce_error_handling** | Shell Script | ❌ Requires try-catch for async | **NO** |
| **Maestro: no_hardcoded_text** | Shell Script | ❌ Requires l10n for Text widgets | **NO** |
| **Maestro: enforce_semantics** | Shell Script | ❌ Requires tooltips on IconButton | **NO** |
| **Maestro: no_direct_api_calls** | Shell Script | ❌ Blocks HTTP imports in UI | **NO** |
| **Maestro: no_setstate_in_build** | Shell Script | ❌ Blocks setState in build() | **NO** |

**Overlap Analysis:**
- ❌ **NO OVERLAP**
- Existing rules focus on **unit/widget test quality**
- Maestro rules focus on **e2e test reliability & maintainability**

**Recommendation:** **Keep all** - they serve different testing layers.

---

### Category 4: Form Validation

| Rule | Type | Focus | Overlap? |
|------|------|-------|----------|
| **Maestro: enforce_input_validation** | Shell Script | ❌ Requires validators on TextFormField | **NEW** |

**Overlap Analysis:**
- ✅ **NEW RULE** - No existing equivalent
- Ensures forms are testable in e2e tests

**Recommendation:** **Keep** - fills a gap.

---

## Summary Matrix

| Aspect | Existing Rules | Maestro Rules | Overlap? |
|--------|----------------|---------------|----------|
| **Widget identifiers** | ✅ Test-side (`prefer_keys`) | ✅ Widget-side (`enforce_identifiers`) | ✅ Complementary |
| **Timing/async patterns** | ✅ Testable DI patterns (14 rules) | ✅ UI loading states | ❌ Different concerns |
| **Form validation** | ❌ None | ✅ Validators required | ✅ New |
| **Error handling** | ❌ None | ✅ Try-catch required | ✅ New |
| **Localization** | ❌ None | ✅ No hardcoded text | ✅ New |
| **Accessibility** | ❌ None | ✅ Tooltips required | ✅ New |
| **Architecture** | ❌ None | ✅ No direct API in UI | ✅ New |
| **Widget lifecycle** | ❌ None | ✅ No setState in build | ✅ New |
| **Test quality** | ✅ TDD tags, coverage | ❌ None | ❌ Different |
| **Test flakiness** | ✅ `pumpAndSettle`, NetworkImage | ❌ None | ❌ Different |

---

## Recommendations

### ✅ Keep All Rules

**Why:**
1. **Only 1 overlap** - `prefer_keys_over_text_finders` + `enforce_test_identifiers` are **complementary**
2. **Different testing layers:**
   - Existing rules → Unit/Widget test quality & timing patterns
   - Maestro rules → E2E test reliability & maintainability
3. **Different enforcement mechanisms:**
   - Custom Lint → Real-time IDE feedback (Dart analyzer)
   - Shell/Python → Pre-commit blocking (Git hooks)

### Suggested Configuration

#### Option 1: Run Both (Recommended)
```bash
# Install both
.fluxid/scripts/maestro-hooks-setup.sh

# Existing hooks already installed
# Now you have comprehensive coverage!
```

**Git hook order:**
1. Maestro hooks (widget-level)
2. TDD tag checker (test-level)
3. Coverage enforcer (test completeness)

#### Option 2: Selective Installation
If you want lighter pre-commit hooks:

**Keep these Maestro rules (most valuable for e2e):**
- ✅ `01_enforce_test_identifiers` (matches `prefer_keys_over_text_finders`)
- ✅ `02_enforce_input_validation` (new - form testability)
- ✅ `05_no_hardcoded_text` (new - i18n stability)
- ⚠️ Skip `03_enforce_loading_states` if too strict

**Skip these Maestro rules (covered by architecture):**
- ❌ `07_no_direct_api_calls` (if you already enforce DI/architecture)

---

## Testing Layer Coverage

| Layer | Existing Rules | Maestro Rules |
|-------|----------------|---------------|
| **Widget Code** | Timing DI patterns | Identifiers, semantics, validators |
| **Test Code** | Text finders, pump patterns, TDD tags | - |
| **E2E Reliability** | - | Loading states, error handling |
| **Maintainability** | - | i18n, architecture |
| **Quality Gates** | Coverage 90%, TDD tags | Pre-commit blocking |

---

## Integration Strategy

### Step 1: Install Maestro Hooks
```bash
.fluxid/scripts/maestro-hooks-setup.sh pockitflyer_app
```

### Step 2: Update `.git/hooks/pre-commit`
Ensure both sets of rules run:

```bash
#!/bin/bash
set -e

# 1. Maestro e2e reliability checks
for script in .fluxid/hooks/flutter/0*.sh; do
    [ -x "$script" ] && "$script"
done

# 2. TDD tag enforcement
python3 .fluxid/hooks/flutter/check_dart_test_tags.py $(git diff --cached --name-only)

# 3. Coverage enforcement
.fluxid/hooks/flutter/flutter_coverage_enforce.sh
```

### Step 3: Document for Team
Add to project README:

```markdown
## Pre-commit Hooks

This project uses multiple lint layers:

1. **Custom Dart Linters** - Real-time IDE feedback
   - Run: `flutter analyze` (automatic in IDE)

2. **Maestro E2E Hooks** - Widget testability
   - Blocks: Missing keys, validators, semantics

3. **TDD Enforcement** - Test quality
   - Requires: `tdd_green`, `tdd_red`, `tdd_refactor` tags

4. **Coverage Gate** - 90% minimum

To install: `.fluxid/scripts/maestro-hooks-setup.sh pockitflyer_app`
```

---

## Conclusion

**Zero conflicts, maximum coverage!**

The existing rules and Maestro rules are **highly complementary**:
- **Existing** → Unit/widget test quality, timing patterns, TDD workflow
- **Maestro** → E2E reliability, UI testability, maintainability

Recommendation: **Install Maestro hooks and keep all existing rules** for comprehensive quality gates across all testing layers.
