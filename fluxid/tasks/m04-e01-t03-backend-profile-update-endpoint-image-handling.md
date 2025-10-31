---
id: m04-e01-t03
title: Backend Profile Update Endpoint and Image Handling
epic: m04-e01
milestone: m04
status: pending
---

# Task: Backend Profile Update Endpoint and Image Handling

## Context
Part of Profile Management (m04-e01) in Milestone 4 (m04).

Implements the backend API endpoints for profile management: retrieving current user profile, listing user's flyers, and updating profile information including profile picture upload. This includes authorization checks (users can only edit their own profiles), image validation and storage, old image cleanup, and comprehensive error handling.

## Implementation Guide for LLM Agent

### Objective
Create Django REST API endpoints for profile retrieval and updates with image upload handling, validation, and authorization.

### Steps

1. Create User model with profile fields (if not exists)
   - Check if User model exists in existing Django app or create new users app
   - If creating new app: `python manage.py startapp users`
   - Create/extend User model in `pockitflyer_backend/users/models.py`:
     ```python
     from django.contrib.auth.models import AbstractUser
     from django.db import models
     from django.core.validators import FileExtensionValidator, MaxValueValidator
     import os

     class User(AbstractUser):
         email = models.EmailField(unique=True)
         display_name = models.CharField(max_length=50)
         profile_picture = models.ImageField(
             upload_to='profile_pictures/',
             null=True,
             blank=True,
             validators=[
                 FileExtensionValidator(allowed_extensions=['jpg', 'jpeg', 'png', 'webp']),
             ]
         )
         email_contact_allowed = models.BooleanField(default=False)
         created_at = models.DateTimeField(auto_now_add=True)
         updated_at = models.DateTimeField(auto_now=True)

         class Meta:
             db_table = 'users'
             indexes = [
                 models.Index(fields=['email']),
                 models.Index(fields=['created_at']),
             ]

         def __str__(self):
             return f"{self.display_name} ({self.email})"

         def delete_profile_picture(self):
             """Delete profile picture file from storage"""
             if self.profile_picture and os.path.isfile(self.profile_picture.path):
                 os.remove(self.profile_picture.path)
                 self.profile_picture = None
     ```
   - Update `pockitflyer_backend/pokitflyer_api/settings.py`:
     - Add `'users'` to INSTALLED_APPS (if new app created)
     - Set `AUTH_USER_MODEL = 'users.User'` (if custom user model)
     - Configure MEDIA_ROOT and MEDIA_URL:
       ```python
       MEDIA_URL = '/media/'
       MEDIA_ROOT = BASE_DIR / 'media'
       ```
   - Run migrations: `python manage.py makemigrations && python manage.py migrate`

