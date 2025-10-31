---
id: m02-e01-t10
epic: m02-e01
title: Implement Session Persistence Across App Restarts
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Session Persistence Across App Restarts

## Objective
Ensure authentication state persists when app is force quit and relaunched. On app startup, check for valid token and restore session if available.

## Acceptance Criteria
- [ ] main.dart calls authProvider.checkAuthStatus() on startup
- [ ] checkAuthStatus() retrieves token from TokenStorageService
- [ ] If valid token exists: restore authenticated state with user info
- [ ] If token expired: clear token and remain unauthenticated
- [ ] If no token exists: remain unauthenticated
- [ ] User info (userId, profileId) decoded from token or fetched from API
- [ ] Splash screen or loading state during auth check
- [ ] App navigates to appropriate screen based on auth state (feed for both authenticated and unauthenticated)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- App startup with valid token: restores session
- App startup with expired token: clears session
- App startup with no token: remains unauthenticated
- checkAuthStatus() decodes user info from token
- UI shows loading state during auth check
- Navigation to correct screen after auth check

## Files to Modify/Create
- `pockitflyer_app/lib/main.dart` (add startup auth check)
- `pockitflyer_app/test/main_test.dart`
- `pockitflyer_app/lib/providers/authentication_provider.dart` (enhance checkAuthStatus if needed)

## Dependencies
- m02-e01-t05 (TokenStorageService)
- m02-e01-t06 (AuthenticationProvider with checkAuthStatus)

## Notes
- JWT payload contains userId and profileId - decode from token
- Consider using jwt_decoder package for token parsing
- Token expiration: check 'exp' claim against current time
- Splash screen can be simple loading indicator or branded splash
- Both authenticated and unauthenticated users see feed as initial screen (M01 behavior)
- Auth status affects header UI (login button vs avatar) but not initial route
