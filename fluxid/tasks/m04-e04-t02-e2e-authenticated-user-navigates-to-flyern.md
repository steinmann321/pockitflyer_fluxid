---
id: m04-e04-t02
title: E2E Test - Authenticated User Navigates to Flyern Button
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Authenticated User Navigates to Flyern Button

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates authenticated user can access Flyern button and navigate to flyer creation screen end-to-end with NO MOCKS. Tests M02 authentication context integration with M04 creation flow.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating authenticated user access to Flyern button through real system stack.

### Steps

1. Create Maestro E2E test file for authentication and navigation
   - Create file `pockitflyer_app/maestro/flows/m04-e04/authenticated_user_flyern_access.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed E2E test data with authenticated user (use management command)
   - Launch iOS app (fresh state)

2. Implement authentication flow test
   - Test: 'Authenticated user sees and accesses Flyern button'
   - Launch app → login screen appears
   - Tap login fields → enter test user credentials
   - Tap "Sign In" → authentication succeeds (JWT token stored)
   - Assert: Flyern button visible in header/navigation
   - Tap Flyern button → creation screen opens
   - Assert: Creation screen displays with empty form fields
   - Verify: Backend logs show authenticated API request

3. Add anonymous user comparison test
   - Test: 'Anonymous user does not see Flyern button'
   - Launch app (skip authentication)
   - Assert: Flyern button hidden or disabled
   - Assert: Feed browsing still works (M01 anonymous browsing)

4. Add test utilities and cleanup
   - Use `e2e_m04_helpers.py::get_test_user_token()` for credential setup
   - Cleanup: Stop backend, reset app state
   - Mark Maestro flow with appropriate TDD marker after passing

### Acceptance Criteria
- [ ] Authenticated user sees Flyern button in navigation [Maestro: assertVisible "Flyern"]
- [ ] Tapping Flyern opens creation screen [Maestro: tapOn "Flyern" → assertVisible "Create Flyer"]
- [ ] Anonymous user does not see Flyern button [Maestro: skipLogin → assertNotVisible "Flyern"]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/authenticated_user_flyern_access.yaml` - NEW: E2E test
- `pockitflyer_app/maestro/flows/m04-e04/anonymous_user_flyern_blocked.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for authentication-gated Flyern access. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, JWT authentication

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Authenticated user can access Flyern button and creation screen
- [ ] Anonymous user cannot access Flyern button (blocked or hidden)
- [ ] Backend logs show authenticated requests with valid JWT
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m02-e01 (User authentication implementation)
- Requires: m04-e01 (Flyern button and creation screen)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Use authenticated user from M04 test fixtures
- **JWT Token**: Token stored in app after login (validates M02 session persistence)
- **Maestro keys**: Ensure Flyern button has testable key/semantics for Maestro
- **Performance**: Login to Flyern access should take <2 seconds
- **Isolation**: Test does not depend on other M04 E2E tests
