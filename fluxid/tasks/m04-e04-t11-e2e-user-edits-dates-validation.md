---
id: m04-e04-t11
title: E2E Test - User Edits Dates With Validation
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Edits Dates With Validation

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates date editing (valid_from, valid_to) with validation rules and expiration logic end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating date editing with validation through real system stack.

### Steps

1. Create Maestro E2E test file for date editing
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_edits_dates_validation.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (expires in 7 days)
   - Launch iOS app → authenticate

2. Implement valid date edit test
   - Test: 'User extends expiration date successfully'
   - Navigate to profile → edit flyer
   - Note original valid_to date (today + 7 days)
   - Tap "Valid To" date picker → select today + 30 days
   - Tap "Save Changes" → wait for success
   - Verify: Database shows updated valid_to date (today + 30 days)
   - Assert: Flyer still visible in feed (not expired)

3. Implement date validation test
   - Test: 'Valid to must be after valid from'
   - Navigate to profile → edit flyer
   - Current dates: valid_from = today, valid_to = today + 30 days
   - Edit valid_to: Select yesterday's date (before valid_from)
   - Tap "Save Changes"
   - Assert: Error message appears "End date must be after start date"
   - Assert: Changes not saved (database unchanged)

4. Implement past date validation test
   - Test: 'Valid from cannot be in the past for active flyers'
   - Navigate to profile → edit flyer
   - Edit valid_from: Select yesterday's date
   - Tap "Save Changes"
   - Assert: Error message or warning appears
   - Verify: Database unchanged or validated appropriately

5. Add cleanup
   - Cleanup: Restore original dates or delete test flyer
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User extends expiration date successfully [Maestro: edit date → save → verify database update]
- [ ] Invalid date range shows error [Maestro: valid_to < valid_from → assertVisible error]
- [ ] Changes persist correctly [Verify: database shows updated dates]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_edits_dates_validation.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for date editing. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, date validation logic

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Valid date edits save successfully
- [ ] Invalid date ranges trigger validation errors
- [ ] Database persists valid date changes
- [ ] Backend validation enforces date rules
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t07 (Navigation to edit screen)
- Requires: m04-e02 (Edit flyer implementation)
- Requires: m04-e03 (Flyer expiration logic)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Validation rules**:
  - valid_to must be > valid_from
  - valid_to should be > now (can't set expiration in past)
  - valid_from typically >= now (can't backdate active flyers)
- **Date format**: Use ISO format or project's standard date format
- **Timezone**: Handle timezone correctly (UTC or local)
- **Maestro date picker**: Use Maestro's date picker interaction commands
- **Performance**: Date validation should be instant (client-side + server-side)
- **Error messages**: Clear, user-friendly validation error messages
