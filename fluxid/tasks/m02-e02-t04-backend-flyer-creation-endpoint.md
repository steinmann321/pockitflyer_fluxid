---
id: m02-e02-t04
title: Backend Flyer Creation Endpoint with Validation
epic: m02-e02
milestone: m02
status: pending
---

# Task: Backend Flyer Creation Endpoint with Validation

## Context
Part of Flyer Creation & Publishing (m02-e02) in Milestone m02 (Authenticated User Experience).

Implements the RESTful API endpoint for creating flyers with comprehensive validation. This endpoint receives multipart form data from the frontend (t01-t03), validates all fields, associates the flyer with the authenticated user, and stores it in the database. Works with image upload (t05) and geocoding (t06) to create complete flyer records.

## Implementation Guide for LLM Agent

### Objective
Create POST /api/flyers/ endpoint with JWT authentication, multipart form data handling, field validation, user association, and database persistence.

### Steps

1. Create Flyer model
   - File: `pockitflyer_backend/flyers/models.py`
   ```python
   # Flyer model structure
   class Flyer(models.Model):
       # Relationships
       creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='flyers')

       # Basic fields
       title = models.CharField(max_length=100)
       info_field_1 = models.TextField(max_length=500, blank=True)
       info_field_2 = models.TextField(max_length=500, blank=True)

       # Location
       address = models.CharField(max_length=200)
       latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
       longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

       # Categories (M2M or JSONField)
       # Option 1: M2M with Category model
       # categories = models.ManyToManyField('Category', related_name='flyers')
       # Option 2: JSONField for simplicity
       categories = models.JSONField(default=list)  # ['events', 'nightlife', 'service']

       # Dates
       publication_date = models.DateTimeField()
       expiration_date = models.DateTimeField(null=True, blank=True)

       # Timestamps
       created_at = models.DateTimeField(auto_now_add=True)
       updated_at = models.DateTimeField(auto_now=True)

       # Database indexes (performance)
       class Meta:
           indexes = [
               models.Index(fields=['publication_date']),
               models.Index(fields=['expiration_date']),
               models.Index(fields=['latitude', 'longitude']),
               models.Index(fields=['creator']),
           ]
           ordering = ['-publication_date']
   ```

2. Create FlyerImage model (for M2M relationship)
   ```python
   class FlyerImage(models.Model):
       flyer = models.ForeignKey(Flyer, on_delete=models.CASCADE, related_name='images')
       image = models.ImageField(upload_to='flyer_images/')
       order = models.PositiveSmallIntegerField(default=0)
       uploaded_at = models.DateTimeField(auto_now_add=True)

       class Meta:
           ordering = ['order']
           unique_together = ['flyer', 'order']
   ```

3. Create migrations
   - Run: `python manage.py makemigrations flyers`
   - Run: `python manage.py migrate`
   - Verify migration files created

4. Create Flyer serializer
   - File: `pockitflyer_backend/flyers/serializers.py`
   ```python
   class FlyerSerializer(serializers.ModelSerializer):
       # Read-only fields
       creator = UserSerializer(read_only=True)
       images = FlyerImageSerializer(many=True, read_only=True)

       class Meta:
           model = Flyer
           fields = [
               'id', 'creator', 'title', 'info_field_1', 'info_field_2',
               'address', 'latitude', 'longitude', 'categories',
               'publication_date', 'expiration_date', 'images',
               'created_at', 'updated_at'
           ]
           read_only_fields = ['id', 'creator', 'latitude', 'longitude', 'created_at', 'updated_at']

       def validate_title(self, value):
           if not value or len(value.strip()) == 0:
               raise serializers.ValidationError("Title is required")
           if len(value) > 100:
               raise serializers.ValidationError("Title must be 100 characters or less")
           return value.strip()

       def validate_categories(self, value):
           valid_categories = ['events', 'nightlife', 'service']
           if not value or len(value) == 0:
               raise serializers.ValidationError("At least one category is required")
           for category in value:
               if category not in valid_categories:
                   raise serializers.ValidationError(f"Invalid category: {category}")
           return value

       def validate_publication_date(self, value):
           if value < timezone.now():
               raise serializers.ValidationError("Publication date cannot be in the past")
           return value

       def validate(self, data):
           # Cross-field validation
           if data.get('expiration_date'):
               if data['expiration_date'] <= data['publication_date']:
                   raise serializers.ValidationError(
                       "Expiration date must be after publication date"
                   )
           return data
   ```

