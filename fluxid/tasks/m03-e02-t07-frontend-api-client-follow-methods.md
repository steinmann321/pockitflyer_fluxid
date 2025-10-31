---
id: m03-e02-t07
epic: m03-e02
title: Add Follow Methods to API Client
status: pending
priority: high
tdd_phase: red
---

# Task: Add Follow Methods to API Client

## Objective
Add follow-related methods to Flutter API client for creating, deleting, and checking follow status. Methods handle authentication, network errors, and return typed responses.

## Acceptance Criteria
- [ ] followUser(int userId) method calls POST /api/follows/ with authentication
- [ ] unfollowUser(int userId) method calls DELETE /api/follows/{userId}/ with authentication
- [ ] getFollowStatus(int userId) method calls GET /api/follows/status/?user_id={userId}
- [ ] Methods include JWT token in Authorization header
- [ ] Methods handle network errors gracefully (throw typed exceptions)
- [ ] Methods handle authentication errors (401 → AuthException)
- [ ] Methods handle validation errors (400 → ValidationException)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- followUser sends correct request with authentication
- unfollowUser sends correct request with authentication
- getFollowStatus sends correct request (works with and without auth)
- Network errors throw NetworkException
- 401 responses throw AuthException
- 400 responses throw ValidationException
- Successful responses return expected data structures
- HTTP client integration tests

## Files to Modify/Create
- `pockitflyer_app/lib/services/api_client.dart` (add follow methods)
- `pockitflyer_app/test/services/api_client_test.dart` (add follow method tests)

## Dependencies
- m03-e02-t02 (Backend follow API endpoints must exist)
- m03-e02-t03 (Backend follow status endpoint must exist)
- m02-e01 (JWT authentication in API client)

## Notes
- Use existing HTTP client and authentication patterns
- Methods should be async/await
- Consider retry logic with exponential backoff for network errors
- API client should handle token refresh if needed
- followUser and unfollowUser are idempotent on backend (handle gracefully)
