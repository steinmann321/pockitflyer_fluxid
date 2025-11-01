# Flutter Linting Setup Scripts

This directory contains three setup scripts for enforcing Flutter code quality through Git pre-commit hooks.

## Available Scripts

### 1. `maestro-hooks-setup.sh` - Maestro Testability Rules

Installs hooks that enforce code quality rules designed to make Maestro e2e tests more reliable and maintainable.

**Rules:** 8 rules (01-08) focused on test identifiers, validation, error handling, etc.

### 2. `setup-general-linting-rules.sh` - Test Quality Rules

Installs hooks that prevent flaky test patterns in widget tests.

**Rules:** 4 rules (10-13) focused on avoiding `pumpAndSettle`, NetworkImage, etc.

### 3. `setup-timing-linting-rules.sh` - Timing/Duration Enforcement ⭐ NEW

Installs hooks that enforce ALL timing and duration configurations through `TimingConfig`.

**Rules:** 11 rules (14-24) covering AnimationController, PageController, ScrollController, Timer, Future.delayed, and more.

**Key Benefit:** Zero durations in widget tests, production durations in Maestro E2E tests.

---

## Quick Start

```bash
# Install all three rule sets
cd .fluxid/scripts

# 1. Maestro testability rules
./maestro-hooks-setup.sh

# 2. Test quality rules
./setup-general-linting-rules.sh

# 3. Timing enforcement rules (recommended!)
./setup-timing-linting-rules.sh
```

---

## Timing Rules Script (Detailed)

### What It Does

The `setup-timing-linting-rules.sh` script enforces that **all timing/duration values** come from a centralized `TimingConfig` class, ensuring:
- ✅ **Zero durations in widget tests** → fast, deterministic tests
- ✅ **Production durations in Maestro E2E** → realistic user experience testing
- ✅ **No flaky animation/timing tests** → consistent CI/CD

## Usage

```bash
# Auto-detect Flutter app (searches common locations)
.fluxid/scripts/maestro-hooks-setup.sh

# Specify Flutter app directory
.fluxid/scripts/maestro-hooks-setup.sh my_app
.fluxid/scripts/maestro-hooks-setup.sh packages/mobile
.fluxid/scripts/maestro-hooks-setup.sh ecommerce_app
```

## What Gets Created/Modified

| Path | Action | Description |
|------|--------|-------------|
| `.git/hooks/pre-commit` | **Created/Overwritten** | Main Git pre-commit hook that runs all lint checks |
| `.fluxid/hooks/flutter/01_*.sh` | **Created** | Test identifiers check |
| `.fluxid/hooks/flutter/02_*.sh` | **Created** | Input validation check |
| `.fluxid/hooks/flutter/03_*.sh` | **Created** | Loading states check |
| `.fluxid/hooks/flutter/04_*.sh` | **Created** | Error handling check |
| `.fluxid/hooks/flutter/05_*.sh` | **Created** | Hardcoded text check |
| `.fluxid/hooks/flutter/06_*.sh` | **Created** | Semantics check |
| `.fluxid/hooks/flutter/07_*.sh` | **Created** | Direct API calls check |
| `.fluxid/hooks/flutter/08_*.sh` | **Created** | setState in build check |
| `.fluxid/hooks/flutter/README.md` | **Created** | Documentation |
| `<app>/analysis_options.yaml` | **Modified** | Adds Dart linter rules (backup created) |

## How It Works

### 1. Auto-Detection

The script searches for a Flutter app by looking for `pubspec.yaml` in:
- Project root (`.`)
- Common subdirectories (`app`, `mobile`, `flutter_app`, `my_app`)
- Any subdirectory with `pubspec.yaml`

### 2. Validation

