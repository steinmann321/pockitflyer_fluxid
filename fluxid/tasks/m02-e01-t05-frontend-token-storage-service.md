---
id: m02-e01-t05
epic: m02-e01
title: Create Secure Token Storage Service (iOS Keychain)
status: pending
priority: high
tdd_phase: red
---

# Task: Create Secure Token Storage Service (iOS Keychain)

## Objective
Implement Flutter service to securely store JWT tokens in iOS Keychain using flutter_secure_storage package. Provides methods to save, retrieve, and delete tokens with proper error handling.

## Acceptance Criteria
- [ ] Install and configure flutter_secure_storage package
- [ ] TokenStorageService class with methods: saveToken, getToken, deleteToken, hasToken
- [ ] Token stored in iOS Keychain (not SharedPreferences)
- [ ] Error handling for storage failures
- [ ] Token retrieval returns null if not found
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Save token successfully
- Retrieve saved token
- Token persistence after service recreation (simulates app restart)
- Delete token clears storage
- hasToken returns correct boolean
- Retrieve non-existent token returns null
- Error handling for storage failures (mock failures)

## Files to Modify/Create
- `pockitflyer_app/lib/services/token_storage_service.dart`
- `pockitflyer_app/test/services/token_storage_service_test.dart`
- `pockitflyer_app/pubspec.yaml` (add flutter_secure_storage)

## Dependencies
- None (foundational service)

## Notes
- iOS Keychain is the only acceptable storage mechanism for tokens (security requirement)
- SharedPreferences is NOT secure enough for JWT tokens
- flutter_secure_storage automatically uses iOS Keychain on iOS
- Token format: raw JWT string (no additional encoding needed)
- Service should be singleton for consistent state management
