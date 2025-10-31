---
id: m03-e03-t12
epic: m03-e03
title: E2E Test - Feed Filter Workflow
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Feed Filter Workflow

## Objective
Create end-to-end Maestro test validating complete feed filter workflow for authenticated users, including filter selection, feed updates, empty states, and filter persistence across app restart.

## Acceptance Criteria
- [ ] Test launches app and logs in as authenticated user
- [ ] Test verifies FilterBar visible in home feed screen
- [ ] Test verifies "All" filter active by default
- [ ] Test favorites some flyers (prerequisite data setup)
- [ ] Test taps "Favorites" filter button
- [ ] Test verifies feed updates to show only favorited flyers
- [ ] Test verifies previously favorited flyers appear in filtered feed
- [ ] Test taps "Following" filter button
- [ ] Test verifies feed updates to show only followed creators' flyers (or empty state)
- [ ] Test taps "All" filter button
- [ ] Test verifies feed returns to showing all flyers
- [ ] Test selects "Favorites" filter again
- [ ] Test force quits and relaunches app
- [ ] Test verifies "Favorites" filter still active after restart
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Filter bar renders in home feed screen
- All three filter buttons visible and tappable
- Tapping filter button updates feed content
- Favorites filter shows only favorited flyers
- Following filter shows only followed creators' flyers
- All filter shows all flyers
- Filter selection persists across app restart
- Empty state UI appears when filter returns no results
- Feed reload completes within 2 seconds
- Test passes on real iOS device or simulator

## Files to Modify/Create
- `pockitflyer_app/maestro/m03-e03-filter-workflow.yaml` (create Maestro test flow)

## Dependencies
- m03-e03-t08 (Filter bar integration)
- m03-e03-t06 (Filter state management with persistence)
- m03-e01-t06 (Favorite button integration - for test data setup)
- m03-e02-t06 (Follow button integration - for test data setup)

## Notes
- Test setup: create test user, test flyers, establish favorites and follows
- Use Maestro assertions to verify filter button active state
- Use Maestro scrolling to verify feed content changes
- Add explicit waits for network operations (2-3 seconds)
- Test empty states: create user with no favorites/follows
- Cleanup test data after test completion
- Consider testing error case: network failure during filter change
