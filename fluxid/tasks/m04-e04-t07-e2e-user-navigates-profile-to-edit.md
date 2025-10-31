---
id: m04-e04-t07
title: E2E Test - User Navigates from Profile to Edit Flyer
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Navigates from Profile to Edit Flyer

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates navigation workflow from profile "My Flyers" list to flyer edit screen with pre-populated data end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating profile-to-edit navigation through real system stack.

### Steps

1. Create Maestro E2E test file for edit navigation
   - Create file `pockitflyer_app/maestro/flows/m04-e04/navigate_profile_to_edit.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyers (use M04 test fixtures)
   - Launch iOS app → authenticate

2. Implement navigation test
   - Test: 'User navigates from profile to edit flyer'
   - Navigate to profile (tap user avatar in header)
   - Assert: Profile shows "My Flyers" section with existing flyers
   - Tap on first flyer in "My Flyers" list
   - Assert: Edit screen opens (not detail view)
   - Assert: Edit form pre-populated with existing flyer data:
     - Title field shows existing title
     - Description field shows existing description
     - Category dropdown shows selected category
     - Address field shows existing address
     - Date pickers show existing valid_from and valid_to dates
     - Images display existing flyer images
   - Assert: "Save Changes" button visible (not "Publish")
   - Verify: Backend logs show GET /api/flyers/{id}/ request

3. Add edit button test
   - Test: 'Profile flyer card has edit button/action'
   - Navigate to profile → "My Flyers" section
   - Assert: Each flyer card has "Edit" button or tap-to-edit affordance
   - Tap "Edit" on specific flyer → edit screen opens for that flyer

4. Add cleanup
   - Cleanup: No database changes in this test (read-only navigation)
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User taps flyer on profile, edit screen opens [Maestro: profile → tapOn flyer → assertVisible "Edit Flyer"]
- [ ] Edit form pre-populated with flyer data [Maestro: verify title, description, dates visible]
- [ ] Backend API returns flyer data for editing [Verify: backend logs show GET request]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/navigate_profile_to_edit.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for profile-to-edit navigation. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, profile/edit APIs

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Navigation from profile to edit screen works
- [ ] Edit form loads with pre-populated flyer data
- [ ] Backend API returns correct flyer for editing
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure with owned flyers)
- Requires: m02-e02 (User profile implementation)
- Requires: m04-e02 (View and edit own flyers)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Use authenticated user with at least 1 owned flyer
- **Pre-population**: Edit screen loads flyer data via API before displaying form
- **Performance**: Edit screen should load with data within 1 second
- **Edit vs Create**: Edit screen shows "Save Changes" button, not "Publish"
- **Maestro verification**: Use assertVisible to check pre-populated field values
- **No changes**: This test only verifies navigation and data loading, no edits saved
