---
id: m04-e04-t14
title: E2E Test - User Deletes Flyer With Confirmation
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Deletes Flyer With Confirmation

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates deletion workflow: user taps delete, confirmation dialog appears, user confirms, flyer removed from feed and profile end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating flyer deletion workflow through real system stack.

### Steps

1. Create Maestro E2E test file for deletion
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_deletes_flyer_confirmation.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (use M04 test fixtures)
   - Launch iOS app → authenticate

2. Implement delete with confirmation test
   - Test: 'User deletes flyer with confirmation dialog'
   - Navigate to profile → "My Flyers"
   - Note flyer count (e.g., 5 flyers)
   - Tap on flyer to delete → edit/detail screen opens
   - Tap "Delete" button → confirmation dialog appears
   - Assert: Dialog shows warning message "This action cannot be undone"
   - Assert: Dialog shows "Cancel" and "Delete" buttons
   - Tap "Cancel" → dialog closes, flyer NOT deleted
   - Tap "Delete" button again → confirmation dialog appears
   - Tap "Delete" (confirm) → loading indicator appears
   - Assert: Success message appears
   - Assert: App navigates back to profile
   - Verify: Backend logs show DELETE /api/flyers/{id}/ request

3. Implement feed removal verification test
   - Test: 'Deleted flyer removed from public feed'
   - After deletion (from step 2)
   - Note deleted flyer title for verification
   - Navigate to main feed
   - Pull-to-refresh (if needed)
   - Assert: Deleted flyer NOT visible in feed
   - Verify: Backend feed API does not return deleted flyer

4. Implement profile removal verification test
   - Test: 'Deleted flyer removed from creator profile'
   - Navigate to profile → "My Flyers"
   - Assert: Flyer count decremented by 1 (e.g., 4 flyers)
   - Assert: Deleted flyer NOT in "My Flyers" list

5. Add cleanup
   - Cleanup: Test flyer already deleted (cleanup is the test itself)
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User taps delete, confirmation dialog appears [Maestro: tapOn "Delete" → assertVisible "This action cannot be undone"]
- [ ] User confirms, flyer deleted [Maestro: tapOn "Delete" confirm → assertVisible "Success"]
- [ ] Deleted flyer removed from feed and profile [Maestro: verify not in feed, profile count decremented]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_deletes_flyer_confirmation.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for flyer deletion workflow. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, deletion logic

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Confirmation dialog prevents accidental deletion
- [ ] Confirmed deletion removes flyer from database
- [ ] Deleted flyer not visible in feed or profile
- [ ] Backend API processes DELETE request correctly
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e03 (Flyer deletion implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Seed user with flyer to delete
- **Confirmation dialog**: Platform-specific (iOS alert, Android dialog)
- **Hard delete**: Flyer record removed from database (not soft delete)
- **Performance**: Deletion should complete within 2 seconds
- **Maestro dialog**: Use Maestro's alert/dialog interaction commands
- **Cancel behavior**: Tapping cancel should not delete flyer
- **Feed removal**: Deleted flyer immediately excluded from feed queries
- **Profile count**: Profile flyer count should update after deletion
