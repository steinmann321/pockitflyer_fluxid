---
id: m02-e01-t03
epic: m02-e01
title: Create User Registration API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create User Registration API Endpoint

## Objective
Implement Django REST API endpoint for user registration that creates user account, automatically creates empty profile, validates input, and returns JWT token.

## Acceptance Criteria
- [ ] POST `/api/auth/register/` endpoint accepts email and password
- [ ] Email uniqueness validation (case-insensitive)
- [ ] Password validation: minimum 8 characters
- [ ] User creation with hashed password
- [ ] Profile automatically created via signal
- [ ] Returns JWT access token and user ID on success
- [ ] Returns appropriate error codes: 400 (validation), 409 (duplicate email), 500 (server error)
- [ ] API response includes clear error messages for validation failures
- [ ] Database-level unique constraint on email field
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Valid registration: creates user, profile, returns token
- Duplicate email: returns 409 error
- Invalid email format: returns 400 error
- Weak password (< 8 chars): returns 400 error
- Empty fields: returns 400 error
- Case-insensitive email check: "Test@example.com" equals "test@example.com"
- Profile created automatically: verify profile exists after registration
- Token is valid and contains correct user info

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (RegisterView)
- `pockitflyer_backend/users/serializers.py` (UserRegistrationSerializer)
- `pockitflyer_backend/users/urls.py` (register route)
- `pockitflyer_backend/pockitflyer_backend/urls.py` (include users.urls)
- `pockitflyer_backend/users/tests/test_registration_api.py`

## Dependencies
- m02-e01-t01 (Profile model with signal)
- m02-e01-t02 (JWT authentication configured)

## Notes
- Email is the unique identifier (no separate username field)
- Password is hashed before storage (never store plaintext)
- Profile creation is automatic via signal handler from t01
- Consider email verification flow for future milestone (optional for MVP)
- API must be accessible without authentication (public endpoint)