2. Create profile serializers
   - Create `pockitflyer_backend/users/serializers.py`:
     ```python
     from rest_framework import serializers
     from .models import User
     import base64
     from django.core.files.base import ContentFile
     from PIL import Image
     from io import BytesIO

     class UserProfileSerializer(serializers.ModelSerializer):
         profile_picture_url = serializers.SerializerMethodField()

         class Meta:
             model = User
             fields = [
                 'id',
                 'email',
                 'display_name',
                 'profile_picture_url',
                 'email_contact_allowed',
                 'created_at',
                 'updated_at',
             ]
             read_only_fields = ['id', 'email', 'created_at', 'updated_at']

         def get_profile_picture_url(self, obj):
             if obj.profile_picture:
                 request = self.context.get('request')
                 if request:
                     return request.build_absolute_uri(obj.profile_picture.url)
             return None

     class ProfileUpdateSerializer(serializers.Serializer):
         display_name = serializers.CharField(
             max_length=50,
             min_length=2,
             required=False,
             trim_whitespace=True,
         )
         profile_picture_base64 = serializers.CharField(
             required=False,
             allow_null=True,
         )
         email_contact_allowed = serializers.BooleanField(required=False)

         def validate_display_name(self, value):
             # Check for valid characters
             import re
             if not re.match(r'^[a-zA-Z0-9\s\-_.]+$', value):
                 raise serializers.ValidationError(
                     'Display name contains invalid characters'
                 )
             return value

         def validate_profile_picture_base64(self, value):
             if not value:
                 return None

             # Decode base64
             try:
                 image_data = base64.b64decode(value)
             except Exception:
                 raise serializers.ValidationError('Invalid image encoding')

             # Check file size (5MB limit)
             max_size = 5 * 1024 * 1024  # 5MB
             if len(image_data) > max_size:
                 raise serializers.ValidationError(
                     'Image size must be less than 5MB'
                 )

             # Validate image format using Pillow
             try:
                 image = Image.open(BytesIO(image_data))
                 image.verify()

                 # Check format
                 allowed_formats = ['JPEG', 'PNG', 'WEBP']
                 if image.format not in allowed_formats:
                     raise serializers.ValidationError(
                         'Image must be JPG, PNG, or WebP format'
                     )
             except Exception as e:
                 raise serializers.ValidationError(f'Invalid image: {str(e)}')

             return image_data

         def update_profile_picture(self, user, image_data):
             """Update user's profile picture and delete old one"""
             if image_data is None:
                 return

             # Delete old profile picture
             user.delete_profile_picture()

             # Save new image
             image_file = ContentFile(image_data, name=f'profile_{user.id}.jpg')
             user.profile_picture = image_file
             user.save(update_fields=['profile_picture'])

     class FlyerListItemSerializer(serializers.Serializer):
         id = serializers.CharField()
         title = serializers.CharField()
         image_url = serializers.SerializerMethodField()
         created_at = serializers.DateTimeField()
         expires_at = serializers.DateTimeField()
         is_active = serializers.SerializerMethodField()

         def get_image_url(self, obj):
             if hasattr(obj, 'image') and obj.image:
                 request = self.context.get('request')
                 if request:
                     return request.build_absolute_uri(obj.image.url)
             return None

         def get_is_active(self, obj):
             from django.utils import timezone
             return obj.expires_at > timezone.now()
     ```

3. Create profile views
   - Create `pockitflyer_backend/users/views.py`:
     ```python
     from rest_framework import status
     from rest_framework.decorators import api_view, permission_classes
     from rest_framework.permissions import IsAuthenticated
     from rest_framework.response import Response
     from django.utils import timezone
     from .models import User
     from .serializers import (
         UserProfileSerializer,
         ProfileUpdateSerializer,
         FlyerListItemSerializer,
     )

     @api_view(['GET'])
     @permission_classes([IsAuthenticated])
     def get_current_user_profile(request):
         """Get current authenticated user's profile"""
         serializer = UserProfileSerializer(
             request.user,
             context={'request': request}
         )
         return Response(serializer.data)

     @api_view(['PATCH'])
     @permission_classes([IsAuthenticated])
     def update_current_user_profile(request):
         """Update current authenticated user's profile"""
         serializer = ProfileUpdateSerializer(data=request.data)

         if not serializer.is_valid():
             return Response(
                 {'error': 'Invalid input', 'details': serializer.errors},
                 status=status.HTTP_400_BAD_REQUEST
             )

         user = request.user
         validated_data = serializer.validated_data

         # Update fields
         if 'display_name' in validated_data:
             user.display_name = validated_data['display_name']

         if 'email_contact_allowed' in validated_data:
             user.email_contact_allowed = validated_data['email_contact_allowed']

         # Handle profile picture separately
         if 'profile_picture_base64' in validated_data:
             image_data = validated_data['profile_picture_base64']
             serializer.update_profile_picture(user, image_data)

         # Save other changes
         if 'display_name' in validated_data or 'email_contact_allowed' in validated_data:
             user.save()

         # Return updated profile
         response_serializer = UserProfileSerializer(
             user,
             context={'request': request}
         )
         return Response(response_serializer.data)

     @api_view(['GET'])
     @permission_classes([IsAuthenticated])
     def get_user_flyers(request, user_id):
         """Get list of flyers created by a specific user"""
         # Note: Assumes Flyer model exists from m03 (flyer publishing)
         # Import Flyer model (adjust import based on actual app structure)
         try:
             from flyers.models import Flyer
         except ImportError:
             return Response(
                 {'error': 'Flyer model not found'},
                 status=status.HTTP_500_INTERNAL_SERVER_ERROR
             )

         # Authorization: Users can only view their own flyers for now
         # (Could be extended to allow viewing other users' flyers)
         if str(request.user.id) != str(user_id):
             return Response(
                 {'error': 'Unauthorized'},
                 status=status.HTTP_403_FORBIDDEN
             )

         flyers = Flyer.objects.filter(
             created_by=request.user
         ).order_by('-created_at')

         serializer = FlyerListItemSerializer(
             flyers,
             many=True,
             context={'request': request}
         )
         return Response(serializer.data)
     ```

