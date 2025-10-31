---
id: m02-e01-t02
title: Backend Login Endpoint with JWT Generation
epic: m02-e01
milestone: m02
status: pending
---

# Task: Backend Login Endpoint with JWT Generation

## Context
Part of User Authentication & Account Management (m02-e01) in Milestone m02.

This task implements the login endpoint that authenticates users with email/password and returns JWT access/refresh tokens. It builds on the CustomUser model from m02-e01-t01 and uses django-rest-framework-simplejwt for token generation with custom claims and expiration settings.

## Implementation Guide for LLM Agent

### Objective
Create login endpoint that validates email/password credentials, generates JWT access/refresh tokens with custom claims (email, user_id), and returns tokens with appropriate expiration times.

### Steps

1. Configure JWT settings in `pokitflyer_api/settings.py`
   - Import: `from datetime import timedelta`
   - Add SIMPLE_JWT configuration dict after REST_FRAMEWORK:
     ```python
     SIMPLE_JWT = {
         'ACCESS_TOKEN_LIFETIME': timedelta(hours=24),  # 24 hour access token
         'REFRESH_TOKEN_LIFETIME': timedelta(days=7),   # 7 day refresh token
         'ROTATE_REFRESH_TOKENS': True,                 # Issue new refresh token on refresh
         'BLACKLIST_AFTER_ROTATION': False,             # Don't blacklist old tokens (simpler)
         'AUTH_HEADER_TYPES': ('Bearer',),
         'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
     }
     ```

2. Create custom token serializer in `users/serializers.py`
   - Import: `from rest_framework_simplejwt.serializers import TokenObtainPairSerializer`
   - Define `CustomTokenObtainPairSerializer(TokenObtainPairSerializer)`:
     - Override `@classmethod get_token(cls, user)`:
       - Call `token = super().get_token(user)`
       - Add custom claims: `token['email'] = user.email`
       - Add custom claims: `token['user_id'] = user.id`
       - Return token
   - This adds email and user_id to JWT payload for easy frontend access

3. Create login view in `users/views.py`
   - Import: `from rest_framework_simplejwt.views import TokenObtainPairView`
   - Define `LoginView(TokenObtainPairView)`:
     - `serializer_class = CustomTokenObtainPairSerializer`
     - `permission_classes = [AllowAny]`
   - This view handles POST with email/password, returns access/refresh tokens

4. Create user detail serializer in `users/serializers.py` (for returning user info with tokens)
   - Import: `from .models import Profile`
   - Define `UserSerializer(serializers.ModelSerializer)`:
     - Include fields: `id`, `email`, `profile` (nested)
     - Define nested `ProfileSerializer(serializers.ModelSerializer)` with fields: `display_name`, `bio`
     - Meta: model = CustomUser, fields = ['id', 'email', 'profile']
   - This serializer provides safe user data (no password) for the frontend

5. Update LoginView to return user data with tokens
   - Override `post()` method in `LoginView`:
     - Call `response = super().post(request, *args, **kwargs)`
     - If successful (status 200):
       - Get user from request data: `user = CustomUser.objects.get(email=request.data['email'])`
       - Serialize user: `user_data = UserSerializer(user).data`
       - Add to response: `response.data['user'] = user_data`
     - Return response
   - This provides user profile data along with tokens in a single response

6. Add login URL to `users/urls.py`
   - Import: `from .views import LoginView`
   - Add to urlpatterns: `path('login/', LoginView.as_view(), name='login')`
   - Final URL: POST /api/users/login/

7. Add token refresh URL to `users/urls.py`
   - Import: `from rest_framework_simplejwt.views import TokenRefreshView`
   - Add to urlpatterns: `path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh')`
   - This allows frontend to refresh access tokens before expiration

8. Create comprehensive test suite in `tests/test_users_login.py`
   - Setup: Create test user in `setUp()` using `CustomUser.objects.create_user(email='test@example.com', password='TestPass123!')`
   - Test cases:
     - `test_login_valid_credentials`: POST with correct email/password returns 200, access token, refresh token, user data
     - `test_login_invalid_password`: Wrong password returns 401
     - `test_login_invalid_email`: Non-existent email returns 401
     - `test_login_missing_fields`: Missing email or password returns 400
     - `test_login_token_format`: Verify access token is valid JWT (decode and check claims)
     - `test_login_token_contains_custom_claims`: Decode token, verify email and user_id claims present
     - `test_login_response_includes_user_data`: Verify response contains user.id, user.email, user.profile
     - `test_login_response_excludes_password`: Verify password not in response
     - `test_token_refresh`: Use refresh token to get new access token, verify new token is valid
     - `test_token_refresh_invalid_token`: Invalid refresh token returns 401
   - Import: `from rest_framework_simplejwt.tokens import AccessToken`, `import jwt`
   - Mark all tests with `@pytest.mark.tdd_red` initially

