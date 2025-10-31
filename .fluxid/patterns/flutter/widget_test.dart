/// PATTERN: Widget Test - Testing Individual Widget Behavior
///
/// WHY THIS IS IMPORTANT:
/// Widget tests verify that a single widget renders correctly and responds to input.
/// Common mistakes include using pumpAndSettle() which causes flaky tests, using
/// text-based finders which break with i18n changes, and using real network images
/// which fail in test environments (HTTP 400 errors).
///
/// WHEN TO USE:
/// - Testing widget rendering and layout
/// - Verifying widget responds to user input (tap, drag, etc.)
/// - Testing widget state changes in isolation
/// - Validating widget appearance for different states (loading, error, success)
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
// BASIC WIDGET RENDERING
// ============================================================================

void exampleBasicRenderTest() {
  testWidgets('renders widget with correct structure', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyWidget()),
    ));

    // ✅ ALWAYS: Use pump() once to render initial frame
    await tester.pump();

    // ✅ ALWAYS: Find widgets by Key, not by text
    expect(find.byKey(const Key('widget_container')), findsOneWidget);
    expect(find.byKey(const Key('widget_title')), findsOneWidget);

    // ❌ NEVER: Use find.text() - breaks with i18n and text changes
    // expect(find.text('My Widget'), findsOneWidget); // WRONG
  }, tags: ['tdd_green']);
}

// ============================================================================
// USER INPUT TESTING
// ============================================================================

void exampleTapTest() {
  testWidgets('responds to tap events', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyButton()),
    ));
    await tester.pump();

    // ✅ ALWAYS: Find interactive widgets by Key
    final buttonFinder = find.byKey(const Key('my_button'));
    expect(buttonFinder, findsOneWidget);

    // Tap the button
    await tester.tap(buttonFinder);

    // ✅ ALWAYS: Pump after user interaction to rebuild
    await tester.pump();

    // Verify state changed
    expect(find.byKey(const Key('button_pressed_indicator')), findsOneWidget);

    // ❌ NEVER: Use pumpAndSettle() after tap
    // await tester.pumpAndSettle(); // WRONG - unnecessary and can cause timeouts
  }, tags: ['tdd_green']);
}

void exampleDragTest() {
  testWidgets('responds to drag gestures', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MySlider()),
    ));
    await tester.pump();

    final sliderFinder = find.byKey(const Key('my_slider'));

    // ✅ ALWAYS: Use drag() with explicit offset
    await tester.drag(sliderFinder, const Offset(100, 0));
    await tester.pump(); // Process the drag

    // Verify slider value changed
    expect(find.byKey(const Key('slider_value_50')), findsOneWidget);
  }, tags: ['tdd_green']);
}

// ============================================================================
// WIDGET STATE TESTING
// ============================================================================

void exampleStateTest() {
  testWidgets('displays different states correctly', (tester) async {
    // Test loading state
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(
        home: MyStatefulWidget(isLoading: true),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('loading_indicator')), findsOneWidget);

    // Test loaded state
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(
        home: MyStatefulWidget(isLoading: false),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('loaded_content')), findsOneWidget);

    // ✅ ALWAYS: Use separate pumpWidget calls for testing different states
    // Don't try to transition state within a single test - use integration tests for that
  }, tags: ['tdd_green']);
}

// ============================================================================
// ASYNC WIDGET TESTING (with mocked services)
// ============================================================================

void exampleAsyncWidgetTest() {
  testWidgets('handles async operations with mock service', (tester) async {
    // ✅ ALWAYS: Mock services to control timing
    final mockService = MockDataService(delay: const Duration(milliseconds: 50));

    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: MaterialApp(
        home: MyAsyncWidget(service: mockService),
      ),
    ));
    await tester.pump();

    // Initial state
    expect(find.byKey(const Key('loading')), findsOneWidget);

    // ✅ ALWAYS: Wait for the exact duration your mock uses
    await tester.pump(const Duration(milliseconds: 50));

    // ✅ ALWAYS: Pump once more to rebuild after async completes
    await tester.pump();

    // Verify final state
    expect(find.byKey(const Key('loaded_data')), findsOneWidget);

    // ❌ NEVER: Use pumpAndSettle() - it's unpredictable with async
    // await tester.pumpAndSettle(); // WRONG
  }, tags: ['tdd_green']);
}

