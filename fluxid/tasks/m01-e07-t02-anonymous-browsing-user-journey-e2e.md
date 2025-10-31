---
id: m01-e07-t02
title: Anonymous Browsing User Journey E2E Validation
epic: m01-e07
milestone: m01
status: pending
---

# Task: Anonymous Browsing User Journey E2E Validation

## Context
Part of E2E Milestone Validation (No Mocks) (m01-e07) in Milestone 1: Anonymous Flyer Browsing (m01).

Validates the core anonymous browsing experience end-to-end: launch app, load feed from real backend, display flyer cards, scroll through feed, view images in carousels, and pull-to-refresh. All tests run against real Django backend with real database and geopy service.

## Implementation Guide for LLM Agent

### Objective
Create comprehensive integration tests that validate the anonymous user's browsing experience works end-to-end with real backend, ensuring flyers load correctly, images display properly, scrolling is smooth, and pull-to-refresh updates the feed.

### Steps

1. **Create base E2E browsing test** in `pockitflyer_app/integration_test/anonymous_browsing_test.dart`
   - Import setup from `setup.dart`
   - Use `setupE2ETests()` and `teardownE2ETests()`
   - Tag with `tags: ['e2e', 'tdd_red']` initially

2. **Test: App launches and feed loads**
   - Launch app using `launchApp()` helper
   - Wait for feed to populate (use `waitForFeedLoad()`)
   - Verify at least 20 flyers are displayed (match test data count)
   - Verify feed is scrollable
   - Verify no error messages displayed
   - Take screenshot: `app_launch_success.png`

3. **Test: Flyer cards display correct data**
   - Query backend API directly to get first 5 flyers
   - For each flyer, find corresponding card in feed
   - Verify card displays:
     - Correct title (exact match)
     - Correct creator name
     - Correct category badge (Events/Nightlife/Service)
     - Distance text present (format: "X.X km away" or "Location unavailable")
     - Image loaded (not placeholder/error)
   - Verify card layout is correct (image, title, creator, badges visible)

4. **Test: Feed scrolling works smoothly**
   - Launch app and wait for feed
   - Record initial visible flyers (get titles/positions)
   - Scroll down 5 full screens
   - Verify new flyers become visible
   - Verify scrolling is smooth (no frame drops - check driver logs)
   - Scroll back to top
   - Verify original flyers are visible again
   - Verify scroll position is maintained correctly

5. **Test: Image carousels work correctly**
   - Find flyer with multiple images (>1 image_url in test data)
   - Tap to expand image carousel (if required by UI)
   - Verify all images are present (count matches backend data)
   - Swipe through all images
   - Verify swipe gestures work smoothly
   - Verify image indicators update (dots/pagination)
   - Close carousel and verify return to feed

