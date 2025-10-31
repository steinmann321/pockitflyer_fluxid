---
id: m01-e01-t17
title: Location Permission Granted E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Location Permission Granted E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates iOS location permission flow when user grants permission. Tests user action: granting location permission. Uses real iOS CoreLocation framework.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating location permission granted flow through real iOS system.

### Steps

1. Create E2E test file for location permission granted
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t17_location_permission_granted.yaml`
   - Follow Maestro flow structure conventions
   - Use Maestro permission handling commands

2. Implement permission grant test
   - Test: 'User grants location permission sees accurate feed'
   - User launches app (first time, clean state)
   - System requests location permission (iOS dialog)
   - User taps "Allow" on permission dialog
   - System obtains device location
   - Verify: Feed loads with distance calculations
   - Verify: Flyer cards show distance from user location

3. Implement post-grant behavior test
   - Test: 'Permission granted persists across app restarts'
   - User grants permission
   - User closes app
   - User reopens app
   - Verify: No permission prompt shown
   - Verify: Feed uses location immediately

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t17_location_permission_granted`
   - Verify real iOS permission system used
   - Capture evidence of permission flow

### Acceptance Criteria
- [ ] Location permission grant flow works [Verify: iOS dialog appears, grant succeeds]
- [ ] Feed shows distances after permission granted [Verify: Distance text on cards]
- [ ] Permission persists across restarts [Verify: No re-prompt on relaunch]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t17_location_permission_granted.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for location permission granted. Test runs against real iOS system without mocks.

- **E2E test**: Full-stack validation using real iOS CoreLocation, real backend

### Definition of Done
- [ ] Test passes against real iOS simulator/device
- [ ] Test validates real iOS permission system (not mocked)
- [ ] Evidence captured showing permission dialog and grant
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t17

## Dependencies
- Requires: Frontend location service implementation (iOS CoreLocation)
- Requires: Backend distance calculation implementation
- Requires: Clean simulator/device state for first-run testing
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Simulator state**: Reset simulator to clear previous permissions
- **Maestro permissions**: Check Maestro docs for permission dialog handling
- **iOS dialog**: System permission dialog must be interacted with
- **Evidence**: Screenshots showing iOS permission dialog and granted state

## References
- Maestro permission handling documentation
- iOS CoreLocation permission best practices
- Frontend location service implementation
