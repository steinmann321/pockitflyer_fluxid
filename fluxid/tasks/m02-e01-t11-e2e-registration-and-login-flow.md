---
id: m02-e01-t11
epic: m02-e01
title: E2E Test - Complete Registration and Login Flow
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Complete Registration and Login Flow

## Objective
Create Maestro E2E tests for complete user registration and login workflows including UI navigation, API integration, and authentication state persistence.

## Acceptance Criteria
- [ ] E2E test: Register new user → verify header shows avatar → verify authenticated state
- [ ] E2E test: Login with existing user → verify header shows avatar → verify authenticated state
- [ ] E2E test: Logout → verify header shows login button → verify unauthenticated state
- [ ] E2E test: Register → force quit app → relaunch → verify session persisted
- [ ] E2E test: Login → force quit app → relaunch → verify session persisted
- [ ] E2E test: Registration with duplicate email → verify error message shown
- [ ] E2E test: Login with wrong password → verify error message shown
- [ ] E2E test: Registration with weak password → verify error message shown
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Complete registration flow: screen → form → submit → authenticated
- Complete login flow: screen → form → submit → authenticated
- Session persistence: login → quit → relaunch → still authenticated
- Error handling: duplicate email, wrong credentials, validation errors
- UI state: header switches between login button and avatar correctly
- Navigation: login/registration screens navigate to feed on success

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/authentication/register_and_login.yaml`
- `pockitflyer_app/maestro/flows/authentication/error_handling.yaml`
- `pockitflyer_app/maestro/flows/authentication/session_persistence.yaml`

## Dependencies
- m02-e01-t07 (Registration screen)
- m02-e01-t08 (Login screen)
- m02-e01-t09 (Header auth UI)
- m02-e01-t10 (Session persistence)
- m01-e05 (Maestro E2E infrastructure from M01)

## Notes
- Use Maestro YAML format consistent with M01 E2E tests
- Test data: generate unique emails for each test run (timestamp-based)
- Backend should be running locally for E2E tests
- Consider test data cleanup strategy (delete test users after run)
- Tests should run in CI/CD pipeline (pre-push hook)
- Verify tests run within 3 seconds per flow (performance requirement)
