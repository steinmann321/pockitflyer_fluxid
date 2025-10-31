---
id: m04-e02-t13
epic: m04-e02
title: E2E Test - Edit Validation and Error Handling
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Edit Validation and Error Handling

## Objective
Create Maestro end-to-end test validating client and server-side validation during flyer editing.

## Acceptance Criteria
- [ ] Test attempts to set expiration date before publication date
- [ ] Test verifies validation error message displayed
- [ ] Test attempts to exceed character limits on text fields
- [ ] Test verifies character limit enforcement
- [ ] Test attempts to save with invalid address
- [ ] Test verifies geocoding error handling
- [ ] Test simulates network failure during save
- [ ] Test verifies error message and retry capability
- [ ] Test verifies unsaved changes warning on back navigation
- [ ] Test verifies save button disabled with invalid data
- [ ] Test tagged with `tdd_green` after passing

## Test Coverage Requirements
- Date validation (expiration > publication)
- Text field character limits enforced
- Invalid address geocoding errors
- Network failure error messages
- Save button disabled for invalid state
- Unsaved changes warning works
- Cancel warning allows save or discard
- Error messages are user-friendly
- Retry after error works correctly
- Form state resets after successful save

## Files to Modify/Create
- `maestro/flows/m04-e02-edit-validation.yaml`
- `maestro/test-data/m04-e02-validation-setup.sh`

## Dependencies
- M04-E02-T05 (Edit screen with validation)
- M04-E02-T02 (Backend update API with validation)
- E2E test infrastructure from M01-E05

## Notes
- Network failures can be simulated by backend test endpoint
- Invalid addresses should be realistic (not just random strings)
- Test both client-side and server-side validation
- Ensure error messages are tested for clarity and actionability
- Consider using Maestro's network condition manipulation if available
