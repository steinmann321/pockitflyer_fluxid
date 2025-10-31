/// PATTERN: Service with Timing - Where Timing Operations ARE Allowed
///
/// WHY THIS IS IMPORTANT:
/// Timing operations (Timer, Future.delayed, etc.) should be encapsulated in dedicated
/// service classes, not scattered throughout business logic or UI code. This enables
/// easy mocking in tests, maintains single responsibility principle, and makes tests
/// fast and deterministic. Business logic and widgets should consume these services,
/// not implement timing directly.
///
/// WHEN TO USE:
/// - Implementing debouncing or throttling
/// - Creating polling mechanisms
/// - Implementing retry with exponential backoff
/// - Managing scheduled tasks
/// - Handling delayed operations
///
/// RELATED RULES:
/// - Rule: direct_timing_operation (custom lint)
/// - Rule: unidentifiable_timing_service (custom lint)
/// - Rule: missing_fake_async (custom lint)

import 'dart:async';
import 'package:pockitflyer_app/core/timing/timing_config.dart';

// ============================================================================
// SERVICE IDENTIFICATION
// ============================================================================

// ✅ ALWAYS: Name service classes with timing-related keywords
// Keywords that identify a timing service:
// - service, timer, timing, scheduler, schedule
// - debounce, throttle, delay
// - async, periodic, interval, future, stream

// Examples of acceptable service names:
// - TimerService, DebounceService, PollingService
// - SearchThrottler, AutoSaveScheduler
// - DelayedActionService, PeriodicSyncService

// ============================================================================
// DEBOUNCE SERVICE
// ============================================================================

// ✅ ALWAYS: Encapsulate debouncing logic in a service class
class DebounceService {
  final TimingConfig timing;
  Timer? _debounceTimer;

  DebounceService({required this.timing});

  /// Debounces a callback - uses TimingConfig by default, optional override
  void call(VoidCallback callback, {Duration? overrideDelay}) {
    final delay = overrideDelay ?? timing.debounceDuration;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback); // ✅ Timing allowed in service
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

// Usage in business logic or widget:
class SearchController {
  final DebounceService _debouncer;

  SearchController({required TimingConfig timing})
      : _debouncer = DebounceService(timing: timing);

  void onSearchTextChanged(String query) {
    // ✅ CORRECT: Using service abstraction, not direct timing
    _debouncer.call(() {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    // Actual search logic
  }
}

// ❌ NEVER: Implement debouncing directly in business logic
class BadSearchController {
  Timer? _debounceTimer;

  void onSearchTextChanged(String query) {
    _debounceTimer?.cancel();
    // ❌ WRONG: Direct timing operation in business logic
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {}
}

// ============================================================================
// THROTTLE SERVICE
// ============================================================================

// ✅ ALWAYS: Create throttle service for rate-limiting operations
class ThrottleService {
  final TimingConfig timing;
  DateTime? _lastExecutionTime;

  ThrottleService({required this.timing});

  /// Throttles a callback - executes at most once per interval
  void call(VoidCallback callback, {Duration? overrideInterval}) {
    final interval = overrideInterval ?? timing.throttleDuration;
    final now = DateTime.now();
    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= interval) {
      _lastExecutionTime = now;
      callback();
    }
  }
}

// Usage:
class ScrollEventHandler {
  final ThrottleService _throttler;

  ScrollEventHandler({required TimingConfig timing})
      : _throttler = ThrottleService(timing: timing);

  void onScroll(double position) {
    // ✅ CORRECT: Using service abstraction
    _throttler.call(() {
      _updateScrollPosition(position);
    });
  }

  void _updateScrollPosition(double position) {}
}

// ============================================================================
// POLLING SERVICE
// ============================================================================

// ✅ ALWAYS: Encapsulate polling in a dedicated service
class PollingService {
  final TimingConfig timing;
  Timer? _pollingTimer;

  PollingService({required this.timing});

  void startPolling(VoidCallback callback, {Duration? overrideInterval}) {
    stopPolling();
    // ✅ Timing allowed in service
    final interval = overrideInterval ?? timing.throttleDuration;
    _pollingTimer = Timer.periodic(interval, (_) {
      callback();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void dispose() {
    stopPolling();
  }
}

// Usage:
class FeedRefreshManager {
  final PollingService _poller;

  FeedRefreshManager({required TimingConfig timing})
      : _poller = PollingService(timing: timing);

  void startAutoRefresh() {
    // ✅ CORRECT: Using service abstraction
    _poller.startPolling(() {
      _refreshFeed();
    }, overrideInterval: const Duration(minutes: 5));
  }

  void stopAutoRefresh() {
    _poller.stopPolling();
  }

  void _refreshFeed() {}
}

// ============================================================================
// RETRY SERVICE WITH EXPONENTIAL BACKOFF
// ============================================================================

// ✅ ALWAYS: Encapsulate retry logic with delays in service
class RetryService {
  final TimingConfig timing;
  final int maxAttempts;

  RetryService({required this.timing, this.maxAttempts = 3});

  Future<T> retry<T>(Future<T> Function() operation) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        // ✅ Timing allowed in service
        final base = timing.retryDelay;
        final delay = base * (1 << (attempt - 1)); // Exponential backoff
        await Future.delayed(delay);
      }
    }
  }
}

// Usage:
class ApiClient {
  final RetryService _retryService;

  ApiClient({required TimingConfig timing})
      : _retryService = RetryService(timing: timing);

  Future<String> fetchData() async {
    // ✅ CORRECT: Using service abstraction
    return _retryService.retry(() async {
      return await _makeApiCall();
    });
  }

  Future<String> _makeApiCall() async {
    // Actual API call
    return 'data';
  }
}

// ============================================================================
// DELAYED ACTION SERVICE
// ============================================================================

// ✅ ALWAYS: Encapsulate delayed actions in service
class DelayedActionService {
  final TimingConfig timing;

  DelayedActionService({required this.timing});

  Future<void> delayedAction(VoidCallback callback, {Duration? overrideDelay}) async {
    // ✅ Timing allowed in service
    final delay = overrideDelay ?? timing.debounceDuration;
    await Future.delayed(delay);
    callback();
  }
}

// Usage:
class NotificationManager {
  final DelayedActionService _delayService;

  NotificationManager({required TimingConfig timing})
      : _delayService = DelayedActionService(timing: timing);

  void showNotification(String message) {
    // Show notification
    // ✅ CORRECT: Using service abstraction
    _delayService.delayedAction(() {
      _hideNotification();
    }, overrideDelay: const Duration(seconds: 3));
  }

  void _hideNotification() {}
}

// ============================================================================
// TESTING TIMING SERVICES
// ============================================================================

// ✅ ALWAYS: Use fakeAsync for testing timing services
void exampleServiceTest() {
  // Note: In real code, import 'package:fake_async/fake_async.dart'
  // test('debounces correctly', () {
  //   fakeAsync((async) {
  //     final service = DebounceService(delay: Duration(milliseconds: 500));
  //     int callCount = 0;
  //
  //     // Rapid calls
  //     service.call(() => callCount++);
  //     service.call(() => callCount++);
  //     service.call(() => callCount++);
  //
  //     // Should not execute yet
  //     expect(callCount, 0);
  //
  //     // Advance time
  //     async.elapse(Duration(milliseconds: 500));
  //
  //     // Should execute only once
  //     expect(callCount, 1);
  //   });
  // });
}

// ============================================================================
// ANNOTATION ALTERNATIVE
// ============================================================================

// ✅ ALTERNATIVE: Use @TimingAllowed() annotation if name doesn't include keywords
class TimingAllowed {
  const TimingAllowed();
}

@TimingAllowed()
class BackgroundSync {
  // ✅ Timing allowed due to annotation
  Timer? _syncTimer;

  void startSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _performSync();
    });
  }

