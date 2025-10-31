---
id: m02-e01-t06
epic: m02-e01
title: Create Authentication State Management
status: pending
priority: high
tdd_phase: red
---

# Task: Create Authentication State Management

## Objective
Implement Flutter authentication state management using Provider or Riverpod. Manages authenticated/unauthenticated state, current user info, and token lifecycle. Persists authentication state across app restarts.

## Acceptance Criteria
- [ ] AuthenticationProvider/Notifier with state: isAuthenticated, currentUserId, currentProfileId
- [ ] Methods: login(token, userId, profileId), logout(), checkAuthStatus()
- [ ] Integration with TokenStorageService
- [ ] checkAuthStatus() called on app startup to restore session
- [ ] State change notifications trigger UI updates
- [ ] Token expiration detection (parse JWT exp claim)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Initial state is unauthenticated
- login() updates state and saves token
- logout() clears state and deletes token
- checkAuthStatus() restores session if valid token exists
- checkAuthStatus() clears session if token expired
- checkAuthStatus() does nothing if no token exists
- State change notifications emitted correctly
- Token expiration detected and handled

## Files to Modify/Create
- `pockitflyer_app/lib/providers/authentication_provider.dart`
- `pockitflyer_app/test/providers/authentication_provider_test.dart`
- `pockitflyer_app/pubspec.yaml` (add provider or riverpod if not present)

## Dependencies
- m02-e01-t05 (TokenStorageService)

## Notes
- Use Provider or Riverpod (check existing M01 state management pattern)
- JWT expiration parsing: decode token payload, check 'exp' claim
- Consider using jwt_decoder package for token parsing
- checkAuthStatus() should be called in main.dart on app startup
- Token refresh logic can be added in future milestone if needed
