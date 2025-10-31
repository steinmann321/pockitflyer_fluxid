---
id: m04-e04-t19
title: E2E Test - Error Handling Production Ready
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Error Handling Production Ready

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates production-ready error handling for M04 workflows: network failures, geocoding failures, image upload failures, validation errors all show clear user feedback end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating error handling and user feedback through real system stack.

### Steps

1. Create Maestro E2E test file for error handling
   - Create file `pockitflyer_app/maestro/flows/m04-e04/error_handling_production_ready.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user
   - Launch iOS app → authenticate

2. Implement network failure test
   - Test: 'Network failure during flyer creation shows error'
   - Navigate to creation screen
   - Fill all fields correctly (title, description, category, address, dates, image)
   - Stop backend (simulate network failure)
   - Tap "Publish" → wait for response
   - Assert: Error message appears "Network error. Please try again."
   - Assert: Retry button or action available
   - Restart backend
   - Tap "Retry" or "Publish" again → flyer created successfully

3. Implement geocoding failure test
   - Test: 'Geocoding failure shows clear error message'
   - Navigate to creation screen
   - Fill all fields except address
   - Input invalid address: "NONEXISTENT ADDRESS 999999"
   - Tap "Publish" → wait for response
   - Assert: Error message appears "Unable to locate address. Please check and try again."
   - Assert: Address field highlighted or marked as invalid
   - Edit address to valid address: "Bahnhofstrasse 1, Zurich"
   - Tap "Publish" → flyer created successfully

4. Implement image upload failure test
   - Test: 'Image upload failure shows error and retry option'
   - Navigate to creation screen
   - Attempt to add very large image (>10MB, if size limit exists)
   - Assert: Error message appears "Image too large. Maximum 5MB."
   - Add valid image (500KB-2MB)
   - Continue with flyer creation → success

5. Implement validation error test
   - Test: 'Form validation errors show clear feedback'
   - Navigate to creation screen
   - Leave title field empty
   - Fill other fields correctly
   - Tap "Publish"
   - Assert: Error message appears "Title is required"
   - Assert: Title field highlighted or marked as invalid
   - Fill title field
   - Tap "Publish" → flyer created successfully

6. Implement edit conflict test
   - Test: 'Concurrent edit conflict shows error'
   - Navigate to profile → edit flyer
   - Simulate backend concurrent edit (use M04 helper to modify flyer)
   - Make changes in app → tap "Save Changes"
   - Assert: Error or warning appears about conflict (if implemented)
   - Assert: Clear resolution path provided

7. Implement delete failure test
   - Test: 'Delete failure (flyer not found) shows error'
   - Navigate to profile → "My Flyers"
   - Note flyer ID
   - Simulate backend deletion (use M04 helper to delete flyer)
   - Tap flyer in app to delete → confirm deletion
   - Assert: Error message appears "Flyer not found or already deleted"

8. Add cleanup
   - Cleanup: Delete created test flyers, restart backend if stopped
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Network failures show clear error messages with retry option [Maestro: stop backend → create → assertVisible "Network error"]
- [ ] Geocoding failures show address-specific error messages [Maestro: invalid address → assertVisible "Unable to locate address"]
- [ ] All errors provide clear user feedback and recovery path [Maestro: verify error messages user-friendly]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/error_handling_production_ready.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for error handling. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, simulated failures

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Network failures handled gracefully
- [ ] Geocoding failures show clear error messages
- [ ] Image upload failures show clear error messages
- [ ] Validation errors show field-specific feedback
- [ ] All errors provide recovery path (retry, edit, etc.)
- [ ] No crashes or undefined errors
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e01, m04-e02, m04-e03 (All M04 feature implementations)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh` (stop/start for network failure tests)
- **Error messages**: User-friendly, non-technical language
- **Retry logic**: Circuit breaker and exponential backoff (CLAUDE.md principle)
- **Field highlighting**: Invalid fields visually indicated (red border, etc.)
- **Network simulation**: Stop backend mid-test to simulate network failure
- **Geocoding failure**: Use invalid address to trigger geopy failure
- **Image size limits**: Test with images exceeding limits (if implemented)
- **Recovery paths**: Every error should have clear next step for user
- **No generic errors**: Avoid "Something went wrong" - be specific
