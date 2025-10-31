---
id: m03-e02-t03
epic: m03-e02
title: Create Follow Status API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Follow Status API Endpoint

## Objective
Implement API endpoint that returns follow status for current user and a target user. This enables the frontend to show correct initial button state (following/not following). Endpoint works for both authenticated and anonymous users.

## Acceptance Criteria
- [ ] GET /api/follows/status/?user_id={user_id} endpoint returns follow status
- [ ] Authenticated users get their actual follow status (true/false for is_following)
- [ ] Anonymous users always get is_following=false (cannot follow while anonymous)
- [ ] Endpoint validates user_id parameter (400 if missing or invalid)
- [ ] Endpoint returns 404 if target user does not exist
- [ ] Response includes: is_following (boolean), followed_user_id (int)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Get follow status when authenticated and following user (is_following=true)
- Get follow status when authenticated and not following user (is_following=false)
- Get follow status as anonymous user (is_following=false)
- Missing user_id parameter (400 Bad Request)
- Invalid user_id format (400 Bad Request)
- Non-existent user_id (404 Not Found)
- Response structure validation

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (add FollowStatusView or method on FollowViewSet)
- `pockitflyer_backend/users/serializers.py` (add FollowStatusSerializer if needed)
- `pockitflyer_backend/users/urls.py` (register follow status endpoint)
- `pockitflyer_backend/users/tests/test_api.py` (add follow status tests)

## Dependencies
- m03-e02-t01 (Follow model must exist)
- m02-e01-t02 (JWT authentication configured, but endpoint works for anonymous too)

## Notes
- Endpoint must work without authentication (for anonymous browsing)
- Use request.user.is_authenticated to differentiate authenticated vs anonymous
- Consider batch endpoint for checking multiple users at once (future optimization)
- Response format: `{"is_following": true, "followed_user_id": 123}`