5. Create flyer creation view
   - File: `pockitflyer_backend/flyers/views.py`
   ```python
   from rest_framework import viewsets, status
   from rest_framework.decorators import action
   from rest_framework.response import Response
   from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
   from django.utils import timezone

   class FlyerViewSet(viewsets.ModelViewSet):
       queryset = Flyer.objects.all()
       serializer_class = FlyerSerializer
       permission_classes = [IsAuthenticatedOrReadOnly]

       def perform_create(self, serializer):
           # Associate flyer with authenticated user
           # Geocoding will be handled separately (t06)
           # Image upload will be handled separately (t05)
           serializer.save(creator=self.request.user)

       def create(self, request, *args, **kwargs):
           # Handle multipart form data
           serializer = self.get_serializer(data=request.data)
           serializer.is_valid(raise_exception=True)
           self.perform_create(serializer)

           headers = self.get_success_headers(serializer.data)
           return Response(
               serializer.data,
               status=status.HTTP_201_CREATED,
               headers=headers
           )
   ```

6. Register URL routes
   - File: `pockitflyer_backend/flyers/urls.py` (NEW)
   ```python
   from django.urls import path, include
   from rest_framework.routers import DefaultRouter
   from .views import FlyerViewSet

   router = DefaultRouter()
   router.register(r'flyers', FlyerViewSet, basename='flyer')

   urlpatterns = [
       path('', include(router.urls)),
   ]
   ```

7. Include flyer URLs in main URL config
   - File: `pockitflyer_backend/pockitflyer_backend/urls.py` (MODIFY)
   ```python
   urlpatterns = [
       # ... existing patterns
       path('api/', include('flyers.urls')),
   ]
   ```

8. Create model validation tests
   - File: `pockitflyer_backend/flyers/tests/test_models.py`
   - Test: Flyer creation with valid data
   - Test: Flyer creation with creator (FK constraint)
   - Test: Required fields (title, address, publication_date)
   - Test: Optional fields (info_field_1, info_field_2, expiration_date)
   - Test: Field length limits (title 100, info 500, address 200)
   - Test: Categories as JSON list
   - Test: Timestamps auto-populated (created_at, updated_at)

9. Create serializer validation tests
   - File: `pockitflyer_backend/flyers/tests/test_serializers.py`
   - Test: Valid flyer data serialization
   - Test: Title required validation
   - Test: Title length validation (>100 chars)
   - Test: Categories required validation (empty list)
   - Test: Categories valid values (events/nightlife/service)
   - Test: Invalid category rejected
   - Test: Publication date in past rejected
   - Test: Expiration date before publication rejected
   - Test: Expiration date after publication accepted

10. Create API endpoint tests
    - File: `pockitflyer_backend/flyers/tests/test_views.py`
    - Test: POST /api/flyers/ with valid data returns 201
    - Test: POST /api/flyers/ without auth returns 401
    - Test: POST /api/flyers/ with invalid data returns 400
    - Test: POST /api/flyers/ associates creator with authenticated user
    - Test: POST /api/flyers/ missing required fields returns 400
    - Test: POST /api/flyers/ with XSS attempt sanitizes input
    - Test: GET /api/flyers/ returns list (from m01)
    - Test: Created flyer immediately queryable in list endpoint

11. Add XSS protection
    - Ensure DRF's default HTML sanitization is enabled
    - Test: HTML tags in title/info fields are escaped
    - Test: Script tags in input are sanitized