9. Test token authentication works (integration test)
   - Create test in `tests/test_users_login.py`:
     - `test_access_token_authenticates_request`:
       - Login to get access token
       - Make request to protected endpoint with `Authorization: Bearer <token>` header
       - Verify request succeeds (200)
       - Make request without token, verify fails (401)
   - Note: This requires a protected endpoint, which will be created in m02-e01-t03, so mark this test `@pytest.mark.skip(reason="Requires protected endpoint from m02-e01-t03")` for now

### Acceptance Criteria
- [ ] POST /api/users/login/ with valid email/password returns 200, access token, refresh token, user data [Test: correct credentials]
- [ ] Invalid credentials return 401 Unauthorized [Test: wrong password, non-existent email]
- [ ] Missing email or password returns 400 Bad Request [Test: empty fields]
- [ ] Access token is valid JWT with exp, iat, user_id, email claims [Test: decode token with PyJWT]
- [ ] Refresh token is valid JWT [Test: decode refresh token]
- [ ] Access token lifetime is 24 hours [Test: check exp claim]
- [ ] Refresh token lifetime is 7 days [Test: check exp claim]
- [ ] Response includes user object with id, email, profile (display_name, bio) [Test: inspect JSON structure]
- [ ] Response never includes password [Test: check all response scenarios]
- [ ] POST /api/users/token/refresh/ with valid refresh token returns new access token [Test: refresh flow]
- [ ] Tests pass with >85% coverage

### Files to Create/Modify
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add SIMPLE_JWT configuration
- `pockitflyer_backend/users/serializers.py` - MODIFY: add CustomTokenObtainPairSerializer, UserSerializer, ProfileSerializer
- `pockitflyer_backend/users/views.py` - MODIFY: add LoginView
- `pockitflyer_backend/users/urls.py` - MODIFY: add login and token refresh URLs
- `pockitflyer_backend/tests/test_users_login.py` - NEW: comprehensive login and token tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**: Serializer validation (CustomTokenObtainPairSerializer custom claims), token payload structure, UserSerializer output
- **Integration tests**: Full login endpoint with test database, token generation/refresh flow, authentication with tokens

### Definition of Done
- [ ] Code written and passes all tests (mark tests `@pytest.mark.tdd_green` after verification)
- [ ] JWT tokens generated with correct claims and expiration
- [ ] No console errors or warnings during test runs
- [ ] Token refresh endpoint working
- [ ] Changes committed with message: "feat(users): implement JWT login endpoint"
- [ ] Ready for m02-e01-t03 (JWT middleware) to use tokens for authentication

## Dependencies
- Requires: m02-e01-t01 (CustomUser model must exist)
- rest_framework_simplejwt installed (already present in settings.py)

## Technical Notes
**JWT Token Structure:**
- Access token: Short-lived (24h), used for API requests
- Refresh token: Long-lived (7d), used to get new access tokens
- Custom claims (email, user_id) allow frontend to identify user without additional API call

**Token Security:**
- Tokens signed with SECRET_KEY from settings (never expose this)
- Tokens are stateless (no database lookup needed for validation)
- ROTATE_REFRESH_TOKENS=True issues new refresh token on each refresh (better security)

**Email Authentication:**
- Existing EmailBackend in pokitflyer_api/backends.py handles email-based login
- USERNAME_FIELD='email' on CustomUser makes email the login identifier
- TokenObtainPairSerializer automatically uses USERNAME_FIELD

**Response Format:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "profile": {
      "display_name": "Anonymous User",
      "bio": ""
    }
  }
}
```

**Testing Strategy:**
- Use `@pytest.mark.tdd_red` for all tests initially
- Run tests: `pytest tests/test_users_login.py -v`
- Decode JWT in tests using: `jwt.decode(token, options={"verify_signature": False})` (signature verification requires SECRET_KEY)
- After implementation, verify tests pass, then change marker to `@pytest.mark.tdd_green`

## References
- djangorestframework-simplejwt: https://django-rest-framework-simplejwt.readthedocs.io/
- JWT.io (decode/inspect tokens): https://jwt.io/
- DRF TokenObtainPairView: https://django-rest-framework-simplejwt.readthedocs.io/en/latest/getting_started.html#usage
