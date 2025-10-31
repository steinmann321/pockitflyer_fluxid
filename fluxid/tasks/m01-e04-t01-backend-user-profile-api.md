---
id: m01-e04-t01
epic: m01-e04
title: Create User Profile API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create User Profile API Endpoint

## Objective
Create Django REST API endpoint to retrieve public user profile information by user ID.

## Acceptance Criteria
- [ ] GET endpoint at `/api/users/{user_id}/` returns user profile data
- [ ] Response includes: id, username, profile_picture URL, bio, created_at
- [ ] Profile picture URL is optimized/resized for mobile display
- [ ] Endpoint accessible without authentication (public profiles)
- [ ] Returns 404 if user does not exist
- [ ] Profile picture field returns null if no picture uploaded
- [ ] Response format matches API conventions (consistent with flyer endpoints)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Successful profile retrieval with all fields
- Profile retrieval without profile picture (null handling)
- User not found (404 response)
- Response structure validation
- Public access (no authentication required)
- Profile picture URL format and accessibility

## Files to Modify/Create
- `pockitflyer_backend/users/views.py`
- `pockitflyer_backend/users/serializers.py` (UserProfileSerializer)
- `pockitflyer_backend/users/urls.py`
- `pockitflyer_backend/users/tests/test_views.py`
- `pockitflyer_backend/users/tests/test_serializers.py`

## Dependencies
- m01-e01-t01 (User model must exist)

## Notes
- Endpoint is public (AllowAny permission class)
- Do not expose sensitive fields (email, location coordinates)
- Profile picture should be optimized during upload (handled in future task)
- Response should be minimal and focused on profile display needs
- Consider caching strategy for frequently accessed profiles (implementation in future milestone)