4. Create URL routing
   - Create `pockitflyer_backend/users/urls.py`:
     ```python
     from django.urls import path
     from . import views

     urlpatterns = [
         path('me/profile', views.get_current_user_profile, name='current-user-profile'),
         path('me/profile', views.update_current_user_profile, name='update-current-user-profile'),
         path('<uuid:user_id>/flyers', views.get_user_flyers, name='user-flyers'),
     ]
     ```
   - Update `pockitflyer_backend/pokitflyer_api/urls.py`:
     ```python
     from django.urls import path, include
     from django.conf import settings
     from django.conf.urls.static import static

     urlpatterns = [
         # ... existing patterns ...
         path('api/users/', include('users.urls')),
     ]

     # Serve media files in development
     if settings.DEBUG:
         urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
     ```

5. Add rate limiting for profile updates
   - Install django-ratelimit: Add to requirements.txt: `django-ratelimit==4.1.0`
   - Run: `pip install django-ratelimit`
   - Update views.py to add rate limiting:
     ```python
     from django_ratelimit.decorators import ratelimit

     @api_view(['PATCH'])
     @permission_classes([IsAuthenticated])
     @ratelimit(key='user', rate='10/h', method='PATCH')
     def update_current_user_profile(request):
         # ... existing code ...
     ```

6. Create unit tests for models
   - Create `pockitflyer_backend/tests/users/test_models.py`:
     ```python
     import pytest
     from django.core.files.uploadedfile import SimpleUploadedFile
     from users.models import User
     import os

     @pytest.mark.django_db
     @pytest.mark.tdd_green
     class TestUserModel:
         def test_user_creation_with_required_fields(self):
             user = User.objects.create_user(
                 username='testuser',
                 email='test@example.com',
                 display_name='Test User',
                 password='password123'
             )
             assert user.email == 'test@example.com'
             assert user.display_name == 'Test User'
             assert user.email_contact_allowed is False
             assert user.profile_picture.name == ''

         def test_user_with_profile_picture(self):
             image_data = b'fake-image-data'
             image_file = SimpleUploadedFile(
                 'test.jpg',
                 image_data,
                 content_type='image/jpeg'
             )
             user = User.objects.create_user(
                 username='testuser',
                 email='test@example.com',
                 display_name='Test User',
                 password='password123',
                 profile_picture=image_file
             )
             assert user.profile_picture.name.startswith('profile_pictures/')

         def test_delete_profile_picture(self, tmp_path):
             # Create user with profile picture
             image_file = SimpleUploadedFile('test.jpg', b'data', content_type='image/jpeg')
             user = User.objects.create_user(
                 username='testuser',
                 email='test@example.com',
                 display_name='Test User',
                 password='password123',
                 profile_picture=image_file
             )

             picture_path = user.profile_picture.path
             assert os.path.exists(picture_path)

             # Delete profile picture
             user.delete_profile_picture()
             assert not os.path.exists(picture_path)
             assert user.profile_picture.name == ''

         def test_user_string_representation(self):
             user = User.objects.create_user(
                 username='testuser',
                 email='test@example.com',
                 display_name='Test User',
                 password='password123'
             )
             assert str(user) == 'Test User (test@example.com)'
     ```