Checks that:
- ✅ You're in a git repository (has `.git/` directory)
- ✅ Flutter app directory exists
- ✅ Directory contains `pubspec.yaml` (confirms it's a Flutter app)

### 3. Hook Installation

Creates:
- **Main hook**: `.git/hooks/pre-commit` - orchestrates all checks
- **8 lint scripts**: `.fluxid/hooks/flutter/0[1-8]_*.sh` - individual checks
- **Documentation**: Explains each rule and how to fix violations

### 4. Configuration Update

Adds recommended Dart linter rules to `analysis_options.yaml`:
- `unawaited_futures`
- `avoid_void_async`
- `cancel_subscriptions`
- `prefer_null_aware_operators`
- And more...

## When Hooks Run

**Automatically** every time you run:
```bash
git commit
```

The pre-commit hook:
1. Finds all staged `.dart` files in your Flutter app
2. Runs 8 lint checks on those files
3. If ANY check fails → commit is blocked
4. If ALL checks pass → commit proceeds

## What Gets Checked

Only **staged Dart files** in your Flutter app's `lib/` and `test/` directories.

**Excluded**:
- Generated files (`*.g.dart`, `*.freezed.dart`)
- Files outside the Flutter app
- Non-Dart files

## Example Run

```bash
$ git add lib/screens/login_screen.dart
$ git commit -m "Add login screen"

Running Maestro-focused lints...
→ 01_enforce_test_identifiers.sh
  Checking for missing keys/semantics...
  ✗ lib/screens/login_screen.dart
    ElevatedButton without key or Semantics at line(s): 45
    Add: key: Key('unique-identifier')

✗ Pre-commit checks failed
Fix the issues above or use 'git commit --no-verify' to skip
```

## Bypass Options

### Temporary Skip
```bash
git commit --no-verify -m "emergency fix"
```

### Code Annotations
```dart
// @allowUnvalidated
TextFormField()

// @allowUncaught
Future<void> riskyMethod() async { ... }

// @allowNoLoading
Future<void> quickUpdate() async { ... }
```

## Requirements

- **Git repository**: Must have `.git/` directory
- **Flutter app**: Must have `pubspec.yaml`
- **Bash**: Script runs in bash shell
- **Standard tools**: `grep`, `sed`, `git` (usually pre-installed)

## Platform Support

- ✅ Linux
- ✅ macOS
- ✅ WSL (Windows Subsystem for Linux)
- ⚠️ Windows (requires Git Bash or WSL)

## Customization

### Change Which Rules Run

Edit `.git/hooks/pre-commit` and comment out checks you don't want:

```bash
for lint_script in "${HOOKS_DIR}"/*.sh; do
    # Skip specific check
    [[ "$lint_script" =~ 05_no_hardcoded_text.sh ]] && continue

    if [ -f "$lint_script" ] && [ -x "$lint_script" ]; then
        # ... run check
    fi
done
```

### Modify Rule Strictness

Edit individual scripts in `.fluxid/hooks/flutter/`:

```bash
# Make a rule less strict
vim .fluxid/hooks/flutter/01_enforce_test_identifiers.sh
```

## Troubleshooting

### "Could not auto-detect Flutter app"
**Solution**: Specify the directory explicitly
```bash
.fluxid/scripts/maestro-hooks-setup.sh path/to/app
```

### "Not in a git repository"
**Solution**: Initialize git first
```bash
git init
```

### Hooks not running
**Check**: Is `.git/hooks/pre-commit` executable?
```bash
ls -l .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Hooks running on wrong directory
**Solution**: Re-run setup with correct path
```bash
.fluxid/scripts/maestro-hooks-setup.sh correct_app_name
```

## Uninstall

To remove hooks:

```bash
# Remove Git hook
rm .git/hooks/pre-commit

# Remove lint scripts (optional)
rm -rf .fluxid/hooks/flutter/

# Restore original analysis_options.yaml
mv <app>/analysis_options.yaml.backup <app>/analysis_options.yaml
```

## For Teams

**Recommended**: Commit the hook scripts to version control:

```bash
# Add scripts to git (but not .git/hooks/pre-commit)
git add .fluxid/

# Each team member runs setup
.fluxid/scripts/maestro-hooks-setup.sh
```

**In README.md**, add setup instructions:
```markdown
## Setup

After cloning, install pre-commit hooks:
```bash
.fluxid/scripts/maestro-hooks-setup.sh
```
```

## Why These Checks?

All rules prevent issues that make Maestro tests:
- **Flaky**: Can't reliably find widgets or handle timing
- **Brittle**: Break when text/UI changes
- **Incomplete**: Can't test edge cases, errors, loading states
- **Slow**: Hard to debug, require real API calls

By enforcing at commit time, tests become:
- ✅ Fast and reliable
- ✅ Easy to maintain
- ✅ Comprehensive coverage

---

## Timing Rules Coverage (Rules 14-24)

| Rule | File | Enforces | Config Property |
|------|------|----------|-----------------|
| 14 | `14_direct_timing_operation.sh` | Timer/Future.delayed in services only | service-specific |
| 15 | `15_third_party_timing_operation.sh` | No rxdart/async timing in business logic | N/A |
| 16 | `16_hardcoded_timing_duration.sh` | No hardcoded Duration in timers | timingConfig.* |
| 17 | `17_animation_without_config.sh` | Animated* widgets use config | animationDuration |
| 18 | `18_animation_controller_duration.sh` | AnimationController uses config | animationDuration, reverseAnimationDuration |
| 19 | `19_page_controller_duration.sh` | PageController uses config | pageTransitionDuration |
| 20 | `20_scroll_controller_duration.sh` | ScrollController uses config | scrollAnimationDuration |
| 21 | `21_image_fade_duration.sh` | FadeInImage uses config | imageFadeInDuration, imageFadeOutDuration |
| 22 | `22_dismissible_duration.sh` | Dismissible uses config | dismissibleMovementDuration, dismissibleResizeDuration |
| 23 | `23_tween_animation_builder_duration.sh` | TweenAnimationBuilder uses config | tweenAnimationDuration |
| 24 | `24_tab_controller_duration.sh` | TabController uses config | tabTransitionDuration |

**Total:** 11 timing-related rules ensuring zero flaky animation tests!

---

## Implementation Guide

After running `setup-timing-linting-rules.sh`:

1. **Create TimingConfig class** at `lib/config/timing_config.dart`:
   ```dart
   class TimingConfig {
     final Duration animationDuration;
     final Duration pageTransitionDuration;
     // ... see TIMING_CONFIG_REFERENCE.md for complete list

     const TimingConfig.test() : animationDuration = Duration.zero, ...;
     const TimingConfig.production() : animationDuration = const Duration(milliseconds: 300), ...;
   }
   ```

2. **Inject via Provider** (recommended):
   ```dart
   // main.dart
   runApp(
     Provider<TimingConfig>(
       create: (_) => TimingConfig.production(),
       child: MyApp(),
     ),
   );

   // tests
   Provider<TimingConfig>(
     create: (_) => TimingConfig.test(),
     child: MyApp(),
   );
   ```

3. **Reference documentation**: `.fluxid/hooks/flutter/TIMING_CONFIG_REFERENCE.md`

---

## More Info

- **Maestro rules**: `.fluxid/hooks/flutter/README.md`
- **Test quality rules**: `.fluxid/hooks/flutter/TEST_QUALITY_RULES.md`
- **Timing rules**: `.fluxid/hooks/flutter/GENERAL_LINT_RULES.md`
- **TimingConfig reference**: `.fluxid/hooks/flutter/TIMING_CONFIG_REFERENCE.md`
- Quick reference: `.fluxid/hooks/QUICKSTART.md`
