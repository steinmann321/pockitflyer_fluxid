---
id: m03-e01-t11
epic: m03-e01
title: Integration Testing
status: pending
priority: medium
tdd_phase: red
---

# Task: Integration Testing

## Objective
Create comprehensive integration tests validating favorite feature interacts correctly with existing authentication, feed, and profile features. Tests ensure no regressions and verify cross-feature workflows.

## Acceptance Criteria
- [ ] Backend: Favorite API endpoints integrate with JWT authentication middleware
- [ ] Backend: Favorite status appears correctly in feed API responses
- [ ] Backend: Favorite status appears correctly in flyer detail API responses
- [ ] Backend: Deleting user cascades to delete user's favorites
- [ ] Backend: Deleting flyer cascades to delete flyer's favorites
- [ ] Frontend: Favorite button state updates when user logs in/out
- [ ] Frontend: Favorite state clears when user logs out
- [ ] Frontend: Favorite state loads when user logs in
- [ ] All tests marked with `@pytest.mark.tdd_green` or `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Backend: authenticated user can create favorite (integration with auth middleware)
- Backend: anonymous user receives 401 on favorite creation attempt
- Backend: feed API returns is_favorited field correctly for authenticated user
- Backend: feed API returns is_favorited=null for anonymous user
- Backend: deleting user deletes all user's favorites (cascade)
- Backend: deleting flyer deletes all favorites of that flyer (cascade)
- Frontend: logging in loads favorites from backend
- Frontend: logging out clears favorite state
- Frontend: favorite button disables when user logs out

## Files to Modify/Create
- `pockitflyer_backend/flyers/tests/test_integration.py` (create integration tests)
- `pockitflyer_app/test/integration/favorite_auth_integration_test.dart` (create integration tests)

## Dependencies
- m03-e01-t02 (favorite API endpoints)
- m03-e01-t03 (favorite status in flyer responses)
- m02-e01-t06 (authentication state management)

## Notes
- Integration tests use real database (not mocked)
- Integration tests create real User, Flyer, and Favorite objects
- Test cleanup: delete test objects after each test
- Consider testing edge cases: user with 1000+ favorites, flyer with 1000+ favorites
- Verify no N+1 query problems when loading feed with favorites
