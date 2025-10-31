---
id: m01-e03-t03
title: Filter State Management and Integration
epic: m01-e03
milestone: m01
status: pending
---

# Task: Filter State Management and Integration

## Context
Part of Category and Proximity Filtering (m01-e03) in Browse and Discover Local Flyers (m01).

Implements the state management layer for filters using Riverpod, including session persistence, real-time feed updates, API integration with debouncing, and handling of edge cases like missing location permissions.

## Implementation Guide for LLM Agent

### Objective
Create a Riverpod-based filter state provider that manages category and proximity filters, persists state during app session, integrates with backend API with debounced calls, and triggers real-time feed updates.

### Steps
1. Create filter state provider
   - Create `pockitflyer_app/lib/features/feed/providers/filter_provider.dart`
   - Define `StateNotifierProvider<FilterNotifier, FilterState>`
   - FilterNotifier class extends `StateNotifier<FilterState>`
   - FilterState uses Freezed model from m01-e03-t02: `FilterState(List<String> categories, bool nearMe)`
   - Initial state: `FilterState(categories: [], nearMe: false)` (no filters active)

2. Implement filter state mutation methods
   - `void toggleCategory(String category)`: add/remove category from list
     - If category in list → remove it
     - If category not in list → add it
     - Update state immutably: `state = state.copyWith(categories: updatedList)`
   - `void setProximity(bool enabled)`: set nearMe flag
     - Update state: `state = state.copyWith(nearMe: enabled)`
   - `void clearAllFilters()`: reset to initial state
     - Update state: `state = FilterState(categories: [], nearMe: false)`

3. Integrate filter state with feed data provider
   - Modify existing feed provider (from m01-e02, likely `flyer_feed_provider.dart`)
   - Add dependency on `filterProvider`
   - When filter state changes → trigger API call with new filter parameters
   - Construct API query parameters from FilterState:
     - `categories`: join list with comma (e.g., "events,nightlife")
     - `near_me`: boolean value
     - `lat`, `lng`: user's current location (obtain from location service or stored state)
   - Example API call: `GET /api/flyers/?categories=events,nightlife&near_me=true&lat=47.3769&lng=8.5417`

4. Implement debouncing for filter changes
   - Use `Timer` or `debounce` utility to delay API calls
   - Wait 300ms after last filter change before triggering API call
   - Prevents excessive API calls during rapid filter toggling
   - Cancel pending timer if new filter change occurs before timeout
   - After debounce timeout → fetch filtered feed data

5. Add session persistence for filter state
   - Use in-memory state only (no persistent storage needed for MVP)
   - Filter state persists during app session (until app is closed/killed)
   - When user navigates away from feed and returns → filters remain active
   - No need for SharedPreferences or database (keep it simple)

6. Handle edge cases
   - **No location permission**: If nearMe=true but location unavailable:
     - Show user-friendly error message (e.g., "Enable location to use Near Me filter")
     - Option 1: Disable proximity filter automatically + show snackbar
     - Option 2: Keep filter active but show error state in feed
     - Recommend Option 1 for better UX
   - **No results**: If filters return empty feed:
     - Display empty state message: "No flyers match your filters. Try adjusting them."
     - Show "Clear Filters" button in empty state
   - **API errors**: If filter API call fails:
     - Show error message, keep current feed data visible
     - Allow user to retry or clear filters

7. Wire filter UI to state provider
   - Modify `FlyerFilterBar` widget (from m01-e03-t02)
   - Replace placeholder callbacks with Riverpod provider calls:
     - `onCategoryChanged`: call `filterNotifier.toggleCategory(category)`
     - `onProximityChanged`: call `filterNotifier.setProximity(enabled)`
   - Use `ref.watch(filterProvider)` to sync UI state with provider state
   - Ensure UI updates reactively when state changes

8. Update feed screen to display filtered results
   - Modify `FeedScreen` (from m01-e02)
   - Watch `filterProvider` for changes
   - When filter state changes → feed provider automatically fetches filtered data (via dependency)
   - Display loading indicator during filter API calls
   - Maintain scroll position when possible (avoid jumping to top on filter change)

