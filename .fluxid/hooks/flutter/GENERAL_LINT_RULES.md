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

#### 9. AnimationController Duration (❌ Blocking)
**File:** `18_animation_controller_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `duration: Duration(...)` or `reverseDuration: Duration(...)` in AnimationController

**Why:** AnimationController durations must be configurable to allow zero-duration animations in tests, preventing flaky tests.

**Fix:**
```dart
// ❌ Bad
_controller = AnimationController(
  duration: Duration(milliseconds: 300),
  vsync: this,
);

// ✅ Good
_controller = AnimationController(
  duration: timingConfig.animationDuration,
  vsync: this,
);

// ✅ Also good for reverseDuration
_controller = AnimationController(
  duration: timingConfig.animationDuration,
  reverseDuration: timingConfig.reverseAnimationDuration,
  vsync: this,
);
```

**Note:** This complements rule 8 (Animated* widgets) to ensure ALL animation timing is controlled via TimingConfig.

#### 10. PageController Animation Duration (❌ Blocking)
**File:** `19_page_controller_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `duration: Duration(...)` in `animateToPage`, `nextPage`, `previousPage`

**Why:** PageController animations (carousels, onboarding) cause flaky swipe tests when durations are hardcoded.

**Fix:**
```dart
// ❌ Bad
pageController.animateToPage(
  1,
  duration: Duration(milliseconds: 300),
  curve: Curves.ease,
);

// ✅ Good
pageController.animateToPage(
  1,
  duration: timingConfig.pageTransitionDuration,
  curve: Curves.ease,
);
```

#### 11. ScrollController Animation Duration (❌ Blocking)
**File:** `20_scroll_controller_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `duration: Duration(...)` in `ScrollController.animateTo`

**Why:** Scroll animations with hardcoded durations make scroll tests flaky.

**Fix:**
```dart
// ❌ Bad
scrollController.animateTo(
  100.0,
  duration: Duration(milliseconds: 200),
  curve: Curves.linear,
);

// ✅ Good
scrollController.animateTo(
  100.0,
  duration: timingConfig.scrollAnimationDuration,
  curve: Curves.linear,
);
```

#### 12. Image Fade Duration (❌ Blocking)
**File:** `21_image_fade_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `fadeInDuration` or `fadeOutDuration: Duration(...)` in FadeInImage/Image widgets

**Why:** Image fade animations with hardcoded durations make image loading tests flaky.

**Fix:**
```dart
// ❌ Bad
FadeInImage(
  fadeInDuration: Duration(milliseconds: 300),
  fadeOutDuration: Duration(milliseconds: 100),
  placeholder: placeholderImage,
  image: NetworkImage(url),
);

// ✅ Good
FadeInImage(
  fadeInDuration: timingConfig.imageFadeInDuration,
  fadeOutDuration: timingConfig.imageFadeOutDuration,
  placeholder: placeholderImage,
  image: NetworkImage(url),
);
```

#### 13. Dismissible Duration (❌ Blocking)
**File:** `22_dismissible_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `movementDuration` or `resizeDuration: Duration(...)` in Dismissible

**Why:** Swipe-to-dismiss animations with hardcoded durations make swipe gesture tests flaky.

**Fix:**
```dart
// ❌ Bad
Dismissible(
  key: key,
  movementDuration: Duration(milliseconds: 200),
  resizeDuration: Duration(milliseconds: 300),
  child: listItem,
);

// ✅ Good
Dismissible(
  key: key,
  movementDuration: timingConfig.dismissibleMovementDuration,
  resizeDuration: timingConfig.dismissibleResizeDuration,
  child: listItem,
);
```

#### 14. TweenAnimationBuilder Duration (❌ Blocking)
**File:** `23_tween_animation_builder_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `duration: Duration(...)` in TweenAnimationBuilder

**Why:** Custom tween animations with hardcoded durations make animation tests flaky.

**Fix:**
```dart
// ❌ Bad
TweenAnimationBuilder(
  duration: Duration(seconds: 1),
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value, child) => Opacity(opacity: value, child: child),
);

// ✅ Good
TweenAnimationBuilder(
  duration: timingConfig.tweenAnimationDuration,
  tween: Tween(begin: 0.0, end: 1.0),
  builder: (context, value, child) => Opacity(opacity: value, child: child),
);
```

#### 15. TabController Animation Duration (❌ Blocking)
**File:** `24_tab_controller_duration.sh`
**Scope:** lib/ files (production code)

**Detects:** Hardcoded `duration: Duration(...)` in `TabController.animateTo`

**Why:** Tab transition animations with hardcoded durations make tab navigation tests flaky.

**Fix:**
```dart
// ❌ Bad
tabController.animateTo(
  1,
  duration: Duration(milliseconds: 300),
  curve: Curves.ease,
);

// ✅ Good
tabController.animateTo(
  1,
  duration: timingConfig.tabTransitionDuration,
  curve: Curves.ease,
);
```

## Summary

| Category | Rules | Focus |
|----------|-------|-------|
| **Test Quality** | 4 rules | Prevent flaky test patterns |
| **Timing Patterns** | 11 rules | Enforce testable timing abstractions |

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