6. **Test: Flyer expands to detail view**
   - Find specific flyer in feed (by title)
   - Tap to expand/open detail view
   - Verify detail view shows:
     - Full description (not truncated)
     - All images in carousel
     - Creator information
     - Location details
     - Category
     - Valid dates (if displayed)
   - Verify back navigation returns to feed
   - Verify feed position is maintained (doesn't scroll to top)

7. **Test: Pull-to-refresh updates feed**
   - Launch app and wait for feed load
   - Record initial flyer count
   - Perform pull-to-refresh gesture
   - Verify loading indicator appears
   - Wait for refresh to complete
   - Verify feed reloads (check API call in logs)
   - Verify flyer count matches backend (should be same for static test data)
   - Verify no errors during refresh

8. **Test: Empty feed handled gracefully** (if applicable)
   - Modify test data temporarily to have 0 flyers (or use test configuration)
   - Launch app
   - Verify empty state message displayed
   - Verify no errors or crashes
   - Verify helpful message (e.g., "No flyers found")
   - Restore test data

9. **Test: Multiple categories displayed in feed**
   - Launch app and load feed
   - Scroll through entire feed (to bottom)
   - Collect all visible category badges
   - Verify all three categories present (Events, Nightlife, Service)
   - Verify category distribution roughly matches test data (not strict counts)

10. **Verify all tests and mark green**
    - Run all tests: `flutter test integration_test/anonymous_browsing_test.dart`
    - Verify all tests pass
    - Check screenshots for visual confirmation
    - Review logs for any warnings or errors
    - Change tag to `tags: ['e2e', 'tdd_green']`

### Acceptance Criteria
- [ ] App launches successfully and feed loads from real backend [Test: app_launch_success screenshot shows populated feed]
- [ ] Flyer cards display correct title, creator, category, distance, image [Test: verify against backend API data]
- [ ] Feed scrolling is smooth and responsive [Test: scroll through 50+ flyers, no frame drops]
- [ ] Image carousels support swiping through multiple images [Test: multi-image flyer, swipe through all]
- [ ] Flyer detail view shows complete information [Test: tap flyer, verify all fields present]
- [ ] Pull-to-refresh reloads feed from backend [Test: trigger refresh, verify API call, feed updates]
- [ ] Empty feed handled with helpful message [Test: configure empty test data, verify message]
- [ ] All three categories appear in feed [Test: scroll through feed, collect all categories, verify Events/Nightlife/Service present]
- [ ] Back navigation maintains feed scroll position [Test: open detail, go back, verify position]
- [ ] No errors or crashes during browsing [Test: review logs, no exceptions]

### Files to Create/Modify
- `pockitflyer_app/integration_test/anonymous_browsing_test.dart` - NEW: E2E browsing tests

### Testing Requirements
**Note**: This task creates E2E integration tests. These tests ARE the tests.

- **E2E integration tests**: All tests in anonymous_browsing_test.dart validate real backend, real UI, real user interactions
- **No unit tests needed**: This task is integration testing, not unit testing

### Definition of Done
- [ ] Code written and all tests pass
- [ ] Tests run against real backend (verified API calls in logs)
- [ ] Screenshots captured for visual validation
- [ ] All browsing flows work smoothly (verified by running tests)
- [ ] No mocks used anywhere (code review confirms)
- [ ] Changes committed with reference to task ID (m01-e07-t02)
- [ ] All tests marked `tdd_green` after passing
- [ ] Ready for m01-e07-t03 (filter and search E2E tests)

## Dependencies
- m01-e07-t01 (E2E test environment setup) - must be complete
- m01-e02 (Core Feed Display) - must be complete
- Real backend running with test data
- Flutter integration_test package

## Technical Notes

### Test Data Requirements
Tests assume test data from m01-e07-t01 includes:
- At least 20 flyers
- At least one flyer with 3+ images (for carousel test)
- All three categories represented
- Valid current dates
- Geocoded locations with coordinates

### API Verification Strategy
Some tests query backend API directly to get ground truth:
- Fetch flyers from `GET /api/flyers/` endpoint
- Compare UI display against API response
- This validates the full stack: API → Flutter → UI rendering

### Screenshot Strategy
Capture screenshots at key points:
- Initial app launch (populated feed)
- Flyer detail view
- Empty state (if tested)
- Image carousel
Screenshots are visual evidence tests are working

### Performance Expectations
Per epic performance targets:
- Feed scrolling: 60fps on iPhone 11+ (check driver performance logs)
- Image loading: Progressive, no blank screens
- Pull-to-refresh: Complete within 3s
If performance issues found, document but don't block task completion

### Flutter Integration Test Patterns
```dart
testWidgets('description', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle(); // Wait for animations

  // Find widgets
  final finder = find.byType(FlyerCard);
  expect(finder, findsWidgets);

  // Interact
  await tester.tap(finder.first);
  await tester.pumpAndSettle();

  // Verify
  expect(find.text('Expected Text'), findsOneWidget);
}, tags: ['e2e', 'tdd_green']);
```

### Handling Timing Issues
Integration tests may have timing sensitivities:
- Use `pumpAndSettle()` to wait for animations/loading
- Use explicit waits for network calls (with timeouts)
- Use `waitForFeedLoad()` helper for feed population
- If flaky, add small delays or better waiting logic

### Backend Verification
Before running tests, verify backend is ready:
- Check `http://localhost:8001/api/flyers/` returns 20-30 flyers
- Check images URLs are valid
- Check all flyers have geocoded coordinates
If backend data is bad, tests will fail - fix data first

## References
- Flutter Integration Testing: https://docs.flutter.dev/testing/integration-tests
- Flutter WidgetTester: https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html
- Project CLAUDE.md for TDD markers
- Epic m01-e07 for E2E testing requirements
- m01-e07-t01 for E2E infrastructure setup
