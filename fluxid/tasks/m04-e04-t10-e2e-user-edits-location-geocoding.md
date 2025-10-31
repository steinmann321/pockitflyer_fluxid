---
id: m04-e04-t10
title: E2E Test - User Changes Location Triggers Geocoding
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Changes Location Triggers Geocoding

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates location editing with real geocoding service, coordinate updates, and distance recalculations end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating location editing with geocoding through real system stack.

### Steps

1. Create Maestro E2E test file for location editing
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_edits_location_geocoding.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (initial address in Zurich)
   - Launch iOS app → authenticate

2. Implement location change test
   - Test: 'User changes address, triggers geocoding, updates coordinates'
   - Navigate to profile → edit flyer
   - Note original address: "Bahnhofstrasse 1, 8001 Zurich"
   - Note original coordinates (from database): ~(47.3769, 8.5417)
   - Edit address field: Clear → input "Bürkliplatz 1, 8001 Zurich"
   - Tap "Save Changes" → loading indicator appears (geocoding in progress)
   - Wait for success message
   - Verify: Backend logs show geopy geocoding API call for new address
   - Verify: Database shows updated coordinates: ~(47.3661, 8.5414)
   - Verify: Distance calculations updated (new coordinates used)

3. Add distance recalculation verification test
   - Test: 'Updated location recalculates distances in feed'
   - After location change, navigate to main feed
   - Find edited flyer in feed (search by title)
   - Assert: Distance from user location updated (reflects new coordinates)
   - Verify: Distance calculation matches haversine formula with new coordinates
   - Compare: Distance should be different from original (Bahnhofstrasse vs Bürkliplatz ~500m apart)

4. Add invalid address test
   - Test: 'Invalid address shows geocoding error'
   - Navigate to profile → edit different flyer
   - Edit address: Input "INVALID ADDRESS 12345 XYZ"
   - Tap "Save Changes" → wait for response
   - Assert: Error message appears "Unable to locate address"
   - Assert: Original coordinates preserved (no update on failure)
   - Verify: Backend logs show geopy geocoding failure

5. Add cleanup
   - Cleanup: Restore original address or delete test flyer
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User changes address, coordinates update [Maestro: edit address → save → verify new coordinates in database]
- [ ] Geocoding service called for new address [Verify: backend logs show geopy API call]
- [ ] Distance calculations use new coordinates [Maestro: verify updated distance in feed]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_edits_location_geocoding.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for location editing with geocoding. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, geopy service

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Location editing triggers real geocoding service
- [ ] Coordinates update correctly in database
- [ ] Distance calculations reflect new location
- [ ] Invalid address handled with error message
- [ ] Backend logs show geopy API calls
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t07 (Navigation to edit screen)
- Requires: m04-e02 (Edit flyer implementation)
- Requires: m01-e01-t03 (Geocoding service implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Geocoding service**: Real geopy service (NOT mocked), may have rate limits
- **Test addresses**: Use known Zurich addresses for predictable coordinates
- **Expected coordinates**:
  - Bahnhofstrasse 1: ~(47.3769, 8.5417)
  - Bürkliplatz 1: ~(47.3661, 8.5414)
  - Distance between: ~1.2 km
- **Performance**: Geocoding should complete within 3 seconds
- **Error handling**: Circuit breaker may activate on repeated failures
- **Tolerance**: Allow ±0.001° coordinate tolerance (geopy variations)
- **Cleanup**: Restore original address for repeatability
