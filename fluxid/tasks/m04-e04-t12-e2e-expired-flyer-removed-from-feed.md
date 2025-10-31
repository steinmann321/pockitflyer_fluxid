---
id: m04-e04-t12
title: E2E Test - Expired Flyer Removed from Public Feed
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Expired Flyer Removed from Public Feed

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates expiration logic: expired flyers hidden from public feed but visible on creator's profile with "Expired" status end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating flyer expiration behavior through real system stack.

### Steps

1. Create Maestro E2E test file for expiration
   - Create file `pockitflyer_app/maestro/flows/m04-e04/expired_flyer_removed_from_feed.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (expires today)
   - Launch iOS app → authenticate

2. Implement flyer expiration test
   - Test: 'Expired flyer removed from public feed'
   - Create flyer with near-expiration:
     - Title: "Expiring Test Flyer [timestamp]"
     - Valid from: yesterday
     - Valid to: today at current time + 5 seconds
   - Navigate to main feed
   - Assert: Flyer visible in feed initially
   - Wait 10 seconds (for expiration)
   - Pull-to-refresh feed
   - Assert: Expired flyer NOT visible in feed
   - Verify: Backend feed API excludes expired flyers (valid_to < now)

3. Implement profile visibility test
   - Test: 'Expired flyer still visible on creator profile'
   - After flyer expires (from step 2)
   - Navigate to profile → "My Flyers"
   - Assert: Expired flyer visible in profile list
   - Assert: Flyer card shows "Expired" status badge
   - Tap expired flyer → edit/detail screen opens
   - Assert: Edit screen shows expired state

4. Add database verification test
   - Test: 'Expiration is time-based, not hard delete'
   - Verify: Database still contains expired flyer record
   - Verify: Flyer record has valid_to < now
   - Verify: No soft-delete flag (record not deleted, just expired)

5. Add cleanup
   - Cleanup: Delete test flyer
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Expired flyer removed from public feed [Maestro: wait for expiration → refresh → assertNotVisible flyer]
- [ ] Expired flyer visible on creator profile with "Expired" badge [Maestro: profile → assertVisible expired flyer]
- [ ] Database record persists (not deleted) [Verify: database query shows record exists]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/expired_flyer_removed_from_feed.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for flyer expiration. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, time-based filtering

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Expired flyers excluded from public feed
- [ ] Expired flyers visible on creator profile with status badge
- [ ] Backend feed API filters by valid_to correctly
- [ ] Database records persist after expiration
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e03 (Flyer expiration implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Create flyer with short expiration window (5-10 seconds)
- **Feed filtering**: Backend filters WHERE valid_to > now
- **Profile filtering**: Profile shows all owned flyers (including expired)
- **Status badge**: UI renders "Expired" or "Active" based on valid_to comparison
- **Performance**: Feed refresh should complete within 2 seconds
- **Maestro wait**: Use Maestro's wait command for expiration timing
- **Time sync**: Ensure backend and test environment times synchronized
- **Alternative**: Instead of waiting, use M04 helper to backdate valid_to in database
