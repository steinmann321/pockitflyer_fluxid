# TimingConfig Reference

This document lists all timing configuration properties required by the lint rules.

## Required TimingConfig Properties

Based on lint rules 7-15, your `TimingConfig` class must provide these duration properties:

### Animation Durations
```dart
class TimingConfig {
  // Rule 8: Animated* widgets (AnimatedContainer, AnimatedOpacity, etc.)
  final Duration animationDuration;

  // Rule 9: AnimationController
  final Duration reverseAnimationDuration;

  // Rule 10: PageController (carousels, onboarding)
  final Duration pageTransitionDuration;

  // Rule 11: ScrollController
  final Duration scrollAnimationDuration;

  // Rule 12: FadeInImage
  final Duration imageFadeInDuration;
  final Duration imageFadeOutDuration;

  // Rule 13: Dismissible (swipe-to-delete)
  final Duration dismissibleMovementDuration;
  final Duration dismissibleResizeDuration;

  // Rule 14: TweenAnimationBuilder
  final Duration tweenAnimationDuration;

  // Rule 15: TabController
  final Duration tabTransitionDuration;
}
```

### Timing Operation Durations
```dart
class TimingConfig {
  // Rule 7: Timer/Future.delayed/Stream.periodic in service files
  // (Service-specific, define as needed per service)
  final Duration debounceTime;
  final Duration retryDelay;
  final Duration shimmerDelay;
  // ... add more as needed by your timing services
}
```

## Implementation Pattern

### Test Configuration (Zero Durations)
```dart
class TimingConfig {
  const TimingConfig.test()
    : animationDuration = Duration.zero,
      reverseAnimationDuration = Duration.zero,
      pageTransitionDuration = Duration.zero,
      scrollAnimationDuration = Duration.zero,
      imageFadeInDuration = Duration.zero,
      imageFadeOutDuration = Duration.zero,
      dismissibleMovementDuration = Duration.zero,
      dismissibleResizeDuration = Duration.zero,
      tweenAnimationDuration = Duration.zero,
      tabTransitionDuration = Duration.zero,
      debounceTime = Duration.zero,
      retryDelay = Duration.zero,
      shimmerDelay = Duration.zero;
}
```

### Production Configuration (Realistic Durations)
```dart
class TimingConfig {
  const TimingConfig.production()
    : animationDuration = const Duration(milliseconds: 300),
      reverseAnimationDuration = const Duration(milliseconds: 200),
      pageTransitionDuration = const Duration(milliseconds: 250),
      scrollAnimationDuration = const Duration(milliseconds: 200),
      imageFadeInDuration = const Duration(milliseconds: 300),
      imageFadeOutDuration = const Duration(milliseconds: 100),
      dismissibleMovementDuration = const Duration(milliseconds: 200),
      dismissibleResizeDuration = const Duration(milliseconds: 300),
      tweenAnimationDuration = const Duration(milliseconds: 300),
      tabTransitionDuration = const Duration(milliseconds: 250),
      debounceTime = const Duration(milliseconds: 500),
      retryDelay = const Duration(seconds: 2),
      shimmerDelay = const Duration(milliseconds: 800);
}
```

### E2E Configuration (For Maestro Tests)
```dart
class TimingConfig {
  // Use production durations for realistic e2e tests
  const TimingConfig.e2e() : this.production();

  // Or use slightly faster durations to speed up e2e tests
  const TimingConfig.e2eFast()
    : animationDuration = const Duration(milliseconds: 150),
      reverseAnimationDuration = const Duration(milliseconds: 100),
      pageTransitionDuration = const Duration(milliseconds: 100),
      scrollAnimationDuration = const Duration(milliseconds: 100),
      imageFadeInDuration = const Duration(milliseconds: 150),
      imageFadeOutDuration = const Duration(milliseconds: 50),
      dismissibleMovementDuration = const Duration(milliseconds: 100),
      dismissibleResizeDuration = const Duration(milliseconds: 150),
      tweenAnimationDuration = const Duration(milliseconds: 150),
      tabTransitionDuration = const Duration(milliseconds: 100),
      debounceTime = const Duration(milliseconds: 250),
      retryDelay = const Duration(seconds: 1),
      shimmerDelay = const Duration(milliseconds: 400);
}
```

## Dependency Injection Setup

### Option 1: Provider (Recommended)
```dart
// main.dart
void main() {
  runApp(
    Provider<TimingConfig>(
      create: (_) => TimingConfig.production(),
      child: MyApp(),
    ),
  );
}

// In widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timingConfig = Provider.of<TimingConfig>(context);

    return AnimatedContainer(
      duration: timingConfig.animationDuration,
      child: ...,
    );
  }
}

// In tests
testWidgets('my test', (tester) async {
  await tester.pumpWidget(
    Provider<TimingConfig>(
      create: (_) => TimingConfig.test(),
      child: MyApp(),
    ),
  );
});
```

### Option 2: InheritedWidget
```dart
class TimingConfigProvider extends InheritedWidget {
  final TimingConfig config;

  const TimingConfigProvider({
    required this.config,
    required super.child,
  });

  static TimingConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TimingConfigProvider>()!.config;
  }

  @override
  bool updateShouldNotify(TimingConfigProvider oldWidget) {
    return config != oldWidget.config;
  }
}

// Usage
TimingConfigProvider.of(context).animationDuration
```

## Lint Rule Coverage

| Rule | File | Widget/API | Config Property |
|------|------|------------|-----------------|
| 7 | 16_hardcoded_timing_duration.sh | Timer/Future.delayed | service-specific |
| 8 | 17_animation_without_config.sh | Animated* widgets | animationDuration |
| 9 | 18_animation_controller_duration.sh | AnimationController | animationDuration, reverseAnimationDuration |
| 10 | 19_page_controller_duration.sh | PageController | pageTransitionDuration |
| 11 | 20_scroll_controller_duration.sh | ScrollController | scrollAnimationDuration |
| 12 | 21_image_fade_duration.sh | FadeInImage | imageFadeInDuration, imageFadeOutDuration |
| 13 | 22_dismissible_duration.sh | Dismissible | dismissibleMovementDuration, dismissibleResizeDuration |
| 14 | 23_tween_animation_builder_duration.sh | TweenAnimationBuilder | tweenAnimationDuration |
| 15 | 24_tab_controller_duration.sh | TabController | tabTransitionDuration |

## Migration Strategy

1. **Create TimingConfig class** with `.test()` and `.production()` constructors
2. **Inject at app root** using Provider or InheritedWidget
3. **Run pre-commit hooks** to find all violations
4. **Fix violations systematically** by replacing hardcoded durations with config properties
5. **Update tests** to inject `TimingConfig.test()`
6. **Verify all tests pass** with zero durations

## Benefits

✅ **Zero flaky tests** - All animations complete instantly in tests
✅ **Fast test execution** - No waiting for animations
✅ **Configurable** - Can adjust durations for different environments
✅ **Consistent** - All timing in one place
✅ **E2E ready** - Maestro tests use production durations for realistic behavior
