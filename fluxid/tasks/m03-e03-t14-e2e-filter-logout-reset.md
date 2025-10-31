---
id: m03-e03-t14
epic: m03-e03
title: E2E Test - Filter Reset on Logout
status: pending
priority: low
tdd_phase: red
---

# Task: E2E Test - Filter Reset on Logout

## Objective
Create end-to-end Maestro test validating that active filter resets to "All" when user logs out, ensuring anonymous users do not see favorites/following filter active.

## Acceptance Criteria
- [ ] Test launches app and logs in as authenticated user
- [ ] Test taps "Favorites" filter button
- [ ] Test verifies "Favorites" filter active
- [ ] Test navigates to profile/settings screen
- [ ] Test taps logout button
- [ ] Test verifies logout successful
- [ ] Test returns to home feed screen
- [ ] Test verifies "All" filter now active (reset from Favorites)
- [ ] Test verifies "Favorites" and "Following" buttons now disabled
- [ ] Test verifies feed shows all flyers (not filtered)
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Filter persists while logged in
- Logout action triggers filter reset
- Filter resets to "All" after logout
- Favorites and Following buttons disabled after logout
- Feed content updates to show all flyers after logout
- State synchronization between auth and filter state
- Test passes on real iOS device or simulator

## Files to Modify/Create
- `pockitflyer_app/maestro/m03-e03-filter-logout-reset.yaml` (create Maestro test flow)

## Dependencies
- m03-e03-t08 (Filter bar integration)
- m03-e03-t06 (Filter state management with logout handling)
- m02-e01-t09 (Logout functionality)

## Notes
- Test validates proper state cleanup on logout
- Ensures anonymous users never see active favorites/following filters
- Filter state should listen to auth state changes
- Consider testing session expiration as similar scenario
- Test should verify both UI state and feed content change