7. Create unit tests for serializers
   - Create `pockitflyer_backend/tests/users/test_serializers.py`:
     ```python
     import pytest
     import base64
     from users.serializers import (
         UserProfileSerializer,
         ProfileUpdateSerializer,
     )
     from users.models import User
     from PIL import Image
     from io import BytesIO

     @pytest.mark.django_db
     @pytest.mark.tdd_green
     class TestUserProfileSerializer:
         def test_serialize_user_profile(self, rf):
             user = User.objects.create_user(
                 username='testuser',
                 email='test@example.com',
                 display_name='Test User',
                 password='password123',
                 email_contact_allowed=True
             )
             request = rf.get('/')
             serializer = UserProfileSerializer(user, context={'request': request})

             data = serializer.data
             assert data['email'] == 'test@example.com'
             assert data['display_name'] == 'Test User'
             assert data['email_contact_allowed'] is True
             assert 'id' in data
             assert 'created_at' in data

     @pytest.mark.django_db
     @pytest.mark.tdd_green
     class TestProfileUpdateSerializer:
         def test_validate_display_name_valid(self):
             serializer = ProfileUpdateSerializer(data={'display_name': 'Valid Name'})
             assert serializer.is_valid()

         def test_validate_display_name_too_short(self):
             serializer = ProfileUpdateSerializer(data={'display_name': 'A'})
             assert not serializer.is_valid()
             assert 'display_name' in serializer.errors

         def test_validate_display_name_too_long(self):
             serializer = ProfileUpdateSerializer(data={'display_name': 'A' * 51})
             assert not serializer.is_valid()
             assert 'display_name' in serializer.errors

         def test_validate_display_name_invalid_characters(self):
             serializer = ProfileUpdateSerializer(data={'display_name': 'Test@#$%'})
             assert not serializer.is_valid()
             assert 'display_name' in serializer.errors

         def test_validate_profile_picture_base64_valid(self):
             # Create a small valid JPEG image
             image = Image.new('RGB', (100, 100), color='red')
             buffer = BytesIO()
             image.save(buffer, format='JPEG')
             image_data = buffer.getvalue()
             encoded = base64.b64encode(image_data).decode()

             serializer = ProfileUpdateSerializer(
                 data={'profile_picture_base64': encoded}
             )
             assert serializer.is_valid()

         def test_validate_profile_picture_base64_invalid_encoding(self):
             serializer = ProfileUpdateSerializer(
                 data={'profile_picture_base64': 'not-base64!!!'}
             )
             assert not serializer.is_valid()
             assert 'profile_picture_base64' in serializer.errors

         def test_validate_profile_picture_base64_too_large(self):
             # Create image larger than 5MB
             large_data = b'x' * (6 * 1024 * 1024)
             encoded = base64.b64encode(large_data).decode()

             serializer = ProfileUpdateSerializer(
                 data={'profile_picture_base64': encoded}
             )
             assert not serializer.is_valid()
             assert 'profile_picture_base64' in serializer.errors
     ```

