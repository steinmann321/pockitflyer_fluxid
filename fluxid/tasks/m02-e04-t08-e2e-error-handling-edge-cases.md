---
id: m02-e04-t08
epic: m02-e04
title: E2E Test - Error Handling and Edge Cases (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Error Handling and Edge Cases (No Mocks)

## Objective
Validate comprehensive error handling and edge cases for M02 authentication and profile management features end-to-end. Tests cover network failures, invalid credentials, expired tokens, validation errors, and recovery workflows using real Django backend and real iOS app with no mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m02_e04_network_failures.yaml`
- [ ] Network failure test steps:
  1. Start real Django backend
  2. Seed M02 E2E test data
  3. Launch iOS app
  4. Stop backend (simulate network unavailable)
  5. Tap "Login" button
  6. Assert login screen loads (cached UI)
  7. Enter credentials: `test_user_001@pockitflyer.test`, `TestPass123!`
  8. Tap "Login" button
  9. Assert error message: "Unable to connect. Please check your connection and try again."
  10. Assert "Retry" button visible
  11. Start backend again (restore network)
  12. Tap "Retry" button
  13. Assert login succeeds
  14. Assert authenticated (profile avatar visible)
- [ ] Maestro flow: `m02_e04_invalid_credentials.yaml`
- [ ] Invalid credentials test steps:
  1. Start backend
  2. Launch app
  3. Tap "Login" button
  4. Test wrong password:
     a. Enter email: `test_user_001@pockitflyer.test`
     b. Enter password: `WrongPassword123!`
     c. Tap "Login"
     d. Assert error: "Invalid email or password"
     e. Assert NOT authenticated (login button still visible)
  5. Test non-existent email:
     a. Clear fields
     b. Enter email: `nonexistent@pockitflyer.test`
     c. Enter password: `TestPass123!`
     d. Tap "Login"
     e. Assert error: "Invalid email or password" (same message, no email enumeration)
     f. Assert NOT authenticated
  6. Test empty fields:
     a. Clear email field
     b. Tap "Login"
     c. Assert validation error: "Email is required"
     d. Enter email: `test_user_001@pockitflyer.test`
     e. Clear password field
     f. Tap "Login"
     g. Assert validation error: "Password is required"
- [ ] Maestro flow: `m02_e04_token_expiration.yaml`
- [ ] Token expiration test steps:
  1. Start backend, login as test_user_001
  2. Assert authenticated
  3. Use backend helper script to expire token immediately
  4. Navigate to profile screen (triggers authenticated API call)
  5. Assert error: "Session expired. Please login again."
  6. Assert auto-redirected to login screen
  7. Assert token cleared from Keychain
  8. Assert login button visible (not profile avatar)
  9. Login again with valid credentials
  10. Assert new token issued, authenticated again
- [ ] Maestro flow: `m02_e04_validation_errors.yaml`
- [ ] Validation error test steps:
  1. Start backend
  2. Launch app
  3. Test registration validations:
     a. Tap "Register" link
     b. Enter email: `invalid-email-format`
     c. Assert validation error: "Invalid email format"
     d. Enter email: `test_user_001@pockitflyer.test` (existing user)
     e. Enter password: `TestPass123!`
     f. Enter display name: `Test User`
     g. Tap "Register"
     h. Assert error: "Email already registered"
  4. Test profile editing validations:
     a. Login as test_user_001
     b. Navigate to edit profile
     c. Enter display name: `` (empty)
     d. Tap "Save"
     e. Assert validation error: "Display name is required"
     f. Enter display name: `This is a very long display name that exceeds the maximum allowed length of 50 characters`
     g. Tap "Save"
     h. Assert validation error: "Display name too long (max 50 characters)"
     i. Enter bio: `<500+ character string>`
     j. Tap "Save"
     k. Assert validation error: "Bio too long (max 500 characters)"
- [ ] Maestro flow: `m02_e04_image_upload_errors.yaml`
- [ ] Image upload error test steps:
  1. Start backend, login as test_user_001
  2. Navigate to edit profile
  3. Test image too large:
     a. Select image >5MB (test fixture)
     b. Assert error: "Image too large. Maximum 5MB."
     c. Assert image not uploaded
  4. Test unsupported format:
     a. Select GIF image (test fixture)
     b. Assert error: "Unsupported format. Use JPEG or PNG."
     c. Assert image not uploaded
  5. Test network failure during upload:
     a. Select valid image
     b. Stop backend (simulate network failure)
     c. Tap "Save"
     d. Assert error: "Upload failed. Please try again."
     e. Assert image not uploaded, profile not updated
     f. Start backend
     g. Tap "Retry" or "Save" again
     h. Assert upload succeeds
- [ ] Maestro flow: `m02_e04_concurrent_session_handling.yaml`
- [ ] Concurrent session test steps:
  1. Start backend
  2. Login as test_user_001 on Device A (simulator 1)
  3. Login as test_user_001 on Device B (simulator 2)
  4. Assert both devices authenticated independently
  5. Logout on Device A
  6. Assert Device A logged out, Device B still authenticated
  7. Edit profile on Device B (change display name)
  8. Login on Device A again
  9. Navigate to profile on Device A
  10. Assert profile shows updated display name (changes from Device B visible)
- [ ] Real service validations:
  - Network errors handled gracefully with clear messages
  - Retry mechanisms work correctly
  - Invalid credentials detected and reported
  - No email enumeration vulnerability (same error for wrong password and non-existent email)
  - Validation errors shown inline (no backend call for frontend validations)
  - Token expiration detected and handled (auto-logout, redirect to login)
  - Image upload errors handled (file size, format, network)
  - Concurrent sessions independent (multiple devices can login simultaneously)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Network failure handling: Login, registration, profile update, image upload
- Network recovery: Retry mechanisms work correctly
- Invalid credentials: Wrong password, non-existent email, empty fields
- Validation errors: Email format, password strength, display name length, bio length
- Token expiration: Detection, auto-logout, redirect to login, re-login
- Image upload errors: File too large, unsupported format, network failure
- Concurrent sessions: Multiple devices login, independent auth states, data synchronization
- Error message clarity: User-friendly, actionable, non-technical
- Error recovery workflows: All errors recoverable (retry or correct input)

## Files to Modify/Create
- `maestro/flows/m02-e04/network_failures.yaml`
- `maestro/flows/m02-e04/invalid_credentials.yaml`
- `maestro/flows/m02-e04/token_expiration.yaml`
- `maestro/flows/m02-e04/validation_errors.yaml`
- `maestro/flows/m02-e04/image_upload_errors.yaml`
- `maestro/flows/m02-e04/concurrent_session_handling.yaml`
- `pockitflyer_backend/scripts/simulate_network_failure.py` (helper script to stop/start backend)
- `pockitflyer_backend/scripts/expire_token_immediately.py` (helper script for token expiration)
- `pockitflyer_backend/fixtures/test_images/` (test images: large file, GIF, valid JPEG/PNG)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure)
- m02-e04-t02 (Registration workflow)
- m02-e04-t03 (Login workflow)
- m02-e04-t04 (Profile editing workflow)
- m02-e04-t06 (Token expiration handling)
- All M02-E01, M02-E02, M02-E03 tasks (implementation of features being tested)

## Notes
**Critical: NO MOCKS**
- Real Django server running on localhost (start/stop to simulate network)
- Real SQLite database with test data
- Real iOS app making actual HTTP requests
- Real network failure simulation (stop backend server)
- Real token expiration (backend helper script modifies token)

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/stop_backend_e2e.sh` - Stops backend (simulates network failure)
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**Error Message Standards**:

1. **Network Errors**:
   - "Unable to connect. Please check your connection and try again."
   - Include "Retry" button for all network errors

2. **Authentication Errors**:
   - Invalid credentials: "Invalid email or password" (no email enumeration)
   - Token expired: "Session expired. Please login again."
   - Unauthorized: "You do not have permission to perform this action."

3. **Validation Errors**:
   - Empty email: "Email is required"
   - Invalid email format: "Invalid email format"
   - Empty password: "Password is required"
   - Weak password: "Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 number"
   - Email already registered: "Email already registered. Please login or use a different email."
   - Display name empty: "Display name is required"
   - Display name too long: "Display name too long (max 50 characters)"
   - Bio too long: "Bio too long (max 500 characters)"

4. **Image Upload Errors**:
   - File too large: "Image too large. Maximum 5MB."
   - Unsupported format: "Unsupported format. Use JPEG or PNG."
   - Upload failed: "Upload failed. Please try again."

**Network Failure Simulation Strategy**:
1. Stop Django backend server: `./scripts/stop_backend_e2e.sh`
2. iOS app makes API request
3. Request times out or connection refused
4. iOS app catches error, shows user-friendly message
5. Start backend again: `./scripts/start_backend_e2e.sh`
6. User taps "Retry" button
7. Request succeeds

**Token Expiration Simulation**:
```python
# pockitflyer_backend/scripts/expire_token_immediately.py
# Option 1: Modify token in database (if using token blacklist)
# Option 2: Temporarily change JWT expiration to 1 second, wait, then change back
# Option 3: Manually craft expired token and inject into iOS Keychain (complex)

# Simplest approach for E2E test:
# Change Django JWT settings: ACCESS_TOKEN_LIFETIME = timedelta(seconds=1)
# User logs in → token expires after 1 second → next API call fails with 401
```

**Validation Error Testing Strategy**:
- Frontend validations: Tested without backend call (instant feedback)
  - Email format, password strength, empty fields, max length
- Backend validations: Tested with API call (async feedback)
  - Email uniqueness (already registered), database constraints

**Image Upload Test Fixtures**:
Create test images in `pockitflyer_backend/fixtures/test_images/`:
- `large_image.jpg` - 6MB image (exceeds 5MB limit)
- `unsupported_format.gif` - GIF image (unsupported)
- `valid_image.jpg` - 2MB JPEG (valid)
- `valid_image.png` - 1MB PNG (valid)

**Concurrent Session Handling**:
- M02 supports multiple concurrent sessions (no single-session enforcement)
- Each device has independent JWT token
- Logout on one device doesn't affect other devices
- Profile updates visible across all devices (data synced via backend)

**Error Recovery Workflows**:

1. **Network failure during login**:
   - Error shown → user taps "Retry" → login succeeds

2. **Invalid credentials**:
   - Error shown → user corrects password → login succeeds

3. **Token expired**:
   - Error shown → redirected to login → user logs in → new token issued

4. **Validation error (display name empty)**:
   - Error shown → user enters display name → save succeeds

5. **Image upload failure (network)**:
   - Error shown → network restored → user taps "Retry" → upload succeeds

**Performance Expectations**:
- Network timeout: 10 seconds (iOS URLSession default)
- Retry after network recovery: <3 seconds
- Validation error display: Immediate (no delay)
- Token expiration detection: <2 seconds (on next API call)

**Edge Cases to Test** (separate Maestro flows):
1. Multiple rapid login attempts with wrong password → consistent error messages
2. Network failure during registration → error shown, user not created in database
3. Token expiration during profile editing → error shown, changes NOT saved
4. Logout during network failure → still clears local token (succeeds locally)
5. Image upload during low bandwidth → timeout after 30 seconds, error shown
6. Very long bio (1000+ characters) → validation error before API call

**Security Considerations**:
- No email enumeration: Same error for wrong password and non-existent email ✅
- Password never logged or exposed in error messages ✅
- Token expiration enforced (no indefinite sessions) ✅
- Validation on both frontend and backend (defense in depth) ✅
- Concurrent sessions allowed but independent (no session hijacking) ✅

**Success Indicators**:
- All network failures handled gracefully ✅
- All error messages clear and actionable ✅
- All errors recoverable (retry or correct input) ✅
- No email enumeration vulnerability ✅
- Token expiration detected and handled ✅
- Validation errors shown inline (instant feedback) ✅
- Image upload errors handled (file size, format, network) ✅
- Concurrent sessions work independently ✅
- All error recovery workflows tested ✅
