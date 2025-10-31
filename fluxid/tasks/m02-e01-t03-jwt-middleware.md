---
id: m02-e01-t03
title: JWT Authentication Middleware for Protected Endpoints
epic: m02-e01
milestone: m02
status: pending
---

# Task: JWT Authentication Middleware for Protected Endpoints

## Context
Part of User Authentication & Account Management (m02-e01) in Milestone m02.

This task configures JWT authentication middleware to protect API endpoints, requiring valid access tokens for authenticated routes. It demonstrates protection with a test endpoint and establishes the pattern for all future authenticated features (e.g., flyer creation).

## Implementation Guide for LLM Agent

### Objective
Configure Django REST Framework to require JWT authentication on protected endpoints, create a test authenticated endpoint, and verify token validation works correctly with proper error responses.

### Steps

1. Update REST Framework authentication settings in `pokitflyer_api/settings.py`
   - Verify `DEFAULT_AUTHENTICATION_CLASSES` already includes `rest_framework_simplejwt.authentication.JWTAuthentication` (should be there from initial setup)
   - Change `DEFAULT_PERMISSION_CLASSES` from `AllowAny` to:
     ```python
     'DEFAULT_PERMISSION_CLASSES': [
         'rest_framework.permissions.IsAuthenticatedOrReadOnly',
     ]
     ```
   - This makes all endpoints require authentication by default, unless explicitly set to AllowAny

2. Create a test protected endpoint in `users/views.py`
   - Import: `from rest_framework.views import APIView`, `from rest_framework.permissions import IsAuthenticated`
   - Define `ProfileView(APIView)`:
     - `permission_classes = [IsAuthenticated]`
     - Override `get(self, request)`:
       - Access authenticated user: `user = request.user`
       - Serialize user: `user_data = UserSerializer(user).data`
       - Return `Response({"message": "Authenticated", "user": user_data})`
   - This endpoint requires valid JWT token to access

3. Add protected endpoint URL to `users/urls.py`
   - Import: `from .views import ProfileView`
   - Add to urlpatterns: `path('profile/', ProfileView.as_view(), name='profile')`
   - Final URL: GET /api/users/profile/

4. Update existing views to explicitly allow anonymous access
   - In `users/views.py`, verify `RegisterView` has `permission_classes = [AllowAny]`
   - In `users/views.py`, verify `LoginView` has `permission_classes = [AllowAny]`
   - This ensures registration and login remain accessible without authentication

5. Create comprehensive test suite in `tests/test_auth_middleware.py`
   - Setup: Create test user, get access token via login in `setUp()`
   - Test cases:
     - `test_protected_endpoint_with_valid_token`: GET /api/users/profile/ with valid token returns 200, user data
     - `test_protected_endpoint_without_token`: GET /api/users/profile/ without token returns 401
     - `test_protected_endpoint_with_invalid_token`: GET with malformed token returns 401
     - `test_protected_endpoint_with_expired_token`: GET with expired token returns 401 (create token with past exp)
     - `test_protected_endpoint_returns_correct_user`: Verify returned user matches authenticated user
     - `test_anonymous_endpoints_still_accessible`: Verify POST /api/users/register/ and POST /api/users/login/ work without token
     - `test_token_refresh_endpoint_accessible`: Verify POST /api/users/token/refresh/ works without access token (only needs refresh token)
   - Import: `from rest_framework.test import APIClient`, `from rest_framework_simplejwt.tokens import AccessToken`
   - Mark all tests with `@pytest.mark.tdd_red` initially

6. Create token expiration test helper
   - In `tests/test_auth_middleware.py`, create function:
     ```python
     def create_expired_token(user):
         from datetime import timedelta, timezone, datetime
         from rest_framework_simplejwt.tokens import AccessToken
         token = AccessToken.for_user(user)
         token.set_exp(from_time=datetime.now(timezone.utc) - timedelta(hours=25))
         return str(token)
     ```
   - Use in `test_protected_endpoint_with_expired_token`

7. Update existing login test to verify authentication
   - In `tests/test_users_login.py`, uncomment/enable the skipped test `test_access_token_authenticates_request`
   - Update it to use the new `/api/users/profile/` endpoint
   - Remove `@pytest.mark.skip` decorator
   - Verify it passes with the new middleware

