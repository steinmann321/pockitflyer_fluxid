---
id: m03-e02-t05
epic: m03-e02
title: Implement Follow State Management
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Follow State Management

## Objective
Create Flutter state management for follow relationships using provider/bloc pattern. State tracks followed users, handles optimistic updates, rollback on failure, and persistence across app sessions.

## Acceptance Criteria
- [ ] FollowState class tracks Set<int> of followed user IDs
- [ ] followUser(userId) method performs optimistic update (adds to set immediately)
- [ ] unfollowUser(userId) method performs optimistic update (removes from set immediately)
- [ ] Rollback mechanism reverts state if API call fails
- [ ] State persists to local storage (SharedPreferences or similar)
- [ ] State loads from local storage on app start
- [ ] isFollowing(userId) method for checking follow status
- [ ] Error handling emits error events for UI to display
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Initial state is empty set
- followUser adds user to followed set optimistically
- unfollowUser removes user from followed set optimistically
- Rollback on API failure reverts optimistic update
- State persists to storage on change
- State loads from storage on initialization
- isFollowing returns correct status
- Concurrent follow/unfollow operations handled gracefully

## Files to Modify/Create
- `pockitflyer_app/lib/providers/follow_provider.dart` (create FollowProvider/FollowBloc)
- `pockitflyer_app/lib/models/follow_state.dart` (create FollowState model if needed)
- `pockitflyer_app/test/providers/follow_provider_test.dart` (create state tests)

## Dependencies
- m03-e02-t07 (API client methods for follow operations)
- State management package (provider, bloc, or riverpod)
- SharedPreferences for persistence

## Notes
- Optimistic updates critical for responsive UI
- Rollback on failure prevents inconsistent state
- Use Set for O(1) lookup performance
- Consider debouncing rapid follow/unfollow taps
- Error handling should be user-friendly (network errors, auth errors)
- State should sync with backend on app foreground (refresh follow list)
