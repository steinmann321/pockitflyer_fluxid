/// PATTERN: Widget Consuming Service - Separation of Concerns
///
/// WHY THIS IS IMPORTANT:
/// Widgets should orchestrate services, not implement complex logic themselves.
/// This keeps widgets thin, testable, and focused on UI. Business logic and timing
/// operations belong in services, not in widget code. This pattern enables easy
/// mocking in tests and maintains clean architecture boundaries.
///
/// WHEN TO USE:
/// - Widgets that need debouncing (search, input validation)
/// - Widgets that need throttling (scroll handlers, analytics)
/// - Widgets that perform async operations
/// - Widgets that need scheduled updates
/// - Any widget with complex state management
///
/// RELATED RULES:
/// - Rule: direct_timing_operation (custom lint)
/// - See: service_with_timing.dart pattern

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockitflyer_app/core/timing/timing_config.dart';
import 'package:pockitflyer_app/core/timing/timing_provider.dart';

// ============================================================================
// SERVICE ABSTRACTIONS (would be in separate files)
// ============================================================================

class DebounceService {
  final TimingConfig timing;
  Timer? _timer;

  DebounceService({required this.timing});

  void call(VoidCallback callback, {Duration? overrideDelay}) {
    final delay = overrideDelay ?? timing.debounceDuration;
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class ThrottleService {
  final TimingConfig timing;
  DateTime? _lastExecutionTime;

  ThrottleService({required this.timing});

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

// ============================================================================
// SEARCH WITH DEBOUNCING
// ============================================================================

// ✅ ALWAYS: Use service for debouncing, not direct timing in widget
class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key});

  @override
  ConsumerState<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends ConsumerState<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  // ✅ CORRECT: Service injected/created in widget
  late final DebounceService _debouncer;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    final timing = ref.read(timingConfigProvider);
    _debouncer = DebounceService(timing: timing);
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text;
    // ✅ CORRECT: Widget orchestrates service, doesn't implement timing
    _debouncer.call(() {
      _performSearch(query);
    }, overrideDelay: ref.read(timingConfigProvider).debounceDuration);
  }

  Future<void> _performSearch(String query) async {
    // Actual search logic
    final results = await _searchApi(query);
    setState(() {
      _results = results;
    });
  }

  Future<List<String>> _searchApi(String query) async {
    // Mock API call
    return [];
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('search_field'),
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Search...'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) => Text(_results[index]),
          ),
        ),
      ],
    );
  }
}

// ❌ NEVER: Implement debouncing directly in widget
class BadSearchWidget extends StatefulWidget {
  const BadSearchWidget({super.key});

  @override
  State<BadSearchWidget> createState() => _BadSearchWidgetState();
}

class _BadSearchWidgetState extends State<BadSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer; // ❌ WRONG: Direct timing in widget

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    // ❌ WRONG: Direct Timer creation in widget
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_controller.text);
    });
  }

  void _performSearch(String query) {}

  @override
  Widget build(BuildContext context) => const Placeholder();
}

// ============================================================================
// SCROLL TRACKING WITH THROTTLING
// ============================================================================

// ✅ ALWAYS: Use service for throttling scroll events
class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends ConsumerState<InfiniteScrollList> {
  final ScrollController _scrollController = ScrollController();
  // ✅ CORRECT: Service for throttling
  late final ThrottleService _scrollThrottler;

  @override
  void initState() {
    super.initState();
    _scrollThrottler = ThrottleService(
      timing: ref.read(timingConfigProvider),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (position >= maxScroll * 0.8) {
      // ✅ CORRECT: Widget orchestrates service
      _scrollThrottler.call(() {
        _loadMoreItems();
      });
  }
  }

  void _loadMoreItems() {
    // Load more logic
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('infinite_scroll_list'),
      controller: _scrollController,
      itemBuilder: (context, index) => const Text('Item'),
    );
  }
}

// ============================================================================
// FORM WITH AUTO-SAVE
// ============================================================================

// ✅ ALWAYS: Use service for delayed operations
class AutoSaveForm extends StatefulWidget {
  const AutoSaveForm({super.key});

  @override
  State<AutoSaveForm> createState() => _AutoSaveFormState();
}

class _AutoSaveFormState extends ConsumerState<AutoSaveForm> {
  final TextEditingController _controller = TextEditingController();
  // ✅ CORRECT: Service for auto-save delay
  late final DebounceService _autoSaver;

  @override
  void initState() {
    super.initState();
    _autoSaver = DebounceService(timing: ref.read(timingConfigProvider));
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // ✅ CORRECT: Widget orchestrates auto-save through service
    _autoSaver.call(() {
      _saveFormData(_controller.text);
    }, overrideDelay: const Duration(seconds: 2));
  }