8. Document authentication pattern for future endpoints
   - Create docstring in `users/views.py` above `ProfileView`:
     ```python
     """
     Example protected endpoint requiring JWT authentication.

     To create protected endpoints:
     1. Add permission_classes = [IsAuthenticated] to view
     2. Access authenticated user via request.user
     3. Token must be passed in Authorization header: "Bearer <token>"

     To create public endpoints:
     1. Add permission_classes = [AllowAny] to view
     2. Override the default IsAuthenticatedOrReadOnly setting
     """
     ```

### Acceptance Criteria
- [ ] GET /api/users/profile/ with valid token returns 200 and user data [Test: with Authorization header]
- [ ] GET /api/users/profile/ without token returns 401 Unauthorized [Test: no header]
- [ ] GET /api/users/profile/ with invalid token returns 401 [Test: malformed token]
- [ ] GET /api/users/profile/ with expired token returns 401 [Test: token with past exp claim]
- [ ] Protected endpoint returns correct authenticated user data [Test: verify user.email matches token]
- [ ] Anonymous endpoints (register, login) still work without token [Test: POST without auth header]
- [ ] Token refresh works without access token [Test: POST /token/refresh/ with only refresh token]
- [ ] Error responses include clear messages (e.g., "Authentication credentials were not provided") [Test: inspect error JSON]
- [ ] Tests pass with >85% coverage

### Files to Create/Modify
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: update DEFAULT_PERMISSION_CLASSES
- `pockitflyer_backend/users/views.py` - MODIFY: add ProfileView, verify AllowAny on public views
- `pockitflyer_backend/users/urls.py` - MODIFY: add profile endpoint URL
- `pockitflyer_backend/tests/test_auth_middleware.py` - NEW: JWT middleware tests
- `pockitflyer_backend/tests/test_users_login.py` - MODIFY: enable authentication test

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**: Token expiration logic, permission class behavior
- **Integration tests**: Full request/response cycle with JWT authentication, multiple endpoints with different permission classes

### Definition of Done
- [ ] Code written and passes all tests (mark tests `@pytest.mark.tdd_green` after verification)
- [ ] Protected endpoints require valid JWT tokens
- [ ] Anonymous endpoints remain accessible
- [ ] No console errors or warnings during test runs
- [ ] Authentication pattern documented for future use
- [ ] Changes committed with message: "feat(auth): configure JWT middleware for protected endpoints"
- [ ] Ready for m02-e01-t04 (frontend) to consume authenticated endpoints

## Dependencies
- Requires: m02-e01-t01 (CustomUser model), m02-e01-t02 (JWT tokens)
- JWTAuthentication configured in settings (already present)

## Technical Notes
**Permission Classes Hierarchy:**
- `IsAuthenticated`: Requires valid token (strict)
- `IsAuthenticatedOrReadOnly`: Requires token for write operations, allows anonymous read
- `AllowAny`: No authentication required (must be explicit override)
- Default is now `IsAuthenticatedOrReadOnly`, so most views are protected unless overridden

**JWT Authentication Flow:**
1. Client includes header: `Authorization: Bearer <access_token>`
2. JWTAuthentication middleware validates token signature and expiration
3. If valid, sets `request.user` to the User object from token's user_id claim
4. View's permission_classes check if user is authenticated
5. If not authenticated, DRF returns 401 before view code runs

**Token Validation:**
- Signature validation: Ensures token signed by server's SECRET_KEY (prevents tampering)
- Expiration validation: Checks exp claim against current time
- Format validation: Ensures proper JWT structure (header.payload.signature)

**Error Response Format:**
```json
{
  "detail": "Authentication credentials were not provided."
}
```
or
```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid",
  "messages": [...]
}
```

**Testing Strategy:**
- Use `@pytest.mark.tdd_red` for all tests initially
- Run tests: `pytest tests/test_auth_middleware.py -v`
- Set auth header in tests: `client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')`
- Clear auth header: `client.credentials()` (no arguments)
- After implementation, verify tests pass, then change marker to `@pytest.mark.tdd_green`

**Future Authenticated Endpoints:**
- Flyer creation (POST /api/flyers/) will use `permission_classes = [IsAuthenticated]`
- Follow the ProfileView pattern for any endpoint requiring authentication

## References
- DRF Authentication: https://www.django-rest-framework.org/api-guide/authentication/
- DRF Permissions: https://www.django-rest-framework.org/api-guide/permissions/
- JWT Authentication: https://django-rest-framework-simplejwt.readthedocs.io/en/latest/getting_started.html#usage
