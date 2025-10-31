---
id: m02-e02-t02
epic: m02-e02
title: Create Profile Name Update API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Name Update API Endpoint

## Objective
Implement Django REST API endpoint for updating user profile name. Endpoint requires authentication and only allows users to update their own profile.

## Acceptance Criteria
- [ ] PATCH `/api/users/me/profile/` endpoint updates profile name
- [ ] Requires JWT authentication (Authorization header)
- [ ] Request body: `{"name": "New Name"}`
- [ ] Name validation: max 50 characters, required field
- [ ] Returns updated profile data on success
- [ ] Returns 400 for invalid name (empty, too long, invalid characters)
- [ ] Returns 401 for unauthenticated requests
- [ ] Returns 403 if user tries to update another user's profile
- [ ] Validation rejects XSS attempts and SQL injection
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Valid name update with authentication
- Empty name returns 400 error
- Name exceeding 50 characters returns 400 error
- Special characters in name (test allowed vs. disallowed)
- XSS attempt in name (e.g., `<script>alert('xss')</script>`) returns 400
- SQL injection attempt in name returns 400
- Unauthenticated request returns 401
- Updated profile returned in response
- Profile updated_at timestamp changes

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (ProfileUpdateView)
- `pockitflyer_backend/users/serializers.py` (ProfileUpdateSerializer)
- `pockitflyer_backend/users/urls.py` (profile update route)
- `pockitflyer_backend/users/tests/test_profile_update_api.py`

## Dependencies
- m02-e01-t01 (Profile model)
- m02-e01-t02 (JWT authentication)
- m02-e02-t01 (Profile retrieval API)

## Notes
- Use `/me/` pattern for accessing own profile (simpler than user ID)
- Name is required field - cannot be set to null or empty
- Consider profanity filter for names (optional for MVP)
- Sanitization should strip dangerous HTML/JS but allow basic Unicode
- Backend enforces business rules (not just serializer validation)
