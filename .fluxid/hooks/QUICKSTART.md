# Maestro Lint Hooks - Quick Start

## Installation

```bash
# Auto-detect Flutter app
.fluxid/scripts/maestro-hooks-setup.sh

# Or specify directory
.fluxid/scripts/maestro-hooks-setup.sh my_app
.fluxid/scripts/maestro-hooks-setup.sh packages/mobile

# Or with custom app name
.fluxid/scripts/maestro-hooks-setup.sh ecommerce_app
```

This installs 8 blocking pre-commit hooks to catch Maestro test issues.

## All Rules (All Blocking ❌)

| # | Rule | Fix |
|---|------|-----|
| 1 | **Test Identifiers** | Add `key: Key('id')` or wrap with `Semantics` |
| 2 | **Input Validation** | Add `validator:` to all `TextFormField` |
| 3 | **Loading States** | Add `bool _isLoading = false` for async setState |
| 4 | **Error Handling** | Wrap async code in `try-catch` |
| 5 | **Hardcoded Text** | Use `context.l10n.key` or `AppStrings.key` |
| 6 | **Semantics** | Add `tooltip:` to all `IconButton` |
| 7 | **No Direct API** | Don't import `http`/`dio` in UI layer |
| 8 | **No setState in Build** | Move `setState` out of `build()` |

## Quick Fixes

### 1. Missing Keys
```dart
// ❌ Before
ElevatedButton(onPressed: () {}, child: Text('Login'))

// ✅ After
ElevatedButton(
  key: Key('login-button'),
  onPressed: () {},
  child: Text('Login'),
)
```

### 2. Missing Validator
```dart
// ❌ Before
TextFormField()

// ✅ After
TextFormField(
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)
```

### 3. Missing Loading State
```dart
// ❌ Before
Future<void> login() async {
  final user = await authService.login();
  setState(() => this.user = user);
}

// ✅ After
bool _isLoading = false;

Future<void> login() async {
  setState(() => _isLoading = true);
  try {
    final user = await authService.login();
    setState(() => this.user = user);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 4. Missing Error Handling
```dart
// ❌ Before
Future<void> fetchData() async {
  final data = await api.getData();
  setState(() => this.data = data);
}

// ✅ After
Future<void> fetchData() async {
  try {
    final data = await api.getData();
    setState(() => this.data = data);
  } catch (e) {
    setState(() => error = e.toString());
  }
}
```

### 5. Hardcoded Text
```dart
// ❌ Before
Text('Welcome Back')

// ✅ After
Text(context.l10n.welcomeBack)
// or
Text(AppStrings.welcomeBack)
```

### 6. Missing Tooltip
```dart
// ❌ Before
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {},
)

// ✅ After
IconButton(
  icon: Icon(Icons.delete),
  tooltip: 'Delete item',
  onPressed: () {},
)
```

### 7. Direct API Call
```dart
// ❌ Before
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  Future<void> login() async {
    final response = await http.post(...);
  }
}

// ✅ After
class LoginScreen extends StatelessWidget {
  final AuthService authService; // Injected

  Future<void> login() async {
    await authService.login(...);
  }
}
```

### 8. setState in Build
```dart
// ❌ Before
@override
Widget build(BuildContext context) {
  setState(() => counter++);
  return Text('$counter');
}

// ✅ After
@override
void initState() {
  super.initState();
  counter++;
}

@override
Widget build(BuildContext context) {
  return Text('$counter');
}
```

## Bypass Options

### Temporary Skip
```bash
git commit --no-verify -m "emergency fix"
```

### Annotation Exceptions
```dart
// @allowUnvalidated
TextFormField()

// @allowUncaught
Future<void> dangerousMethod() async { ... }

// @allowNoLoading
Future<void> quickUpdate() async { ... }
```

## Testing Hooks

```bash
# Trigger without committing
git commit --dry-run

# Test specific hook
.fluxid/hooks/flutter/01_enforce_test_identifiers.sh
```

## Why These Rules?

All rules prevent common issues that make Maestro tests:
- **Flaky** - Can't find widgets, timing issues
- **Brittle** - Break when text changes
- **Incomplete** - Can't test edge cases, error states
- **Slow** - Hard to debug, require real API calls

By enforcing these at commit time, your Maestro tests become:
- ✅ Fast and reliable
- ✅ Easy to maintain
- ✅ Comprehensive coverage