### Acceptance Criteria
- [ ] POST /api/flyers/ creates flyer with valid data [Test: send valid payload, verify 201]
- [ ] Endpoint requires JWT authentication [Test: send without token, verify 401]
- [ ] Flyer associated with authenticated user [Test: create flyer, verify creator field]
- [ ] Title validation: required, 1-100 chars [Test: empty, >100 chars, valid]
- [ ] Info fields optional, max 500 chars [Test: 501 chars, 500 chars, null]
- [ ] Address required, max 200 chars [Test: empty, >200 chars, valid]
- [ ] Categories required, at least 1 [Test: empty list, valid list]
- [ ] Categories validate against allowed values [Test: invalid category, verify 400]
- [ ] Publication date cannot be in past [Test: yesterday's date, verify 400]
- [ ] Expiration date optional [Test: create without expiration, verify 201]
- [ ] Expiration date must be after publication [Test: exp before pub, verify 400]
- [ ] XSS attempts sanitized [Test: `<script>` in title, verify escaped]
- [ ] Created flyer returned in response [Test: verify response contains flyer data]
- [ ] Created flyer queryable via GET /api/flyers/ [Test: create, then list, verify present]
- [ ] Unit tests pass with ≥90% coverage
- [ ] Integration tests pass

### Files to Create/Modify
- `pockitflyer_backend/flyers/__init__.py` - NEW: app initialization
- `pockitflyer_backend/flyers/models.py` - NEW: Flyer and FlyerImage models
- `pockitflyer_backend/flyers/serializers.py` - NEW: FlyerSerializer
- `pockitflyer_backend/flyers/views.py` - NEW: FlyerViewSet
- `pockitflyer_backend/flyers/urls.py` - NEW: flyer routes
- `pockitflyer_backend/pockitflyer_backend/urls.py` - MODIFY: include flyer URLs
- `pockitflyer_backend/pockitflyer_backend/settings.py` - MODIFY: add 'flyers' to INSTALLED_APPS
- `pockitflyer_backend/flyers/tests/test_models.py` - NEW: model tests
- `pockitflyer_backend/flyers/tests/test_serializers.py` - NEW: serializer tests
- `pockitflyer_backend/flyers/tests/test_views.py` - NEW: API tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**:
  - Model field validation (lengths, required/optional)
  - Serializer validation (title, categories, dates)
  - Cross-field validation (expiration after publication)

- **Integration tests** (with test database):
  - Complete API endpoint flow (POST → database → GET)
  - Authentication requirement enforcement
  - User association (creator FK)
  - Invalid data rejection (400 responses)
  - XSS protection

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Django and project conventions
- [ ] All tests marked with appropriate TDD markers
- [ ] Migrations created and applied
- [ ] API documented (docstrings or schema)
- [ ] Changes committed with `m02-e02-t04` reference
- [ ] Ready for integration with t05 (images) and t06 (geocoding)

## Dependencies
- Requires: m02-e01 (JWT authentication, User model)
- Requires: m01-e01 (Flyer API structure from milestone 1, if applicable)
- Requires: m02-e02-t01, t02, t03 (frontend sends complete flyer data)
- Blocks: m02-e02-t05 (image upload needs Flyer instance)
- Blocks: m02-e02-t06 (geocoding updates Flyer lat/lng)

## Technical Notes

**Model Design Decisions**:
- **Categories**: Use JSONField for simplicity (3 fixed values). If categories become dynamic, migrate to M2M with Category model.
- **Images**: M2M relationship via FlyerImage model allows ordering and metadata per image.
- **Coordinates**: Stored as DecimalField for precision, populated by geocoding service (t06).

**Validation Strategy**:
- Field-level: in serializer methods (`validate_title`, `validate_categories`)
- Cross-field: in serializer `validate()` method (expiration vs publication)
- Model-level: only for database constraints, not business logic

**Security Considerations**:
- JWT authentication required for creation (IsAuthenticated permission)
- XSS protection via DRF's HTML escaping (enabled by default)
- SQL injection prevented by Django ORM
- Creator field never writable (set from `request.user`)

**Database Indexes**:
- `publication_date`: for ranking by recency
- `latitude, longitude`: for proximity queries (composite index)
- `creator`: for user's flyers queries

**API Response Format**:
```json
{
  "id": 1,
  "creator": {
    "id": 5,
    "email": "user@example.com",
    "name": "User Name"
  },
  "title": "Sample Flyer",
  "info_field_1": "Additional info",
  "info_field_2": "More info",
  "address": "123 Main St, City, State",
  "latitude": null,
  "longitude": null,
  "categories": ["events", "nightlife"],
  "publication_date": "2025-01-20T10:00:00Z",
  "expiration_date": "2025-02-20T10:00:00Z",
  "images": [],
  "created_at": "2025-01-15T09:30:00Z",
  "updated_at": "2025-01-15T09:30:00Z"
}
```

**Integration with Frontend**:
- Endpoint accepts multipart/form-data for future image upload
- Currently handles JSON payload with flyer metadata
- Images will be added in t05 via separate handling

**Feed Integration**:
- Created flyers immediately queryable via existing GET /api/flyers/ endpoint (from m01)
- Respect m01 ranking algorithm (recency, proximity, relevance)
- Filter out expired flyers (expiration_date < now)

## References
- Django REST Framework viewsets: https://www.django-rest-framework.org/api-guide/viewsets/
- DRF validation: https://www.django-rest-framework.org/api-guide/validators/
- Django model indexes: https://docs.djangoproject.com/en/stable/ref/models/indexes/
- DRF permissions: https://www.django-rest-framework.org/api-guide/permissions/