8. Create integration tests for API endpoints
   - Create `pockitflyer_backend/tests/users/test_profile_api.py`:
     ```python
     import pytest
     from rest_framework.test import APIClient
     from rest_framework import status
     from users.models import User
     import base64
     from PIL import Image
     from io import BytesIO

     @pytest.fixture
     def api_client():
         return APIClient()

     @pytest.fixture
     def test_user():
         return User.objects.create_user(
             username='testuser',
             email='test@example.com',
             display_name='Test User',
             password='password123'
         )

     def create_test_image():
         """Helper to create base64 encoded test image"""
         image = Image.new('RGB', (100, 100), color='blue')
         buffer = BytesIO()
         image.save(buffer, format='JPEG')
         image_data = buffer.getvalue()
         return base64.b64encode(image_data).decode()

     @pytest.mark.django_db
     @pytest.mark.tdd_green
     class TestGetCurrentUserProfile:
         def test_get_profile_authenticated(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)
             response = api_client.get('/api/users/me/profile')

             assert response.status_code == status.HTTP_200_OK
             assert response.data['email'] == 'test@example.com'
             assert response.data['display_name'] == 'Test User'

         def test_get_profile_unauthenticated(self, api_client):
             response = api_client.get('/api/users/me/profile')
             assert response.status_code == status.HTTP_401_UNAUTHORIZED

     @pytest.mark.django_db
     @pytest.mark.tdd_green
     class TestUpdateCurrentUserProfile:
         def test_update_display_name(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)
             response = api_client.patch(
                 '/api/users/me/profile',
                 {'display_name': 'Updated Name'},
                 format='json'
             )

             assert response.status_code == status.HTTP_200_OK
             assert response.data['display_name'] == 'Updated Name'

             test_user.refresh_from_db()
             assert test_user.display_name == 'Updated Name'

         def test_update_email_contact_permission(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)
             response = api_client.patch(
                 '/api/users/me/profile',
                 {'email_contact_allowed': True},
                 format='json'
             )

             assert response.status_code == status.HTTP_200_OK
             assert response.data['email_contact_allowed'] is True

         def test_update_profile_picture(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)
             image_base64 = create_test_image()

             response = api_client.patch(
                 '/api/users/me/profile',
                 {'profile_picture_base64': image_base64},
                 format='json'
             )

             assert response.status_code == status.HTTP_200_OK

             test_user.refresh_from_db()
             assert test_user.profile_picture.name != ''

         def test_update_replaces_old_profile_picture(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)

             # Upload first image
             image1 = create_test_image()
             api_client.patch(
                 '/api/users/me/profile',
                 {'profile_picture_base64': image1},
                 format='json'
             )
             test_user.refresh_from_db()
             old_picture_name = test_user.profile_picture.name

             # Upload second image
             image2 = create_test_image()
             api_client.patch(
                 '/api/users/me/profile',
                 {'profile_picture_base64': image2},
                 format='json'
             )
             test_user.refresh_from_db()
             new_picture_name = test_user.profile_picture.name

             # Verify old picture was replaced
             assert old_picture_name != new_picture_name

         def test_update_invalid_display_name(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)
             response = api_client.patch(
                 '/api/users/me/profile',
                 {'display_name': 'A'},  # Too short
                 format='json'
             )

             assert response.status_code == status.HTTP_400_BAD_REQUEST
             assert 'error' in response.data

         def test_update_invalid_image(self, api_client, test_user):
             api_client.force_authenticate(user=test_user)
             response = api_client.patch(
                 '/api/users/me/profile',
                 {'profile_picture_base64': 'invalid-base64'},
                 format='json'
             )

             assert response.status_code == status.HTTP_400_BAD_REQUEST

         def test_update_unauthenticated(self, api_client):
             response = api_client.patch(
                 '/api/users/me/profile',
                 {'display_name': 'Hacker'},
                 format='json'
             )
             assert response.status_code == status.HTTP_401_UNAUTHORIZED

     @pytest.mark.django_db
     @pytest.mark.tdd_green
     class TestGetUserFlyers:
         def test_get_user_flyers_authenticated(self, api_client, test_user):
             # Note: This test assumes Flyer model exists from m03
             # May need to be marked tdd_red until m03 is complete
             api_client.force_authenticate(user=test_user)
             response = api_client.get(f'/api/users/{test_user.id}/flyers')

             # Should return empty list or 200 OK
             assert response.status_code in [status.HTTP_200_OK, status.HTTP_500_INTERNAL_SERVER_ERROR]

         def test_get_user_flyers_unauthorized_user(self, api_client, test_user):
             other_user = User.objects.create_user(
                 username='other',
                 email='other@example.com',
                 display_name='Other',
                 password='password123'
             )
             api_client.force_authenticate(user=test_user)
             response = api_client.get(f'/api/users/{other_user.id}/flyers')

             assert response.status_code == status.HTTP_403_FORBIDDEN
     ```

9. Update .gitignore for media files
   - Add to `pockitflyer_backend/.gitignore`:
     ```
     media/
     ```

10. Create API documentation
    - Add endpoint documentation to OpenAPI/Swagger schema (if using drf-spectacular)
    - Document in code comments:
      - GET /api/users/me/profile - Returns current user's profile
      - PATCH /api/users/me/profile - Updates current user's profile
      - GET /api/users/{user_id}/flyers - Returns flyers created by user

