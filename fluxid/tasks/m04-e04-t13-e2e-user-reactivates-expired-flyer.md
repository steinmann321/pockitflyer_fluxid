---
id: m04-e04-t13
title: E2E Test - User Reactivates Expired Flyer
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Reactivates Expired Flyer

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates reactivation workflow: user extends expiration date of expired flyer, flyer reappears in public feed end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating expired flyer reactivation through real system stack.

### Steps

1. Create Maestro E2E test file for reactivation
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_reactivates_expired_flyer.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with expired flyer (valid_to in past)
   - Launch iOS app → authenticate

2. Implement reactivation test
   - Test: 'User extends expiration date of expired flyer'
   - Navigate to profile → "My Flyers"
   - Assert: Expired flyer visible with "Expired" status badge
   - Tap expired flyer → edit screen opens
   - Note current valid_to date (in the past)
   - Edit valid_to: Select today + 14 days (future date)
   - Tap "Save Changes" → wait for success
   - Verify: Database shows updated valid_to (today + 14 days)
   - Assert: Profile flyer status changes from "Expired" to "Active"

3. Implement feed reappearance test
   - Test: 'Reactivated flyer appears in public feed'
   - After reactivation (from step 2)
   - Navigate to main feed
   - Pull-to-refresh (if needed)
   - Assert: Reactivated flyer visible in feed
   - Assert: Flyer displays without "Expired" badge
   - Verify: Backend feed API includes reactivated flyer (valid_to > now)

4. Add backend query verification test
   - Test: 'Feed query includes reactivated flyer'
   - Verify: Backend feed API query WHERE valid_to > now includes flyer
   - Verify: Feed results contain reactivated flyer ID
   - Verify: Flyer position in feed reflects update timestamp

5. Add cleanup
   - Cleanup: Delete test flyer
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User extends expired flyer date, status changes to "Active" [Maestro: edit date → save → assertVisible "Active"]
- [ ] Reactivated flyer reappears in public feed [Maestro: feed → assertVisible reactivated flyer]
- [ ] Backend feed API includes reactivated flyer [Verify: backend query results]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_reactivates_expired_flyer.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for flyer reactivation. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, time-based filtering

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Expired flyer reactivated successfully
- [ ] Reactivated flyer appears in public feed
- [ ] Backend feed API query includes reactivated flyer
- [ ] Status badge updates correctly
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure with expired flyers)
- Requires: m04-e04-t12 (Expired flyer behavior)
- Requires: m04-e03 (Flyer expiration and reactivation implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Seed expired flyer with valid_to < now
- **Reactivation**: Simply updating valid_to to future date reactivates flyer
- **Feed filtering**: Backend WHERE valid_to > now automatically includes reactivated flyers
- **Status badge**: UI computes status based on valid_to vs now comparison
- **Performance**: Reactivation should complete within 2 seconds
- **Feed refresh**: May need pull-to-refresh to see reactivated flyer
- **Alternative approach**: Backend may have explicit "reactivate" endpoint (check implementation)
