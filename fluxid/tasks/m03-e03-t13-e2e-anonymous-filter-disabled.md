---
id: m03-e03-t13
epic: m03-e03
title: E2E Test - Anonymous User Filter Disabled
status: pending
priority: low
tdd_phase: red
---

# Task: E2E Test - Anonymous User Filter Disabled

## Objective
Create end-to-end Maestro test validating that favorites and following filters are disabled for anonymous users, with only "All" filter accessible. Test verifies proper UI state and behavior for unauthenticated sessions.

## Acceptance Criteria
- [ ] Test launches app without logging in (anonymous mode)
- [ ] Test navigates to home feed screen
- [ ] Test verifies FilterBar visible
- [ ] Test verifies "All" filter active and enabled
- [ ] Test verifies "Favorites" filter button disabled (grayed out, not tappable)
- [ ] Test verifies "Following" filter button disabled (grayed out, not tappable)
- [ ] Test attempts to tap disabled "Favorites" button
- [ ] Test verifies no action occurs (feed does not change)
- [ ] Test verifies feed shows all flyers (default behavior)
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Filter bar renders for anonymous users
- "All" filter button enabled
- "Favorites" filter button disabled and not tappable
- "Following" filter button disabled and not tappable
- Tapping disabled buttons has no effect
- Feed shows all flyers regardless of filter tap attempts
- Visual indication of disabled state (opacity, color change)
- Test passes on real iOS device or simulator

## Files to Modify/Create
- `pockitflyer_app/maestro/m03-e03-anonymous-filter-disabled.yaml` (create Maestro test flow)

## Dependencies
- m03-e03-t08 (Filter bar integration)
- m03-e03-t06 (Filter state management with auth handling)

## Notes
- Test should not create or log in as user
- Use Maestro assertions to verify button enabled/disabled state
- Disabled button visual check: opacity or color difference
- This test validates authentication-gated features properly restricted
- No backend API calls should occur for disabled filter taps
