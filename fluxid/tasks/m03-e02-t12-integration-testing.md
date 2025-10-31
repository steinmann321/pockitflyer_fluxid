---
id: m03-e02-t12
epic: m03-e02
title: Follow Integration Testing
status: pending
priority: medium
tdd_phase: red
---

# Task: Follow Integration Testing

## Objective
Create comprehensive integration tests validating complete follow functionality across backend and frontend. Tests verify full request-response cycles, error handling, and edge cases.

## Acceptance Criteria
- [ ] Backend integration tests validate full API workflows (create, delete, status check)
- [ ] Frontend integration tests validate FollowProvider + API client + FollowButton interaction
- [ ] Tests validate error handling (network errors, auth errors, validation errors)
- [ ] Tests validate edge cases (deleted user, concurrent follows, rapid toggle)
- [ ] Tests validate state persistence and recovery
- [ ] All tests marked with `@pytest.mark.tdd_green` (backend) and `tags: ['tdd_green']` (frontend) after passing

## Test Coverage Requirements
- Backend: Full follow workflow (authenticate, follow, verify status, unfollow)
- Backend: Follow already-deleted user returns 404
- Backend: Concurrent follow requests handled gracefully (unique constraint)
- Frontend: FollowProvider + API client integration (follow, unfollow, rollback on error)
- Frontend: FollowButton + FollowProvider integration (state updates trigger UI updates)
- Frontend: State persistence integration (save to storage, load from storage)
- Frontend: Error propagation from API client → provider → UI

## Files to Modify/Create
- `pockitflyer_backend/users/tests/test_integration.py` (create backend integration tests)
- `pockitflyer_app/test/integration/follow_integration_test.dart` (create frontend integration tests)

## Dependencies
- m03-e02-t01 through m03-e02-t10 (all core follow functionality complete)

## Notes
- Integration tests use real database (not mocked) for backend
- Frontend integration tests mock API client but test provider + widget together
- Tests should cover happy path and error paths
- Edge case testing critical (deleted users, network failures, concurrent operations)
- Integration tests complement unit tests and E2E tests
