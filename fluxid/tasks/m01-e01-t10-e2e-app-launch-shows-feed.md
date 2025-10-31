---
id: m01-e01-t10
title: App Launch Shows Feed E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: App Launch Shows Feed E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that users see smart-ranked feed on app launch without authentication. Tests user action: opening app for first time. Uses real backend, real database, real geocoding service.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating app launch shows feed through real system stack.

### Steps

1. Create E2E test file for app launch scenario
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t11_app_launch_shows_feed.yaml`
   - Follow existing Maestro flow structure from `pockitflyer_app/maestro/flows/app_launch.yaml`
   - Reference Maestro configuration in `pockitflyer_app/maestro/config/maestro.yaml`
   - Use Maestro YAML syntax (see flows/README.md for command reference)

2. Implement app launch test
   - Test: 'User opens app sees ranked feed without authentication'
   - User launches app (launchApp command)
   - System displays feed screen
   - Verify: Feed screen is visible
   - Verify: At least one flyer card is visible
   - Verify: No authentication prompt shown

3. Add fresh install scenario
   - Test: 'Fresh install shows feed immediately'
   - Simulate fresh install state
   - Launch app
   - Verify: Feed loads without requiring login

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh`
   - Verify test passes against real backend
   - Capture test report from maestro-reports directory

### Acceptance Criteria
- [ ] App launches and displays feed screen without authentication [Verify: Feed screen visible]
- [ ] Test runs against real backend [Verify: Backend logs show feed API request]
- [ ] Fresh install scenario passes [Verify: No authentication required]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t11_app_launch_shows_feed.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for app launch. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, geocoding service

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates data from real database (not mocked)
- [ ] Evidence captured in maestro-reports directory
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t11

## Dependencies
- Requires: Backend User model implementation
- Requires: Backend Flyer model implementation
- Requires: Backend Feed API implementation
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Backend must have at least one test flyer in database
- **Performance**: Allow time for real backend/geocoding service responses
- **Evidence**: Test report saved to pockitflyer_app/maestro-reports/
- **Isolation**: Test should not depend on other E2E tests
- **Device state**: Test assumes simulator/device in default state

## References
- Maestro flows documentation: pockitflyer_app/maestro/flows/README.md
- Maestro runner: pockitflyer_app/maestro/run_tests.sh
- Existing smoke test: pockitflyer_app/maestro/flows/app_launch.yaml
