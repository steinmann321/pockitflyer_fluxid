---
id: m03-e03-t06
epic: m03-e03
title: Feed Filter State Management
status: pending
priority: high
tdd_phase: red
---

# Task: Feed Filter State Management

## Objective
Create state management for feed filter selection that persists across app restarts, handles authentication changes, and coordinates with feed data loading. State resets to "All" when user logs out.

## Acceptance Criteria
- [ ] State stores current filter selection (all, favorites, following)
- [ ] State persists to local storage (shared preferences)
- [ ] State loads persisted value on app launch
- [ ] Changing filter triggers feed reload with new filter parameter
- [ ] State resets to "All" when user logs out
- [ ] State resets to "All" if persisted filter was favorites/following and user is now anonymous
- [ ] State exposes filter value to UI components
- [ ] State provides method to change filter
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Initial state is "All" filter
- Changing filter updates state correctly
- State persists to shared preferences on change
- State loads persisted value on initialization
- Logout resets filter to "All"
- Filter change triggers feed reload
- Anonymous users cannot activate favorites/following filters (resets to All)
- State synchronizes with authentication state changes

## Files to Modify/Create
- `pockitflyer_app/lib/state/feed_filter_state.dart` (create feed filter state)
- `pockitflyer_app/test/state/feed_filter_state_test.dart` (create state tests)

## Dependencies
- m02-e01-t06 (Authentication state management)
- Existing state management solution (Provider, Riverpod, Bloc, etc.)

## Notes
- Use shared_preferences package for persistence
- Storage key: 'feed_filter_selection'
- Filter enum: FilterType { all, favorites, following }
- Listen to authentication state changes to reset filter on logout
- Consider using ChangeNotifier, StateNotifier, or similar for reactivity
- State should invalidate/clear feed cache when filter changes
