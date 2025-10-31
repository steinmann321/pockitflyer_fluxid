---
id: m01-e01-t08
epic: m01-e01
title: Create Home Feed Screen with Pull-to-Refresh
status: pending
priority: high
tdd_phase: red
---

# Task: Create Home Feed Screen with Pull-to-Refresh

## Objective
Build main home screen with scrollable flyer feed, pull-to-refresh, and state management.

## Acceptance Criteria
- [ ] HomeScreen widget as app's main screen
- [ ] Displays vertical scrollable list of FlyerCard widgets
- [ ] Pull-to-refresh gesture to reload feed
- [ ] Loading states:
  - Initial load: full-screen loading indicator
  - Pull-to-refresh: native iOS refresh indicator
  - Pagination: loading indicator at bottom while fetching next page
- [ ] Empty state: friendly message and icon when no flyers available
- [ ] Error state: error message with retry button
- [ ] Infinite scroll: loads next page when user scrolls near bottom (80% threshold)
- [ ] State management: use Provider, Riverpod, or BLoC pattern
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Initial feed load success and failure
- Pull-to-refresh behavior
- Infinite scroll pagination
- All state transitions (loading, loaded, error, empty)
- Location permission integration
- User interaction (scroll, pull-to-refresh, retry button)
- Widget tests with mocked dependencies

## Files to Modify/Create
- `pockitflyer_app/lib/screens/home_screen.dart`
- `pockitflyer_app/lib/providers/feed_provider.dart` (or equivalent state management)
- `pockitflyer_app/lib/main.dart` (set HomeScreen as initial route)
- `pockitflyer_app/test/screens/home_screen_test.dart`
- `pockitflyer_app/test/providers/feed_provider_test.dart`

## Dependencies
- m01-e01-t05 (LocationService)
- m01-e01-t06 (FlyerCard widget)
- m01-e01-t07 (FeedApiClient and models)

## Notes
- Use Flutter's RefreshIndicator for pull-to-refresh
- Infinite scroll: detect scroll position via ScrollController
- Cache feed in memory during session (cleared on app restart)
- Show location permission prompt on first app launch before feed loads
- Empty state: "No flyers nearby. Pull to refresh or adjust your location."
- Error state: "Couldn't load flyers. Check your connection and try again."
