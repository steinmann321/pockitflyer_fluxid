/// PATTERN: Integration Test - Testing Widget Interactions and Async Flows
///
/// WHY THIS IS IMPORTANT:
/// Integration tests verify that multiple components work together correctly.
/// The most common failure mode is using pumpAndSettle() which causes flaky tests
/// because it waits indefinitely for animations and async operations to complete.
/// With NetworkImage or failed network requests, pumpAndSettle() will timeout,
/// causing tests to fail unpredictably.
///
/// WHEN TO USE:
/// - Testing user flows across multiple screens
/// - Verifying widget interactions (scrolling, tapping, swiping)
/// - Testing state changes that affect multiple widgets
/// - Validating pagination, pull-to-refresh, and load-more patterns
///
/// RELATED RULES:
/// - Rule: avoid_pump_and_settle (custom lint)
/// - Rule: prefer_keys_over_text_finders (custom lint)
/// - Rule: network_image_in_tests (custom lint)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pockitflyer_app/core/timing/timing_config.dart';
import 'package:pockitflyer_app/core/timing/timing_provider.dart';

// ============================================================================
// ASYNC OPERATION TESTING
// ============================================================================

void exampleAsyncTest() {
  testWidgets('loads data and displays it', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyScreen()),
    ));

    // ✅ ALWAYS: Use pump() to advance frames explicitly
    await tester.pump(); // Trigger initial build and microtasks

    // Verify loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // ✅ ALWAYS: Use pump() with duration to advance time predictably (override when needed)
    await tester.pump(const Duration(milliseconds: 100));

    // ❌ NEVER: Use pumpAndSettle() - it waits indefinitely for animations/async
    // await tester.pumpAndSettle(); // WRONG - causes flaky tests

    // ✅ ALWAYS: Pump again to rebuild after async operation completes
    await tester.pump();

    // Verify data is displayed using Keys (not text)
    expect(find.byKey(const Key('data_loaded_indicator')), findsOneWidget);
  }, tags: ['tdd_green']);
}

// ============================================================================
// SCROLLING AND PAGINATION
// ============================================================================

void exampleScrollTest() {
  testWidgets('loads more items on scroll', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyListScreen()),
    ));
    await tester.pump();

    // Wait for initial load
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(); // Rebuild after data loads

    // ✅ ALWAYS: Use drag() for scrolling
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump(); // Process the drag

    // ✅ ALWAYS: Wait for the specific duration your service uses
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(); // Rebuild after load more completes

    // Verify more items loaded
    expect(find.byKey(const Key('loading_more_indicator')), findsNothing);
  }, tags: ['tdd_green']);
}

// ============================================================================
// PULL-TO-REFRESH
// ============================================================================

void exampleRefreshTest() {
  testWidgets('refreshes on pull down', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    // ✅ ALWAYS: Use fling() for fast swipe gestures like pull-to-refresh
    await tester.fling(find.byType(MyScreen), const Offset(0, 300), 1000);
    await tester.pump(); // Start refresh animation

    await tester.pump(const Duration(milliseconds: 100)); // Wait for refresh
    await tester.pump(); // Rebuild after refresh completes

    // Verify refresh completed
    expect(find.byType(RefreshIndicator), findsOneWidget);
  }, tags: ['tdd_green']);
}

// ============================================================================
// STATE CHANGES AND UPDATES
// ============================================================================

void exampleStateChangeTest() {
  testWidgets('updates UI when state changes', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyScreen()),
    ));
    await tester.pump();

    // Trigger state change
    await tester.tap(find.byKey(const Key('update_button')));
    await tester.pump(); // Process the tap

    // ✅ ALWAYS: Pump once more to rebuild after state update
    await tester.pump();

    // Verify new state is reflected
    expect(find.byKey(const Key('updated_state_indicator')), findsOneWidget);
  }, tags: ['tdd_green']);
}

// ============================================================================
// ERROR HANDLING
// ============================================================================

void exampleErrorTest() {
  testWidgets('displays error state on failure', (tester) async {
    // Setup: Use a repository that throws errors
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyScreen()),
    ));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 100)); // Wait for error
    await tester.pump(); // Rebuild to show error state

    // Verify error state
    expect(find.byKey(const Key('error_indicator')), findsOneWidget);

    // Test retry
    await tester.tap(find.byKey(const Key('retry_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }, tags: ['tdd_green']);
}

// ============================================================================
// KEY PRINCIPLES
// ============================================================================

// 1. TIMING PATTERN:
//    - pump() → trigger action
//    - pump(Duration) → wait for async operation
//    - pump() → rebuild after completion
//
// 2. NEVER use pumpAndSettle():
//    - Causes timeouts with NetworkImage
//    - Unpredictable with animations
//    - Makes tests flaky
//
// 3. ALWAYS use Keys for finding widgets:
//    - Text changes frequently
//    - Keys are stable contracts
//    - Better for internationalization
//
// 4. MOCK async operations:
//    - Use repositories with controllable delays
//    - Test both success and error paths
//    - Verify state at each step

// ============================================================================
// DUMMY WIDGETS (for example compilation)
// ============================================================================

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
