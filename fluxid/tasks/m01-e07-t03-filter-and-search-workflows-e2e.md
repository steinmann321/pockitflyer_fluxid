---
id: m01-e07-t03
title: Filter and Search Workflows E2E Validation
epic: m01-e07
milestone: m01
status: pending
---

# Task: Filter and Search Workflows E2E Validation

## Context
Part of E2E Milestone Validation (No Mocks) (m01-e07) in Milestone 1: Anonymous Flyer Browsing (m01).

Validates category filtering, proximity filtering, and search functionality end-to-end with real backend. Tests ensure filters update the feed correctly via API calls, search provides real-time results, multiple filters work together, and clearing filters restores full feed.

## Implementation Guide for LLM Agent

### Objective
Create comprehensive integration tests that validate filtering and search work end-to-end: category filters call real API with correct parameters, proximity filters use real distance calculations, search queries are processed by backend, and UI updates correctly with filtered results.

### Steps

1. **Create E2E filter/search test file** in `pockitflyer_app/integration_test/filter_search_test.dart`
   - Import setup from `setup.dart`
   - Use `setupE2ETests()` and `teardownE2ETests()`
   - Tag with `tags: ['e2e', 'tdd_red']` initially

2. **Test: Category filter - Events only**
   - Launch app and wait for feed load
   - Record initial flyer count (should be ~20-30)
   - Tap/select "Events" category filter
   - Wait for feed to update
   - Verify API call made with `category=events` parameter (check logs or network traffic)
   - Query backend API: `GET /api/flyers/?category=events`
   - Verify feed shows only Events flyers (check all visible cards)
   - Verify flyer count matches API response count
   - Verify category badges all show "Events"
   - Take screenshot: `filter_events_only.png`

3. **Test: Category filter - Nightlife only**
   - Launch app and wait for feed load
   - Tap/select "Nightlife" category filter
   - Wait for feed to update
   - Verify API call with `category=nightlife`
   - Verify feed shows only Nightlife flyers
   - Verify flyer count decreases from unfiltered feed
   - Verify category badges all show "Nightlife"

4. **Test: Category filter - Service only**
   - Launch app and wait for feed load
   - Tap/select "Service" category filter
   - Wait for feed to update
   - Verify API call with `category=service`
   - Verify feed shows only Service flyers
   - Verify category badges all show "Service"

5. **Test: Proximity filter - Within 10km**
   - Launch app and wait for feed load
   - Grant location permission if prompted (or configure test location)
   - Apply proximity filter: "Within 10km"
   - Wait for feed to update
   - Verify API call with `max_distance=10` and `user_lat`/`user_long` parameters
   - Query backend API with same parameters
   - Verify all visible flyers show distance ≤ 10km
   - Verify flyer count ≤ unfiltered count
   - Scroll through feed and spot-check distances

6. **Test: Proximity filter - Within 5km**
   - Launch app and wait for feed load
   - Apply proximity filter: "Within 5km"
   - Verify API call with `max_distance=5`
   - Verify all visible flyers show distance ≤ 5km
   - Verify flyer count ≤ 10km filter count (stricter filter)

7. **Test: Combined filters - Events within 10km**
   - Launch app and wait for feed load
   - Apply category filter: "Events"
   - Apply proximity filter: "Within 10km"
   - Wait for feed to update
   - Verify API call with `category=events&max_distance=10&user_lat=X&user_long=Y`
   - Query backend API with same parameters
   - Verify all visible flyers:
     - Category badge shows "Events"
     - Distance ≤ 10km
   - Verify flyer count matches API response
   - Verify count ≤ either filter alone (intersection of filters)

8. **Test: Search filters feed in real-time**
   - Launch app and wait for feed load
   - Record initial flyer count
   - Enter search query: "party" (or term from test data)
   - Wait for feed to update (should be real-time, <500ms)
   - Verify API call with `search=party` parameter
   - Query backend API: `GET /api/flyers/?search=party`
   - Verify feed shows only matching flyers
   - Verify search term appears in titles or descriptions (spot-check)
   - Verify flyer count ≤ initial count