9. Create comprehensive test suite
   - **Unit tests** for FilterNotifier (8-10 tests):
     - toggleCategory adds category if not present
     - toggleCategory removes category if present
     - setProximity updates nearMe flag
     - clearAllFilters resets to initial state
     - Verify state immutability (original state not mutated)
   - **Integration tests** with mocked API (6-8 tests):
     - Filter change triggers API call with correct parameters
     - Debouncing works (multiple rapid changes → single API call after delay)
     - Filter state persists during navigation (navigate away + return → filters still active)
     - No location permission → proximity filter disabled + error message
     - No results → empty state displayed
     - API error → error message displayed
     - Combined category + proximity filters → correct API parameters
     - Clear filters → API call with no filter parameters

10. Add loading and error UI states
    - Create `FilterLoadingIndicator` widget (optional, could reuse feed loading indicator)
    - Show loading indicator below filter bar when fetching filtered data
    - Show error snackbar or inline message on API errors
    - Use Flutter `SnackBar` or custom error widget

### Acceptance Criteria
- [ ] Filter state provider manages categories and proximity state [Test: toggle filters, verify state updates]
- [ ] Filter changes trigger debounced API calls [Test: rapid filter changes → single API call after 300ms]
- [ ] Filtered feed data displays correctly [Test: apply filters, verify feed shows only matching flyers]
- [ ] Filter state persists during app session [Test: navigate away, return, filters still active]
- [ ] No location permission handled gracefully [Test: proximity filter without location → error message]
- [ ] No results shows empty state with clear option [Test: filters with zero matches → helpful message]
- [ ] API errors handled gracefully [Test: simulate API failure, verify error message]
- [ ] UI updates reactively to state changes [Test: filter changes immediately update UI]
- [ ] All tests pass with >85% coverage on provider and integration logic

### Files to Create/Modify
- `pockitflyer_app/lib/features/feed/providers/filter_provider.dart` - NEW: filter state provider (Riverpod StateNotifier)
- `pockitflyer_app/lib/features/feed/providers/flyer_feed_provider.dart` - MODIFY: integrate filter dependency, construct API query params
- `pockitflyer_app/lib/features/feed/widgets/flyer_filter_bar.dart` - MODIFY: wire UI to provider (replace placeholder callbacks)
- `pockitflyer_app/lib/features/feed/screens/feed_screen.dart` - MODIFY: handle loading/error states for filters
- `pockitflyer_app/lib/core/utils/debounce.dart` - NEW: debounce utility (if not already exists)
- `pockitflyer_app/test/features/feed/providers/filter_provider_test.dart` - NEW: unit tests for FilterNotifier
- `pockitflyer_app/test/features/feed/integration/filter_integration_test.dart` - NEW: integration tests for filter flow

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: FilterNotifier state mutations, immutability verification, edge cases
- **Integration tests**: Full filter flow with mocked API, debouncing, persistence, error handling, no location permission, empty results

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter/Riverpod conventions
- [ ] No console errors or warnings
- [ ] Filter changes update feed in real-time (smooth UX)
- [ ] Edge cases handled gracefully (no location, no results, errors)
- [ ] Changes committed with reference to task ID (m01-e03-t03)
- [ ] Ready for comprehensive testing (m01-e03-t04)

## Dependencies
- Requires: m01-e03-t01 (Backend API supports filters), m01-e03-t02 (Filter UI components exist), m01-e02 (Feed provider exists)
- Requires (partial): m01-e05 (Location services for proximity filter, fallback if unavailable)
- Blocks: m01-e03-t04 (Integration Testing)

## Technical Notes
- Use Riverpod `StateNotifierProvider` for filter state (standard pattern)
- Debouncing: Use `Timer(Duration(milliseconds: 300), () => fetchData())` or dedicated debounce utility
- Filter state is part of app state, not URL state (no need for go_router query params)
- Location permission: Check if location available before enabling proximity filter (graceful degradation)
- Maintain scroll position: Use `ScrollController.keepScrollOffset = true` or equivalent
- API integration: Modify existing feed provider to accept filter parameters (don't duplicate API logic)
- Empty state: Consider reusing existing empty state widget from feed (if exists) or create new one

## References
- Riverpod StateNotifier: https://riverpod.dev/docs/providers/state_notifier_provider
- Freezed copyWith for immutable updates: https://pub.dev/packages/freezed
- Debouncing in Dart: https://api.dart.dev/stable/dart-async/Timer-class.html
- Existing feed provider implementation (m01-e02)
- Backend filter API (m01-e03-t01)
- Flutter SnackBar: https://api.flutter.dev/flutter/material/ScaffoldMessenger/showSnackBar.html
