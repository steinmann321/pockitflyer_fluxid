---
id: m03-e01-t08
epic: m03-e01
title: E2E Test - Favorite Workflow
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Favorite Workflow

## Objective
Create end-to-end Maestro test validating complete favorite/unfavorite workflow for authenticated users, including optimistic updates, backend persistence, and state synchronization across app restart.

## Acceptance Criteria
- [ ] Test launches app and logs in as authenticated user
- [ ] Test navigates to feed and verifies flyer cards visible
- [ ] Test taps favorite button on flyer card
- [ ] Test verifies button changes to filled heart immediately (optimistic update)
- [ ] Test waits for backend sync (network delay)
- [ ] Test navigates to flyer detail view
- [ ] Test verifies favorite button shows filled heart (state persists across navigation)
- [ ] Test taps unfavorite button
- [ ] Test verifies button changes to empty heart immediately
- [ ] Test force quits and relaunches app
- [ ] Test verifies unfavorited state persists after app restart
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Favorite button appears on flyer cards
- Tapping favorite button triggers optimistic update
- Favorite state persists across navigation (feed ↔ detail)
- Backend API call succeeds (favorite created)
- Unfavorite button triggers optimistic update
- Backend API call succeeds (favorite deleted)
- State persists across app restart (local storage)
- Test passes on real iOS device or simulator

## Files to Modify/Create
- `pockitflyer_app/maestro/m03-e01-favorite-workflow.yaml` (create Maestro test flow)

## Dependencies
- m03-e01-t06 (favorite button integration complete)
- m03-e01-t05 (favorite state management complete)
- m03-e01-t02 (backend API endpoints complete)

## Notes
- Use Maestro assertions to verify button state changes
- Add explicit waits for network operations (2-3 seconds)
- Test should create test user and test flyer via setup script
- Cleanup test data after test completion
- Consider testing error cases: network failure, 401 unauthorized