9. **Test: Search with special characters**
   - Launch app and wait for feed load
   - Enter search query with special characters: "café & bar"
   - Verify API encodes query correctly (%20, %26, etc.)
   - Verify backend processes query without errors
   - Verify results are relevant (if test data includes such terms)
   - Clear search and verify feed returns to unfiltered

10. **Test: Search combined with category filter**
    - Launch app and wait for feed load
    - Apply category filter: "Nightlife"
    - Enter search query: "music"
    - Verify API call with `category=nightlife&search=music`
    - Query backend API with same parameters
    - Verify all visible flyers:
      - Category badge shows "Nightlife"
      - Title or description contains "music"
    - Verify flyer count matches API response

11. **Test: Clear single filter**
    - Launch app and wait for feed load
    - Apply category filter: "Events"
    - Verify feed is filtered (count reduced)
    - Clear category filter (tap "Clear" or "All categories")
    - Verify API call with no `category` parameter
    - Verify feed returns to unfiltered state (count increases)
    - Verify all categories visible again

12. **Test: Clear all filters**
    - Launch app and wait for feed load
    - Apply multiple filters: category "Events", proximity "10km", search "party"
    - Verify feed is heavily filtered (small count)
    - Tap "Clear all filters" button (or clear each individually)
    - Verify API call with no filter parameters
    - Verify feed returns to full unfiltered state
    - Verify flyer count matches original (~20-30)

13. **Test: Empty filter results handled gracefully**
    - Launch app and wait for feed load
    - Apply filters that return no results:
      - Category: "Service"
      - Proximity: "1km" (assuming no service flyers that close)
      - Search: "nonexistentterm12345"
    - Verify API call returns empty list
    - Verify UI shows empty state message
    - Verify no errors or crashes
    - Verify helpful message: "No flyers match your filters"
    - Clear filters and verify feed restores

14. **Test: Filter persistence across navigation** (if applicable)
    - Launch app and apply filter: "Events"
    - Verify feed is filtered
    - Navigate to flyer detail (tap flyer)
    - Navigate back to feed
    - Verify filter is still active (feed still shows Events only)
    - Verify UI shows active filter indicator

15. **Verify all tests and mark green**
    - Run all tests: `flutter test integration_test/filter_search_test.dart`
    - Verify all tests pass
    - Check screenshots for visual confirmation
    - Review API logs to confirm correct parameters
    - Change tag to `tags: ['e2e', 'tdd_green']`

### Acceptance Criteria
- [ ] Category filters (Events/Nightlife/Service) query backend with correct parameters [Test: verify API calls with `category=X`]
- [ ] Proximity filters (5km/10km) query backend with user location and max_distance [Test: verify API calls with `max_distance=X&user_lat=Y&user_long=Z`]
- [ ] Search queries backend in real-time with search parameter [Test: type search, verify API call with `search=query`]
- [ ] Combined filters work together (category + proximity + search) [Test: apply multiple, verify API parameters combined]
- [ ] Filtered feed displays only matching flyers [Test: compare UI against API response]
- [ ] Filter counts match backend responses [Test: query API, compare flyer counts]
- [ ] Special characters in search are handled correctly [Test: search "café & bar", verify encoding and results]
- [ ] Empty filter results show helpful message [Test: impossible filter combo, verify empty state]
- [ ] Clearing filters restores full feed [Test: clear all, verify count returns to ~20-30]
- [ ] Filter state persists across navigation [Test: filter → detail → back, verify filter still active]

### Files to Create/Modify
- `pockitflyer_app/integration_test/filter_search_test.dart` - NEW: E2E filter and search tests

### Testing Requirements
**Note**: This task creates E2E integration tests. These tests ARE the tests.

