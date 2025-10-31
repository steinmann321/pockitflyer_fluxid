---
id: m04-e04-t17
title: E2E Test - M02 M04 Authentication Context Works Correctly
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - M02 M04 Authentication Context Works Correctly

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates M02-M04 authentication integration: only authenticated users can create/edit/delete flyers, JWT tokens work correctly, auth required for Flyern button, session persistence across app restarts end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating M02-M04 authentication integration through real system stack.

### Steps

1. Create Maestro E2E test file for authentication integration
   - Create file `pockitflyer_app/maestro/flows/m04-e04/m02_m04_authentication_context.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user (use M04 test fixtures)
   - Launch iOS app (fresh state, not authenticated)

2. Implement anonymous user blocked test
   - Test: 'Anonymous user cannot access flyer creation'
   - Launch app (skip authentication)
   - Assert: Flyern button hidden or disabled
   - Navigate to main feed → browse works (M01 anonymous browsing)
   - Assert: Cannot access creation features

3. Implement authenticated user access test
   - Test: 'Authenticated user can access all M04 features'
   - Login with test user credentials (M02 authentication)
   - Assert: JWT token stored in app (session persistence)
   - Assert: Flyern button visible and enabled
   - Tap Flyern → creation screen opens
   - Create flyer → success (JWT sent with API request)
   - Navigate to profile → "My Flyers" visible (authenticated view)
   - Edit own flyer → success (JWT authorization)
   - Delete own flyer → success (JWT authorization)

4. Implement JWT token validation test
   - Test: 'M04 API endpoints require valid JWT token'
   - Verify: Backend logs show Authorization header with JWT token
   - Verify: POST /api/flyers/ request includes Bearer token
   - Verify: PATCH /api/flyers/{id}/ request includes Bearer token
   - Verify: DELETE /api/flyers/{id}/ request includes Bearer token
   - Verify: Backend validates token before processing requests

5. Implement session persistence test
   - Test: 'Authentication persists across app restarts'
   - Login with test user → create flyer → note user session
   - Force quit app (simulate restart)
   - Relaunch app
   - Assert: User still authenticated (JWT token persisted)
   - Assert: Flyern button still visible
   - Assert: Can immediately access M04 features without re-login

6. Implement logout clears access test
   - Test: 'Logout revokes M04 feature access'
   - Authenticated user → logout (M02 logout flow)
   - Assert: Flyern button hidden or disabled
   - Assert: Cannot access creation features
   - Assert: Profile shows anonymous view (or login prompt)

7. Add cleanup
   - Cleanup: Delete created test flyers, logout test user
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Anonymous user cannot access M04 features [Maestro: skip login → assertNotVisible "Flyern"]
- [ ] Authenticated user can access all M04 features [Maestro: login → assertVisible "Flyern" → create/edit/delete success]
- [ ] JWT tokens work correctly for all M04 API requests [Verify: backend logs show Authorization headers]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/m02_m04_authentication_context.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for M02-M04 authentication integration. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, JWT authentication, session persistence

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Anonymous users blocked from M04 features
- [ ] Authenticated users can access all M04 features
- [ ] JWT tokens sent with all M04 API requests
- [ ] Session persistence works across app restarts
- [ ] Logout revokes M04 feature access
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m02-e01 (User authentication implementation)
- Requires: m04-e01, m04-e02, m04-e03 (All M04 feature implementations)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **JWT authentication**: Django REST Framework JWT (or similar)
- **Token storage**: iOS Keychain or secure storage
- **Authorization header**: "Authorization: Bearer {token}"
- **Token validation**: Backend validates JWT signature and expiration
- **Session persistence**: Token persisted in secure storage, auto-loaded on app launch
- **Anonymous browsing**: M01 features work without authentication
- **Performance**: Authentication checks should be instant (no API call needed for local validation)
- **Security**: Logout must clear token from storage
