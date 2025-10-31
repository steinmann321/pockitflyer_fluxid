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
