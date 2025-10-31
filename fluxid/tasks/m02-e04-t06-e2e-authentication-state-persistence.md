---
id: m02-e04-t06
epic: m02-e04
title: E2E Test - Authentication State Persistence and Token Lifecycle (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Authentication State Persistence and Token Lifecycle (No Mocks)

## Objective
Validate authentication state persistence across app lifecycle events (background, foreground, force quit, relaunch) and token lifecycle management (issuance, storage, expiration, invalidation) end-to-end using real Django backend and real iOS app with no mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m02_e04_auth_persistence_app_restart.yaml`
- [ ] App restart persistence test steps:
  1. Start real Django backend
  2. Seed M02 E2E test data
  3. Launch iOS app (fresh install)
  4. Login as test_user_001
  5. Assert header shows profile avatar (authenticated)
  6. Navigate to profile screen
  7. Assert profile data loads correctly
  8. Force quit app (simulate swipe-up kill on iOS)
  9. Relaunch app
  10. Assert app auto-authenticates (no login required)
  11. Assert header shows profile avatar immediately (not login button)
  12. Navigate to profile screen
  13. Assert profile data loads correctly (authenticated API call succeeds)
  14. Verify token still in iOS Keychain
  15. Verify token valid (not expired)
  16. Cleanup: stop backend
- [ ] Maestro flow: `m02_e04_auth_persistence_background_foreground.yaml`
- [ ] Background/foreground persistence test steps:
  1. Start backend, login as test_user_001
  2. Assert authenticated (profile avatar visible)
  3. Background app (simulate home button press)
  4. Wait 10 seconds
  5. Foreground app
  6. Assert still authenticated (profile avatar still visible)
  7. Navigate to profile
  8. Assert profile loads (API call with token succeeds)
  9. Background app again
  10. Wait 1 minute
  11. Foreground app
  12. Assert still authenticated
  13. Cleanup: stop backend
- [ ] Maestro flow: `m02_e04_token_expiration_handling.yaml`
- [ ] Token expiration handling test steps:
  1. Start backend
  2. Login as test_user_001
  3. Assert authenticated
  4. Simulate token expiration (backend helper script: expire token)
  5. Navigate to profile screen (triggers authenticated API call)
  6. Assert error: "Session expired. Please login again."
  7. Assert app auto-redirects to login screen
  8. Assert token cleared from Keychain
  9. Assert header shows login button (no avatar)
  10. Login again with same credentials
  11. Assert new token issued and stored
  12. Assert authenticated again
  13. Cleanup: stop backend
- [ ] Maestro flow: `m02_e04_logout_and_relogin.yaml`
- [ ] Logout and re-login test steps:
  1. Start backend, login as test_user_001
  2. Assert authenticated
  3. Navigate to profile screen
  4. Tap "Logout" button
  5. Confirm logout
  6. Assert header shows login button (unauthenticated)
  7. Verify token cleared from Keychain
  8. Force quit app
  9. Relaunch app
  10. Assert still logged out (no auto-authentication)
  11. Assert header shows login button
  12. Tap login button
  13. Login as test_user_001 again
  14. Assert authenticated (new token issued)
  15. Assert header shows profile avatar
  16. Cleanup: stop backend
- [ ] Real service validations:
  - JWT token stored in iOS Keychain (secure storage)
  - Token persists across app restarts
  - Token persists during background/foreground transitions
  - Token cleared on logout
  - Token not restored after logout + app restart
  - Expired token detected and handled gracefully
  - New token issued on re-login after expiration
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Token storage in iOS Keychain (secure)
- Token retrieval on app launch (auto-authentication)
- Token persistence: App restart (force quit → relaunch)
- Token persistence: Background → foreground
- Token persistence: Extended background (1+ minute)
- Token invalidation: Logout clears token
- Token expiration: Detected and handled (redirect to login)
- Token refresh: Not implemented in M02 (future feature), only expiration handling
- Authentication state synchronization with token presence
- Header UI state synchronization with auth state

## Files to Modify/Create
- `maestro/flows/m02-e04/auth_persistence_app_restart.yaml`
- `maestro/flows/m02-e04/auth_persistence_background_foreground.yaml`
- `maestro/flows/m02-e04/token_expiration_handling.yaml`
- `maestro/flows/m02-e04/logout_and_relogin.yaml`
- `pockitflyer_backend/scripts/expire_user_token.py` (helper script to simulate token expiration)
- `pockitflyer_backend/scripts/verify_token_in_database.py` (helper script to verify token blacklist)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure)
- m02-e04-t03 (Login workflow with token storage)
- m02-e01-t05 (Token storage service - iOS Keychain)
- m02-e01-t06 (Authentication state management)
- m02-e01-t10 (Session persistence implementation)

## Notes
**Critical: NO MOCKS**
- Real Django server running on localhost
- Real SQLite database with test data
- Real JWT authentication (tokens issued by backend)
- Real iOS Keychain for token storage
- Real app lifecycle events (background, foreground, quit, relaunch)

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**JWT Token Configuration**:
- Token expiration: 7 days (configurable in Django settings)
- Token payload: `{user_id, email, exp, iat}`
- Token algorithm: HS256 (HMAC with SHA-256)
- Token secret: Django SECRET_KEY

**iOS Keychain Storage**:
- Service name: `com.pockitflyer.app`
- Account name: User email (e.g., `test_user_001@pockitflyer.test`)
- Token stored as password field
- Keychain item persists across app restarts (not uninstalls)
- Keychain security: Accessible only when device unlocked

**Authentication State Management**:
```dart
// Flutter authentication state
class AuthState {
  bool isAuthenticated;
  String? token;
  User? currentUser;
}
```

**App Launch Authentication Flow**:
1. App launches
2. Check iOS Keychain for token
3. If token exists:
   a. Load token into memory
   b. Set `isAuthenticated = true`
   c. Update UI: Show profile avatar in header
   d. (Optional) Verify token with backend (validate not expired)
4. If token does not exist:
   a. Set `isAuthenticated = false`
   b. Update UI: Show login button in header

**Token Expiration Handling Flow**:
1. User makes authenticated API call (e.g., load profile)
2. Backend validates token
3. Backend detects token expired (current time > exp timestamp)
4. Backend returns 401 Unauthorized with error: "Token expired"
5. iOS app receives 401 response
6. iOS app clears token from Keychain
7. iOS app sets `isAuthenticated = false`
8. iOS app shows error message: "Session expired. Please login again."
9. iOS app redirects to login screen
10. User logs in again → new token issued → authenticated again

**Backend Token Expiration Simulation**:
```python
# pockitflyer_backend/scripts/expire_user_token.py
# Modifies token expiration in database (for testing only)
user = User.objects.get(email='test_user_001@pockitflyer.test')
# Option 1: Manually set token exp to past time (requires token blacklist)
# Option 2: Temporarily change Django JWT settings to short expiration (1 second)
# Option 3: Wait 7 days (not practical for E2E testing)
```

**Logout Flow**:
1. User taps "Logout" button
2. Confirmation dialog: "Are you sure?"
3. User confirms
4. App clears token from iOS Keychain
5. App sets `isAuthenticated = false`
6. App updates UI: Header shows login button (not avatar)
7. (Optional) App calls backend logout API (invalidate token server-side)
8. App navigates to feed (still accessible anonymously)

**Post-Logout App Restart Behavior**:
- App relaunches
- Checks Keychain for token → not found (cleared on logout)
- Sets `isAuthenticated = false`
- Shows login button in header
- No auto-authentication (user must login again)

**Background/Foreground Persistence**:
- Token remains in Keychain during background
- Token remains valid during background (unless expired)
- App resumes with same auth state after foreground
- No re-authentication required after short background (<5 minutes)
- No re-authentication required after extended background (1+ minute, as long as token not expired)

**Token Invalidation Strategies** (for M02):
1. **Client-side only**: Clear token from Keychain (simple, no backend tracking)
2. **Server-side blacklist**: Backend maintains blacklist of invalidated tokens (more secure, requires additional implementation)
   - For M02: Client-side only (server-side blacklist is future enhancement)

**Performance Expectations**:
- App launch with auto-auth: <2 seconds
- Token retrieval from Keychain: <100ms
- Token validation API call (optional): <1 second
- Background → foreground transition: Immediate (no delay)

**Error Handling**:
- Token expired → clear token, redirect to login, show error message
- Token invalid (malformed) → clear token, redirect to login, show error message
- Keychain access error → assume not authenticated, show login button
- Network error during token validation → assume token valid (offline mode)

**Edge Cases to Test** (separate Maestro flows):
1. Login → force quit immediately → relaunch → verify auto-authenticated
2. Login → background for 5 minutes → foreground → verify still authenticated
3. Login → wait 7+ days (token expiration) → API call → verify expired, redirect to login
4. Logout → force quit → relaunch → verify not authenticated
5. Logout → relaunch → login again → verify new token issued
6. Multiple sessions: Login on device A → login on device B → verify both authenticated independently

**Success Indicators**:
- Token persists across app restart ✅
- Auto-authentication on app launch ✅
- Token persists during background/foreground transitions ✅
- Token cleared on logout ✅
- No auto-authentication after logout + restart ✅
- Token expiration detected and handled gracefully ✅
- Re-login after expiration issues new token ✅
- All error cases handled gracefully ✅