// ============================================================================
// TESTING WITH IMAGES
// ============================================================================

void exampleImageTest() {
  testWidgets('displays images correctly', (tester) async {
    // ✅ ALWAYS: Use Image.memory() or asset images in tests
    final testImage = Image.memory(
      Uint8List(0), // Empty byte array for test
      key: const Key('test_image'),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: MaterialApp(home: testImage),
    ));
    await tester.pump();

    expect(find.byKey(const Key('test_image')), findsOneWidget);

    // ❌ NEVER: Use NetworkImage in tests
    // await tester.pumpWidget(MaterialApp(
    //   home: Image.network('https://example.com/image.jpg'), // WRONG
    // ));
    // NetworkImage causes HTTP 400 errors in test environment and tests timeout
  }, tags: ['tdd_green']);
}

// ============================================================================
// FORM VALIDATION TESTING
// ============================================================================

void exampleFormTest() {
  testWidgets('validates form input', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyForm()),
    ));
    await tester.pump();

    // ✅ ALWAYS: Use Keys for form fields
    final emailField = find.byKey(const Key('email_field'));
    expect(emailField, findsOneWidget);

    // Enter invalid email
    await tester.enterText(emailField, 'invalid-email');
    await tester.pump(); // Process text input

    // Trigger validation (e.g., tap submit)
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump(); // Show validation errors

    // Verify validation error appears
    expect(find.byKey(const Key('email_error')), findsOneWidget);
  }, tags: ['tdd_green']);
}

// ============================================================================
// ANIMATION TESTING
// ============================================================================

void exampleAnimationTest() {
  testWidgets('runs animation correctly', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [timingConfigProvider.overrideWithValue(const TestTimingConfig())],
      child: const MaterialApp(home: MyAnimatedWidget()),
    ));
    await tester.pump();

    // Start animation
    await tester.tap(find.byKey(const Key('start_animation_button')));
    await tester.pump(); // Start animation

    // ✅ ALWAYS: Advance animation with specific durations
    await tester.pump(const Duration(milliseconds: 100)); // Advance 100ms
    expect(find.byKey(const Key('animation_midpoint')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100)); // Advance another 100ms
    expect(find.byKey(const Key('animation_complete')), findsOneWidget);

    // ❌ NEVER: Use pumpAndSettle() for animations
    // await tester.pumpAndSettle(); // WRONG - can timeout with infinite animations
  }, tags: ['tdd_green']);
}

// ============================================================================
// KEY PRINCIPLES
// ============================================================================

// 1. USE KEYS FOR EVERYTHING:
//    - Find widgets by Key, not text
//    - Keys are stable contracts
//    - Works with internationalization
//
// 2. PUMP PATTERN:
//    - pump() → render initial frame
//    - pump() → after user interaction
//    - pump(Duration) → advance time for async/animations
//    - pump() → rebuild after async completes
//
// 3. NEVER use pumpAndSettle():
//    - Unpredictable with animations
//    - Timeouts with NetworkImage
//    - Makes tests flaky
//
// 4. MOCK EVERYTHING ASYNC:
//    - Services with controllable delays
//    - Use Image.memory() not Image.network()
//    - Test success and error paths separately
//
// 5. ONE WIDGET PER TEST:
//    - Widget tests test single widget behavior
//    - Use integration tests for multi-widget flows
//    - Keep tests simple and focused

// ============================================================================
// DUMMY CLASSES (for example compilation)
// ============================================================================

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MyButton extends StatelessWidget {
  const MyButton({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MySlider extends StatelessWidget {
  const MySlider({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MyStatefulWidget extends StatelessWidget {
  final bool isLoading;
  const MyStatefulWidget({super.key, required this.isLoading});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MyAsyncWidget extends StatelessWidget {
  final MockDataService service;
  const MyAsyncWidget({super.key, required this.service});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MockDataService {
  final Duration delay;
  MockDataService({required this.delay});
}

class MyForm extends StatelessWidget {
  const MyForm({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MyAnimatedWidget extends StatelessWidget {
  const MyAnimatedWidget({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class Uint8List {
  Uint8List(int size);
}
