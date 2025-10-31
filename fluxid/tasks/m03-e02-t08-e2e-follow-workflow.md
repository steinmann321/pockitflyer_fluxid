---
id: m03-e02-t08
epic: m03-e02
title: E2E Test - Follow/Unfollow Workflow
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Follow/Unfollow Workflow

## Objective
Create end-to-end Maestro test validating complete follow/unfollow workflow for authenticated users. Test covers following from flyer card and profile, unfollowing, state persistence, and error handling.

## Acceptance Criteria
- [ ] Test authenticates user (login flow)
- [ ] Test navigates to feed and taps follow button on flyer card
- [ ] Verify button changes to "Following" state immediately
- [ ] Test navigates to creator profile and verifies follow button shows "Following"
- [ ] Test taps unfollow button on profile
- [ ] Verify button changes to "Follow" state immediately
- [ ] Test force closes app and relaunches
- [ ] Verify follow state persists across sessions
- [ ] Test handles network error gracefully (rollback optimistic update)
- [ ] All tests pass and marked complete

## Test Coverage Requirements
- Follow user from flyer card (optimistic update, backend sync)
- Verify follow state on creator profile matches
- Unfollow user from profile (optimistic update, backend sync)
- Follow state persists across app restart
- Rapid follow/unfollow handled gracefully (no race conditions)
- Network error shows error message and rolls back state
- Backend sync on app foreground

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/follow_workflow.yaml` (create Maestro flow)
- `pockitflyer_app/maestro/README.md` (document test)

## Dependencies
- m03-e02-t06 (Follow button integration complete)
- m02-e01 (Authentication system)
- Maestro E2E framework configured

## Notes
- Use Maestro test data fixtures for consistent user accounts
- Test should create fresh user to avoid state pollution
- Simulate network errors using backend mock or network interception
- Test should verify backend state (query API for follow status)
- Follow state visible in UI must match backend state
