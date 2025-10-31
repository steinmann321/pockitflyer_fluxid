---
id: m01-e01-t18
title: Location Permission Denied E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Location Permission Denied E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates iOS location permission flow when user denies permission. Tests user action: denying location permission. Uses real iOS CoreLocation framework.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating graceful handling when location permission denied through real iOS system.

### Steps

1. Create E2E test file for location permission denied
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t18_location_permission_denied.yaml`
   - Follow Maestro flow structure conventions
   - Use Maestro permission handling commands

2. Implement permission denial test
   - Test: 'User denies location permission feed still works'
   - User launches app (first time, clean state)
   - System requests location permission (iOS dialog)
   - User taps "Don't Allow" on permission dialog
   - System handles denial gracefully
   - Verify: Feed still loads successfully
   - Verify: Flyer cards show without distance (or with fallback message)
   - Verify: No app crash or error state

3. Implement fallback behavior test
   - Test: 'Feed without location uses default ranking'
   - User denies location permission
   - Verify: Feed shows flyers ranked by recency (not proximity)
   - Verify: Distance field shows appropriate fallback (e.g., "Location not available")

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t18_location_permission_denied`
   - Verify graceful degradation
   - Capture evidence of denial handling

### Acceptance Criteria
- [ ] Location permission denial handled gracefully [Verify: Feed loads, no crash]
- [ ] Feed works without location [Verify: Flyers visible, ranked by recency]
- [ ] Distance field shows fallback message [Verify: Appropriate text instead of distance]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t18_location_permission_denied.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for location permission denied. Test runs against real iOS system without mocks.

- **E2E test**: Full-stack validation using real iOS CoreLocation, real backend

### Definition of Done
- [ ] Test passes against real iOS simulator/device
- [ ] Test validates real iOS permission system (not mocked)
- [ ] Evidence captured showing permission dialog and denial
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t18

## Dependencies
- Requires: Frontend location service with denial handling
- Requires: Backend feed API with location-optional support
- Requires: Clean simulator/device state for first-run testing
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Simulator state**: Reset simulator to clear previous permissions
- **Maestro permissions**: Check Maestro docs for permission dialog handling
- **iOS dialog**: System permission dialog must be interacted with
- **Graceful degradation**: App must not crash or show error
- **Evidence**: Screenshots showing iOS permission denial and feed working

## References
- Maestro permission handling documentation
- iOS CoreLocation permission best practices
- Frontend location service error handling implementation
