---
id: m02-e01-t01
title: Backend User Model and Registration Endpoint
epic: m02-e01
milestone: m02
status: pending
---

# Task: Backend User Model and Registration Endpoint

## Context
Part of User Authentication & Account Management (m02-e01) in Milestone m02.

This task creates the foundational user authentication infrastructure by implementing a custom User model with email/password authentication, a registration endpoint with validation and security measures, and automatic default profile creation. This establishes the backend foundation for all authenticated features in the platform.

## Implementation Guide for LLM Agent

### Objective
Create Django app with custom User model, Profile model, registration endpoint with email/password validation, password hashing, rate limiting, and automatic profile creation signal.

### Steps

1. Create Django app for authentication
   - Run: `python manage.py startapp users` in `pockitflyer_backend/`
   - Add `"users"` to `INSTALLED_APPS` in `pokitflyer_api/settings.py`
   - Create `users/models.py`, `users/serializers.py`, `users/views.py`, `users/urls.py`

2. Create custom User model in `users/models.py`
   - Import: `from django.contrib.auth.models import AbstractUser`
   - Define `CustomUser(AbstractUser)` with fields:
     - `email` = `EmailField(unique=True, max_length=255)`
     - `USERNAME_FIELD = "email"`
     - `REQUIRED_FIELDS = []` (override to remove username requirement)
     - Override `username` field to make it optional: `username = models.CharField(max_length=150, blank=True, null=True)`
   - Add `__str__` method returning email
   - Add `class Meta` with `db_table = "users"` and `verbose_name = "User"`

3. Create Profile model in `users/models.py`
   - Import: `from django.conf import settings`
   - Define `Profile(models.Model)` with fields:
     - `user` = `OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile")`
     - `display_name` = `CharField(max_length=100, default="Anonymous User")`
     - `bio` = `TextField(blank=True, default="")`
     - `created_at` = `DateTimeField(auto_now_add=True)`
   - Add `__str__` method returning f"{user.email} - {display_name}"
   - Add `class Meta` with `db_table = "profiles"`

4. Create post_save signal for automatic profile creation
   - In `users/models.py`, import: `from django.db.models.signals import post_save`, `from django.dispatch import receiver`
   - Define signal handler:
     ```python
     @receiver(post_save, sender=CustomUser)
     def create_user_profile(sender, instance, created, **kwargs):
         if created:
             Profile.objects.create(user=instance)
     ```
   - This automatically creates a Profile when a User is created

5. Configure AUTH_USER_MODEL in `pokitflyer_api/settings.py`
   - Add setting: `AUTH_USER_MODEL = "users.CustomUser"`
   - Update `AUTHENTICATION_BACKENDS` to use the existing EmailBackend (keep as is - it uses `get_user_model()` so will work with CustomUser)

6. Create registration serializer in `users/serializers.py`
   - Import: `from rest_framework import serializers`, `from django.contrib.auth.password_validation import validate_password`, `from .models import CustomUser`
   - Define `RegisterSerializer(serializers.ModelSerializer)`:
     - Fields: `email`, `password`, `password_confirm`
     - `password` field: `write_only=True, required=True, validators=[validate_password]`
     - `password_confirm` field: `write_only=True, required=True`
     - Override `validate()` to check `password == password_confirm`, raise `ValidationError` if not
     - Override `create()` to use `CustomUser.objects.create_user(email=..., password=...)` (ensures password hashing)
     - Return only safe fields in representation (exclude passwords)
   - Meta class: model = CustomUser, fields = ['email', 'password', 'password_confirm']

7. Create registration view in `users/views.py`
   - Import: `from rest_framework import generics, status`, `from rest_framework.response import Response`, `from rest_framework.permissions import AllowAny`, `from rest_framework.throttling import AnonRateThrottle`
   - Define custom throttle class:
     ```python
     class RegistrationRateThrottle(AnonRateThrottle):
         rate = '5/hour'  # 5 registration attempts per hour per IP
     ```
   - Define `RegisterView(generics.CreateAPIView)`:
     - `serializer_class = RegisterSerializer`
     - `permission_classes = [AllowAny]`
     - `throttle_classes = [RegistrationRateThrottle]`
     - Override `create()` method:
       - Call `serializer.save()`
       - Return `Response` with `{"message": "User created successfully", "email": user.email}` and `status=201`
       - Handle exceptions: catch `Exception` and return 400 with error details

8. Configure rate limiting in `pokitflyer_api/settings.py`
   - Add to REST_FRAMEWORK dict:
     ```python
     'DEFAULT_THROTTLE_CLASSES': [
         'rest_framework.throttling.AnonRateThrottle',
     ],
     'DEFAULT_THROTTLE_RATES': {
         'anon': '100/hour',  # General rate limit
     }
     ```

9. Create URL routing in `users/urls.py`
   - Import: `from django.urls import path`, `from .views import RegisterView`
   - Define `urlpatterns = [path('register/', RegisterView.as_view(), name='register')]`

10. Register users URLs in main `pokitflyer_api/urls.py`
    - Import: `from django.urls import include`
    - Add to `urlpatterns`: `path('api/users/', include('users.urls'))`

11. Create and run migrations
    - Run: `python manage.py makemigrations`
    - Run: `python manage.py migrate`
    - Verify migration creates `users` and `profiles` tables

