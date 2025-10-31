---
id: m01-e01-t14
title: Distance Calculations E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Distance Calculations E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that distance calculations between user location and flyer location are accurate. Tests user action: viewing distance on flyer cards. Uses real geocoding service, real coordinates.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating distance calculations are accurate within 100m through real system stack.

### Steps

1. Create E2E test file for distance validation
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t14_distance_calculations.yaml`
   - Follow Maestro flow structure conventions
   - Reference Maestro location simulation commands

2. Implement distance display test
   - Test: 'Flyer card shows distance from user location'
   - Set user location to known coordinates (Maestro runFlow with env vars)
   - User launches app
   - System calculates distances using real geocoding
   - Verify: Distance text visible on flyer card
   - Verify: Distance format correct (e.g., "2.3 km", "500 m")

3. Implement accuracy verification
   - Test: 'Distance calculation accurate within 100m'
   - Use test flyer at known location
   - Set user location to known coordinates
   - Calculate expected distance manually
   - Verify: Displayed distance matches expected (±100m tolerance)

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t14_distance_calculations`
   - Verify real geocoding service used
   - Capture evidence showing distance values

### Acceptance Criteria
- [ ] Distance displays on flyer cards [Verify: Distance text visible with unit]
- [ ] Distance accurate within 100m [Verify: Match known coordinates calculation]
- [ ] Test uses real geocoding service [Verify: Backend logs show geopy calls]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t14_distance_calculations.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for distance calculations. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real geocoding service (geopy)

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates real geocoding service responses (not mocked)
- [ ] Evidence captured showing accurate distance calculations
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t14

## Dependencies
- Requires: Backend geocoding service (geopy) implementation
- Requires: Backend distance calculation logic
- Requires: Frontend distance display on flyer cards
- Requires: Test flyer with known coordinates in database
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyer at known coordinates
- **Geocoding**: Allow time for real geopy service calls
- **Accuracy**: Use ±100m tolerance for assertions
- **Location simulation**: Maestro may support location override (check docs)
- **Evidence**: Screenshots showing distance values

## References
- Backend geocoding service implementation for expected behavior
- Distance calculation algorithm for manual verification
- Maestro location simulation (if available)
