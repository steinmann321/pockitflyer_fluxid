---
id: m02-e01-t04
epic: m02-e01
title: Create User Login API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create User Login API Endpoint

## Objective
Implement Django REST API endpoint for user login that validates credentials, returns JWT token, and handles authentication errors with clear messages.

## Acceptance Criteria
- [ ] POST `/api/auth/login/` endpoint accepts email and password
- [ ] Validates credentials against hashed password
- [ ] Returns JWT access token, user ID, and profile ID on success
- [ ] Returns 401 error for invalid credentials (wrong password or non-existent email)
- [ ] Returns 400 error for missing fields
- [ ] Error messages are clear but don't reveal whether email exists (security)
- [ ] Case-insensitive email matching
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Valid login: returns token and user info
- Wrong password: returns 401 error
- Non-existent email: returns 401 error
- Empty email or password: returns 400 error
- Case-insensitive email: "Test@example.com" logs in as "test@example.com"
- Token is valid and contains correct user info
- Error message doesn't reveal if email exists

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (LoginView)
- `pockitflyer_backend/users/serializers.py` (UserLoginSerializer)
- `pockitflyer_backend/users/urls.py` (login route)
- `pockitflyer_backend/users/tests/test_login_api.py`

## Dependencies
- m02-e01-t02 (JWT authentication configured)
- m02-e01-t03 (User registration to create test users)

## Notes
- Use Django's authenticate() function for credential validation
- Don't reveal whether email exists in error messages (security best practice)
- Generic error: "Invalid email or password" for both cases
- Token expiration handled by JWT settings from t02
- API must be accessible without authentication (public endpoint)