12. Create comprehensive test suite in `tests/test_users_registration.py`
    - Test cases:
      - `test_register_valid_user`: Valid email/password creates user and profile, returns 201
      - `test_register_duplicate_email`: Second registration with same email returns 400
      - `test_register_invalid_email`: Malformed email returns 400
      - `test_register_weak_password`: Password too short/common returns 400
      - `test_register_password_mismatch`: password != password_confirm returns 400
      - `test_register_creates_profile`: Verify Profile object exists after registration
      - `test_register_password_hashed`: Verify password is hashed (not plain text) in database
      - `test_register_rate_limiting`: 6 rapid requests from same IP, 6th returns 429
      - `test_response_excludes_password`: Response JSON never contains password fields
    - Use Django's `APITestCase` and `APIClient`
    - Mark all tests with `@pytest.mark.tdd_red` initially

### Acceptance Criteria
- [ ] POST /api/users/register/ with valid email/password creates user and returns 201 [Test: valid credentials]
- [ ] Registration automatically creates associated Profile with default values [Test: Profile.objects.get(user=created_user) succeeds]
- [ ] Duplicate email registration returns 400 with clear error [Test: register same email twice]
- [ ] Invalid email format returns 400 with validation error [Test: 'notanemail', '@domain.com', 'user@']
- [ ] Weak passwords rejected per Django validators (min 8 chars, not all numeric, not too common) [Test: '123', 'password', 'abc']
- [ ] Password mismatch returns 400 [Test: password='Strong123!', password_confirm='Different456!']
- [ ] Passwords are hashed with bcrypt/pbkdf2 (never plain text) [Test: query database, verify hash format]
- [ ] Rate limiting blocks 6th request within 1 hour from same IP [Test: rapid POST requests]
- [ ] Response never includes password fields [Test: inspect response JSON for all scenarios]
- [ ] Tests pass with >85% coverage for users app

### Files to Create/Modify
- `pockitflyer_backend/users/__init__.py` - NEW: empty file (Django app)
- `pockitflyer_backend/users/models.py` - NEW: CustomUser and Profile models with signal
- `pockitflyer_backend/users/serializers.py` - NEW: RegisterSerializer
- `pockitflyer_backend/users/views.py` - NEW: RegisterView with rate limiting
- `pockitflyer_backend/users/urls.py` - NEW: users app URL config
- `pockitflyer_backend/users/apps.py` - NEW: UsersConfig (auto-generated)
- `pockitflyer_backend/users/admin.py` - NEW: register CustomUser and Profile in admin
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add users app, AUTH_USER_MODEL, throttle config
- `pockitflyer_backend/pokitflyer_api/urls.py` - MODIFY: include users.urls
- `pockitflyer_backend/tests/test_users_registration.py` - NEW: comprehensive registration tests
- `pockitflyer_backend/users/migrations/0001_initial.py` - NEW: generated migration

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**: Model validation (CustomUser, Profile), serializer validation (password checks, email format), signal handler (profile creation)
- **Integration tests**: Full registration endpoint with test database, verify database persistence, rate limiting behavior with TestClient

### Definition of Done
- [ ] Code written and passes all tests (mark tests `@pytest.mark.tdd_green` after verification)
- [ ] Code follows Django best practices (model Meta, proper serializer usage)
- [ ] No console errors or warnings during test runs
- [ ] Migration files committed
- [ ] Changes committed with message: "feat(users): implement user registration with profile creation"
- [ ] Ready for m02-e01-t02 (login endpoint) to use CustomUser model

## Dependencies
- Django 5.1+, djangorestframework installed (already present)
- rest_framework_simplejwt installed (already present)
- No task dependencies (first task in epic)

## Technical Notes
**Password Security:**
- Django's `create_user()` method automatically hashes passwords using settings.PASSWORD_HASHERS (default: PBKDF2)
- Never use `User.objects.create()` directly (bypasses password hashing)
- `validate_password()` enforces AUTH_PASSWORD_VALIDATORS from settings (min length, common password check, numeric check)

**Profile Creation:**
- Signal creates profile automatically, no manual creation needed
- Signal runs inside same database transaction as user creation (atomic)
- Default display_name allows users to start anonymous, can update later

**Email Backend:**
- Existing `pokitflyer_api/backends.py` EmailBackend already uses `get_user_model()`, so it will automatically work with CustomUser
- No changes needed to EmailBackend

**Rate Limiting:**
- AnonRateThrottle uses IP address for anonymous users
- Rate limits are per-view (RegistrationRateThrottle only applies to registration)
- Throttle state stored in cache (default: in-memory, resets on server restart)

**Testing Strategy:**
- Use `@pytest.mark.tdd_red` for all tests initially
- Run tests: `pytest tests/test_users_registration.py -v`
- After implementation, verify tests pass, then change marker to `@pytest.mark.tdd_green`
- Aim for >85% coverage: `pytest --cov=users tests/test_users_registration.py`

## References
- Django Custom User Model: https://docs.djangoproject.com/en/5.1/topics/auth/customizing/#substituting-a-custom-user-model
- DRF Serializers: https://www.django-rest-framework.org/api-guide/serializers/
- DRF Throttling: https://www.django-rest-framework.org/api-guide/throttling/
- Django Signals: https://docs.djangoproject.com/en/5.1/topics/signals/