  void _performSync() {}
}

// ============================================================================
// COMMENT ALTERNATIVE
// ============================================================================

// ✅ ALTERNATIVE: Use // timing-allowed comment above class
// timing-allowed
class AutoSave {
  // ✅ Timing allowed due to comment
  Timer? _saveTimer;

  void scheduleAutoSave() {
    _saveTimer = Timer(const Duration(seconds: 30), () {
      _save();
    });
  }

  void _save() {}
}

// ============================================================================
// KEY PRINCIPLES
// ============================================================================

// 1. TIMING OPERATIONS ONLY IN SERVICES:
//    - Never use Timer/Future.delayed directly in business logic
//    - Never use timing operations in widgets
//    - Always encapsulate in dedicated service classes
//
// 2. SERVICE NAMING:
//    - Include timing-related keywords in class name
//    - OR use @TimingAllowed() annotation
//    - OR use // timing-allowed comment above class
//
// 3. TESTABILITY:
//    - Services can be mocked in tests
//    - Tests run fast without waiting for real delays
//    - Use fakeAsync for testing timing services themselves
//
// 4. SINGLE RESPONSIBILITY:
//    - Service does one thing: manages timing
//    - Business logic does one thing: coordinates operations
//    - Clear separation of concerns
//
// 5. DISPOSAL:
//    - Always cancel timers in dispose()
//    - Prevent memory leaks
//    - Clean up resources properly
//
// 6. ABSTRACTION BENEFITS:
//    - Easy to swap implementations
//    - Can add logging/monitoring
//    - Centralized timing configuration
//    - Reusable across app

// ============================================================================
// COMMON TIMING PATTERNS TO ENCAPSULATE
// ============================================================================

// These should all be in service classes:
// - Timer() - one-shot delays
// - Timer.periodic() - repeated execution
// - Future.delayed() - async delays
// - Stream.periodic() - periodic stream events
// - debounceTime() (rxdart) - debouncing streams
// - throttleTime() (rxdart) - throttling streams
// - interval() (rxdart) - interval streams
// - RestartableTimer() (async package) - restartable delays
// - CancelableOperation() (async package) - cancelable operations
// - Any duration-based callback patterns

class VoidCallback {
  void call() {}
}