  Future<void> _saveFormData(String text) async {
    // Save to backend or local storage
  }

  @override
  void dispose() {
    _autoSaver.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('autosave_field'),
      controller: _controller,
      decoration: const InputDecoration(hintText: 'Type to auto-save...'),
    );
  }
}

// ============================================================================
// NOTIFICATION WITH AUTO-DISMISS
// ============================================================================

// ✅ ALWAYS: Use service for delayed actions
class NotificationBanner extends StatefulWidget {
  final String message;

  const NotificationBanner({super.key, required this.message});

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends ConsumerState<NotificationBanner> {
  bool _isVisible = true;
  // ✅ CORRECT: Service for delayed dismissal
  late final DelayedActionService _dismissService;

  @override
  void initState() {
    super.initState();
    _dismissService = DelayedActionService(timing: ref.read(timingConfigProvider));
    // ✅ CORRECT: Schedule dismissal through service
    _dismissService.delayedAction(() {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    }, overrideDelay: const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      key: const Key('notification_banner'),
      padding: const EdgeInsets.all(16),
      color: Colors.blue,
      child: Text(widget.message),
    );
  }
}

class DelayedActionService {
  final TimingConfig timing;

  DelayedActionService({required this.timing});

  Future<void> delayedAction(VoidCallback callback, {Duration? overrideDelay}) async {
    final delay = overrideDelay ?? timing.debounceDuration;
    await Future.delayed(delay);
    callback();
  }
}

// ============================================================================
// TESTING WIDGETS THAT USE SERVICES
// ============================================================================

// ✅ ALWAYS: Mock services in widget tests
void exampleWidgetTest() {
  // Note: In real test file
  // testWidgets('search debounces correctly', (tester) async {
  //   final mockDebouncer = MockDebounceService();
  //
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: SearchWidget(debouncer: mockDebouncer), // Inject mock
  //     ),
  //   );
  //
  //   // Type in search field
  //   await tester.enterText(find.byKey(Key('search_field')), 'query');
  //   await tester.pump();
  //
  //   // Verify debouncer was called
  //   verify(() => mockDebouncer.call(any())).called(1);
  // });
}

// ============================================================================
// DEPENDENCY INJECTION FOR TESTING
// ============================================================================

// ✅ BEST PRACTICE: Allow service injection for easy testing
class TestableSearchWidget extends ConsumerStatefulWidget {
  final DebounceService? debouncer; // Allow injection

  const TestableSearchWidget({super.key, this.debouncer});

  @override
  ConsumerState<TestableSearchWidget> createState() => _TestableSearchWidgetState();
}

class _TestableSearchWidgetState extends ConsumerState<TestableSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  late final DebounceService _debouncer;

  @override
  void initState() {
    super.initState();
    // ✅ Use injected service or create default from TimingConfig
    _debouncer = widget.debouncer ??
        DebounceService(timing: ref.read(timingConfigProvider));
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debouncer.call(() {
      _performSearch(_controller.text);
    });
  }

  void _performSearch(String query) {}

  @override
  void dispose() {
    if (widget.debouncer == null) {
      // Only dispose if we created it
      _debouncer.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}

// ============================================================================
// KEY PRINCIPLES
// ============================================================================

// 1. WIDGETS ORCHESTRATE, DON'T IMPLEMENT:
//    - Widgets call services, don't create timers
//    - Widgets coordinate flow, don't implement logic
//    - Keep widgets thin and focused on UI
//
// 2. SERVICE INJECTION:
//    - Create services in widget state
//    - Allow injection for testing
//    - Dispose services properly
//
// 3. CLEAR BOUNDARIES:
//    - Timing logic → in services
//    - Business logic → in controllers/providers
//    - UI logic → in widgets
//
// 4. TESTABILITY:
//    - Mock services in tests
//    - Test widget behavior, not service behavior
//    - Service tests are separate
//
// 5. DISPOSAL:
//    - Always dispose services in widget dispose()
//    - Prevent memory leaks
//    - Cancel pending operations
//
// 6. COMMON PATTERNS:
//    - Search debouncing: widget + DebounceService
//    - Scroll tracking: widget + ThrottleService
//    - Auto-save: widget + DebounceService
//    - Polling: widget + PollingService
//    - Delayed actions: widget + DelayedActionService
//    - Retry logic: widget + RetryService

// ============================================================================
// ANTI-PATTERNS TO AVOID
// ============================================================================

// ❌ Direct Timer in widget
// ❌ Future.delayed in widget build/initState
// ❌ Timer.periodic in widget
// ❌ Complex timing logic in widget
// ❌ Multiple timers managed in widget
// ❌ Forgetting to cancel timers in dispose

// ✅ Instead:
// - Use service abstractions
// - Inject services for testing
// - Keep widgets simple
// - Test services separately
// - Mock services in widget tests