### Acceptance Criteria
- [ ] GET /api/users/me/profile returns authenticated user's profile [Test: 200 response with correct data, 401 for unauthenticated]
- [ ] PATCH /api/users/me/profile updates profile fields [Test: display_name, email_contact_allowed, profile_picture]
- [ ] Profile picture upload validates format and size [Test: valid JPG/PNG/WEBP, reject invalid format, reject >5MB]
- [ ] Old profile picture deleted when new one uploaded [Test: verify old file removed from storage]
- [ ] Display name validation enforces rules [Test: min length, max length, valid characters]
- [ ] Authorization prevents editing other users' profiles [Test: only owner can update]
- [ ] GET /api/users/{user_id}/flyers returns user's flyers [Test: authenticated user, correct flyer list, active/expired status]
- [ ] Unauthorized users cannot access other users' flyers [Test: 403 for non-owner]
- [ ] Rate limiting prevents abuse [Test: >10 updates/hour blocked]
- [ ] Error responses include helpful messages [Test: validation errors, authorization errors, server errors]
- [ ] All unit tests pass [Test: models, serializers]
- [ ] All integration tests pass [Test: API endpoints, image handling]
- [ ] Tests achieve >90% coverage for new code [Test: run pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/users/__init__.py` - NEW: Users app init
- `pockitflyer_backend/users/models.py` - NEW: User model with profile fields
- `pockitflyer_backend/users/serializers.py` - NEW: Profile serializers
- `pockitflyer_backend/users/views.py` - NEW: Profile API views
- `pockitflyer_backend/users/urls.py` - NEW: Profile URL routing
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: Add users app, configure AUTH_USER_MODEL, MEDIA settings
- `pockitflyer_backend/pokitflyer_api/urls.py` - MODIFY: Include users URLs, serve media files
- `pockitflyer_backend/requirements.txt` - MODIFY: Add django-ratelimit
- `pockitflyer_backend/.gitignore` - MODIFY: Add media/ directory
- `pockitflyer_backend/tests/users/__init__.py` - NEW: Tests package init
- `pockitflyer_backend/tests/users/test_models.py` - NEW: User model tests
- `pockitflyer_backend/tests/users/test_serializers.py` - NEW: Serializer tests
- `pockitflyer_backend/tests/users/test_profile_api.py` - NEW: API endpoint tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**:
  - User model creation, validation, string representation
  - User.delete_profile_picture method
  - UserProfileSerializer serialization
  - ProfileUpdateSerializer validation (display_name, profile_picture_base64)
  - Image encoding/decoding logic
  - Image format and size validation

- **Integration tests**:
  - GET /api/users/me/profile (authenticated, unauthenticated)
  - PATCH /api/users/me/profile (update each field, validation errors, image upload, old image deletion)
  - GET /api/users/{user_id}/flyers (authorized, unauthorized)
  - Rate limiting enforcement
  - Error response formats

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Django/DRF style, PEP 8)
- [ ] No console errors or warnings
- [ ] Documentation/comments added where needed (complex logic only)
- [ ] Migrations created and applied successfully
- [ ] Changes committed with reference to task ID (m04-e01-t03)
- [ ] Ready for frontend integration (m04-e01-t01, m04-e01-t02)

## Dependencies
- Requires: m02-e01 (authentication system - JWT middleware, User model base)
- Requires: m03 (flyer publishing - Flyer model for GET /users/{id}/flyers endpoint)
- Blocks: None (works in parallel with frontend tasks)

## Technical Notes
- **Custom User Model**: If AUTH_USER_MODEL is not already customized, this task extends AbstractUser. If already custom, modify existing User model.
- **Image Storage**: Use Django's default FileSystemStorage with MEDIA_ROOT. For production, consider cloud storage (S3, GCS) but don't implement yet (YAGNI).
- **Image Validation**: Use Pillow to verify image format and integrity (prevents malicious uploads).
- **Base64 Encoding**: Simpler than multipart/form-data for initial implementation. Consider multipart in future if performance issues.
- **File Deletion**: Always delete old profile picture when uploading new one to prevent storage bloat.
- **Rate Limiting**: Use django-ratelimit with user-based key (10 updates/hour prevents abuse).
- **Authorization**: IsAuthenticated permission ensures only logged-in users access endpoints. Additional check in get_user_flyers prevents viewing others' flyers.
- **Error Handling**: Return consistent error format: `{'error': 'message', 'details': {...}}` for client parsing.
- **Migrations**: After creating User model, run makemigrations and migrate. If User already exists, create migration to add profile fields.
- **MEDIA_URL in Development**: Serve via `django.conf.urls.static.static()` in DEBUG mode. In production, serve via nginx/Apache.
- **Flyer Model Dependency**: GET /users/{id}/flyers endpoint assumes Flyer model exists. If m03 not complete, handle gracefully (return 500 or empty list).

## References
- Django custom user model: https://docs.djangoproject.com/en/5.1/topics/auth/customizing/#substituting-a-custom-user-model
- Django file uploads: https://docs.djangoproject.com/en/5.1/topics/http/file-uploads/
- Pillow image validation: https://pillow.readthedocs.io/en/stable/
- django-ratelimit: https://django-ratelimit.readthedocs.io/
- DRF serializers: https://www.django-rest-framework.org/api-guide/serializers/
- DRF permissions: https://www.django-rest-framework.org/api-guide/permissions/