- **E2E integration tests**: All tests in filter_search_test.dart validate real backend, real filtering, real search
- **No unit tests needed**: This task is integration testing, not unit testing

### Definition of Done
- [ ] Code written and all tests pass
- [ ] Tests verify API calls with correct filter/search parameters
- [ ] All filter combinations tested (category, proximity, search, combined)
- [ ] Empty results handled gracefully
- [ ] Filter clearing works correctly
- [ ] No mocks used anywhere (code review confirms)
- [ ] Changes committed with reference to task ID (m01-e07-t03)
- [ ] All tests marked `tdd_green` after passing
- [ ] Ready for m01-e07-t04 (location and navigation E2E tests)

## Dependencies
- m01-e07-t01 (E2E test environment setup) - must be complete
- m01-e03 (Category/Proximity Filtering) - must be complete
- m01-e04 (Search and Updates) - must be complete
- Real backend running with diverse test data
- Flutter integration_test package

## Technical Notes

### Test Data Requirements
Tests assume test data from m01-e07-t01 includes:
- Flyers in all three categories (Events: ~10, Nightlife: ~8, Service: ~10)
- Various distances from test user location (0-50km spread)
- Search terms in titles/descriptions that can be tested
- At least one impossible filter combo (e.g., "Service" + "Within 1km" = 0 results)

### API Parameter Verification
Critical to verify backend receives correct parameters:
- Check network logs or use Flutter's `dio` interceptor to log requests
- Compare expected URL parameters against actual API calls
- Example: `/api/flyers/?category=events&max_distance=10&user_lat=37.7749&user_long=-122.4194&search=party`

### Location Permission Handling
Proximity filters require location access:
- Tests should grant location permission (or use mocked coordinates in integration test config)
- If permission denied, verify proximity filter is disabled/hidden
- Use test coordinates that match test data distances (e.g., center of test flyer distribution)

### Real-Time Search Timing
Per epic performance targets: <500ms from typing to UI update
- Implement debouncing in search input (wait 300ms after last keystroke)
- Verify API call happens after debounce, not on every character
- Measure time from search input to feed update (should be <500ms total)

### Filter State Management
Filters should persist across navigation:
- Use state management (Provider, Riverpod, Bloc, etc.)
- When navigating to detail and back, filters remain active
- Verify this by checking API call on return (should include filter parameters)

### Empty State Design
When filters return no results:
- Show helpful message: "No flyers match your filters"
- Suggest action: "Try adjusting your filters"
- Show "Clear all filters" button prominently
- Do NOT show error or crash

### Flutter Integration Test Patterns for Filters
```dart
testWidgets('Category filter - Events only', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Apply filter
  await tester.tap(find.text('Events'));
  await tester.pumpAndSettle();

  // Verify API call (requires network logging)
  // Verify UI
  final categoryBadges = find.byWidgetPredicate(
    (widget) => widget is CategoryBadge && widget.category == 'Events'
  );
  expect(categoryBadges, findsWidgets);

  // Query backend API to verify
  final response = await http.get('http://localhost:8001/api/flyers/?category=events');
  final apiCount = json.decode(response.body)['results'].length;

  // Count UI flyers
  final flyerCards = find.byType(FlyerCard);
  expect(tester.widgetList(flyerCards).length, equals(apiCount));
}, tags: ['e2e', 'tdd_green']);
```

### Handling Filter UI Variations
UI for filters may vary:
- Dropdown selects
- Button groups
- Chips
- Search bar
Adapt finder logic to match actual UI implementation

## References
- Flutter Integration Testing: https://docs.flutter.dev/testing/integration-tests
- Flutter Finder: https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html
- Project CLAUDE.md for TDD markers
- Epic m01-e07 for E2E testing requirements
- m01-e07-t01 for E2E infrastructure setup
- m01-e03 for filtering implementation details
- m01-e04 for search implementation details
