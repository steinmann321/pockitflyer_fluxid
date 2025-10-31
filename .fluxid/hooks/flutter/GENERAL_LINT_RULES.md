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
