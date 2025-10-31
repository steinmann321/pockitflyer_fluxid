---
id: m03-e02-t02
epic: m03-e02
title: Create Follow/Unfollow API Endpoints
status: pending
priority: high
tdd_phase: red
---

# Task: Create Follow/Unfollow API Endpoints

## Objective
Implement Django REST API endpoints for creating and deleting follow relationships. Endpoints require authentication, prevent self-follows, handle duplicate/non-existent follows gracefully, and return appropriate status codes.

## Acceptance Criteria
- [ ] POST /api/follows/ endpoint creates follow relationship (authenticated users only)
- [ ] DELETE /api/follows/{followed_user_id}/ endpoint deletes follow relationship (authenticated users only)
- [ ] Endpoints require JWT authentication (401 if not authenticated)
- [ ] POST endpoint prevents self-follows (400 Bad Request with clear error message)
- [ ] POST endpoint handles duplicate follows gracefully (idempotent - returns 200 or 201)
- [ ] DELETE endpoint handles non-existent follows gracefully (idempotent - returns 204)
- [ ] POST endpoint validates followed user exists (404 if not found)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Create follow with authenticated user (201 Created)
- Create follow without authentication (401 Unauthorized)
- Attempt self-follow (400 Bad Request)
- Duplicate follow creation (idempotent behavior)
- Follow non-existent user (404 Not Found)
- Delete existing follow (204 No Content)
- Delete non-existent follow (204 No Content - idempotent)
- Delete follow without authentication (401 Unauthorized)
- API response structure validation

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (add FollowViewSet or CreateFollow/DeleteFollow views)
- `pockitflyer_backend/users/serializers.py` (add FollowSerializer if needed)
- `pockitflyer_backend/users/urls.py` (register follow endpoints)
- `pockitflyer_backend/users/tests/test_api.py` (add follow API tests)

## Dependencies
- m03-e02-t01 (Follow model must exist)
- m02-e01-t02 (JWT authentication must be configured)

## Notes
- POST endpoint accepts `followed_id` in request body, follower is current authenticated user
- DELETE endpoint uses followed_user_id in URL, follower is current authenticated user
- Idempotency important for network retry scenarios
- Consider using viewsets (FollowViewSet) for RESTful patterns
- Response includes minimal data - just status and success/error message
