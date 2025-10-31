---
id: m03-e01-t05
epic: m03-e01
title: Implement Favorite State Management
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Favorite State Management

## Objective
Create state management for favorite operations using ChangeNotifier or equivalent. State handles optimistic updates, backend synchronization, rollback on error, and persists favorite status across app sessions.

## Acceptance Criteria
- [ ] FavoriteState class manages favorite status for all flyers
- [ ] toggleFavorite method performs optimistic update (immediate UI change)
- [ ] toggleFavorite calls backend API to persist change
- [ ] State rolls back optimistic update if backend call fails
- [ ] State handles concurrent favorite operations gracefully (queue or debounce)
- [ ] State persists favorite status to local storage (SharedPreferences or equivalent)
- [ ] State loads favorite status from local storage on app start
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- toggleFavorite updates state optimistically before backend call
- toggleFavorite calls correct API endpoint (POST for favorite, DELETE for unfavorite)
- toggleFavorite rolls back state on API error
- toggleFavorite handles network timeout gracefully
- Concurrent toggleFavorite calls handled correctly (no race conditions)
- State persists to local storage after successful backend sync
- State loads from local storage on initialization
- State emits notifications to listeners on state changes

## Files to Modify/Create
- `pockitflyer_app/lib/state/favorite_state.dart` (create FavoriteState class)
- `pockitflyer_app/test/state/favorite_state_test.dart` (create state tests)

## Dependencies
- m03-e01-t02 (favorite API endpoints must exist)
- m02-e01-t05 (token storage service for authentication)

## Notes
- Use Map<String, bool> to track favorite status by flyer_id
- Optimistic update pattern: update state → call API → rollback if error
- Consider using dio interceptor to add auth token to API calls
- Local storage key: 'user_favorites_{user_id}' to support multiple users
- Handle edge case: user logs out (clear local favorite state)
- Consider debouncing rapid taps (e.g., 300ms) to prevent duplicate API calls
