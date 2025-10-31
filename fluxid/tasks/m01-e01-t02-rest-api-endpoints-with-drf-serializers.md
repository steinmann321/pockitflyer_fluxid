---
id: m01-e01-t02
title: REST API Endpoints with DRF Serializers
epic: m01-e01
milestone: m01
status: pending
---

# Task: REST API Endpoints with DRF Serializers

## Context
Part of Backend Flyer API and Data Services (m01-e01) in Milestone 1: Anonymous Flyer Browsing (m01).

Creates REST API endpoints using Django REST Framework to serve flyer data for the iOS app. Implements serializers for data transformation, viewsets for CRUD operations, pagination for performance, and URL routing. This task focuses on the API layer only - filtering, search, and ranking logic will be added in subsequent tasks.

## Implementation Guide for LLM Agent

### Objective
Create DRF serializers and viewsets for Flyer, Creator, and Location models with proper nested serialization, pagination, and basic CRUD endpoints to support anonymous browsing.

### Steps

1. **Create serializers** in `pockitflyer_backend/flyers/serializers.py`

   **LocationSerializer**:
   - Fields: `id`, `address`, `latitude`, `longitude`, `city`, `country`
   - Read-only: `id`, `geocoded_at`
   - Validation: Inherit from model validation (already in m01-e01-t01)

   **CreatorSerializer** (public profile version):
   - Fields: `id`, `display_name`, `bio`, `avatar_url`, `created_at`
   - Exclude: `email` (privacy - not exposed in public API)
   - Read-only: `id`, `created_at`

   **FlyerListSerializer** (optimized for feed):
   - Fields: `id`, `title`, `category`, `thumbnail_url`, `valid_from`, `valid_until`, `created_at`, `location`, `creator`
   - Nested: `location` (LocationSerializer), `creator` (CreatorSerializer with only id, display_name)
   - Use `select_related('creator', 'location')` in viewset to avoid N+1 queries

   **FlyerDetailSerializer** (full flyer details):
   - Fields: all FlyerListSerializer fields plus `description`, `image_url`
   - Nested: full `location` and `creator` serializers
   - Computed field: `is_valid` (uses model's `is_currently_valid()` method)

2. **Create viewsets** in `pockitflyer_backend/flyers/views.py`

   **FlyerViewSet** (ModelViewSet):
   - Queryset: `Flyer.objects.filter(is_active=True).select_related('creator', 'location').order_by('-created_at')`
   - Serializer: Use `get_serializer_class()` to return FlyerListSerializer for list, FlyerDetailSerializer for retrieve
   - Permissions: `AllowAny` (anonymous browsing)
   - Pagination: 20 items per page (configure in settings)
   - Actions: `list` (GET /flyers/), `retrieve` (GET /flyers/{id}/)
   - Disable: `create`, `update`, `delete` (read-only API for now)

   **CreatorViewSet** (ReadOnlyModelViewSet):
   - Queryset: `Creator.objects.all()`
   - Serializer: CreatorSerializer
   - Permissions: `AllowAny`
   - Actions: `retrieve` (GET /creators/{id}/) - returns creator profile
   - Custom action: `flyers` (GET /creators/{id}/flyers/) - returns all active flyers by this creator
     - Use `@action(detail=True, methods=['get'])`
     - Return paginated list of creator's flyers using FlyerListSerializer

3. **Configure pagination** in `pockitflyer_backend/pokitflyer_api/settings.py`
   - Add to REST_FRAMEWORK dict:
     ```python
     'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
     'PAGE_SIZE': 20
     ```
   - This enables pagination across all viewsets

4. **Create URL routing** in `pockitflyer_backend/flyers/urls.py` (NEW file)
   - Use DRF DefaultRouter
   - Register FlyerViewSet at `flyers/` basename
   - Register CreatorViewSet at `creators/` basename
   - Router will generate:
     - GET /api/flyers/ (list)
     - GET /api/flyers/{id}/ (detail)
     - GET /api/creators/{id}/ (profile)
     - GET /api/creators/{id}/flyers/ (creator's flyers)

5. **Update main URL config** in `pockitflyer_backend/pokitflyer_api/urls.py`
   - Include flyers.urls under `/api/` path
   - Example: `path('api/', include('flyers.urls'))`

6. **Create comprehensive test suite** in `pockitflyer_backend/flyers/tests/test_api.py`

   **Serializer tests**:
   - LocationSerializer: verify all fields serialized correctly
   - CreatorSerializer: verify email is excluded, only public fields exposed
   - FlyerListSerializer: verify nested serialization, thumbnail_url included
   - FlyerDetailSerializer: verify full data including description, image_url, is_valid computed field

   **API endpoint tests** (use Django REST Framework's APITestCase):
   - **GET /api/flyers/**:
     - Returns 200 with paginated list
     - Contains only active flyers (is_active=True)
     - Ordered by created_at descending (newest first)
     - Includes nested creator and location data
     - Pagination metadata present (count, next, previous)
     - Empty result set returns 200 with empty results array
   - **GET /api/flyers/{id}/**:
     - Returns 200 with full flyer details
     - Includes description and image_url
     - Includes is_valid computed field
     - Non-existent ID returns 404
     - Inactive flyer (is_active=False) returns 404
   - **GET /api/creators/{id}/**:
     - Returns 200 with creator profile
     - Email field not present in response
     - Non-existent ID returns 404
   - **GET /api/creators/{id}/flyers/**:
     - Returns 200 with paginated list of creator's active flyers
     - Only includes flyers by this creator
     - Non-existent creator returns 404
     - Creator with no flyers returns empty results
   - **Performance tests**:
     - N+1 query check: List endpoint makes constant queries regardless of result count
     - Pagination: Verify PAGE_SIZE limit enforced

   **Error handling tests**:
   - Invalid flyer ID format returns 404
   - Malformed request parameters handled gracefully

7. **Create test fixtures** in `pockitflyer_backend/flyers/tests/factories.py` (optional but recommended)
   - Use factory_boy or Django fixtures to create test data
   - FlyerFactory, CreatorFactory, LocationFactory for reusable test objects
   - Reduces test code duplication

### Acceptance Criteria
- [ ] GET /api/flyers/ returns paginated list of active flyers [Test: create 25 flyers, verify pagination]
- [ ] GET /api/flyers/{id}/ returns full flyer details [Test: retrieve specific flyer]
- [ ] GET /api/creators/{id}/ returns public creator profile without email [Test: verify response excludes email field]
- [ ] GET /api/creators/{id}/flyers/ returns creator's flyers [Test: creator with 5 flyers]
- [ ] Nested serialization includes creator and location data [Test: verify nested objects in response]
- [ ] Pagination set to 20 items per page [Test: create 21 flyers, verify page 1 has 20, page 2 has 1]
- [ ] Inactive flyers excluded from results [Test: create active and inactive flyers, verify only active returned]
- [ ] Results ordered by created_at descending [Test: create flyers with different timestamps, verify order]
- [ ] No N+1 query issues in list endpoint [Test: Django Debug Toolbar or assertNumQueries]
- [ ] All endpoints return proper status codes (200, 404) [Test: various scenarios]
- [ ] All tests pass with >90% coverage [Test: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/serializers.py` - NEW: LocationSerializer, CreatorSerializer, FlyerListSerializer, FlyerDetailSerializer
- `pockitflyer_backend/flyers/views.py` - NEW: FlyerViewSet, CreatorViewSet
- `pockitflyer_backend/flyers/urls.py` - NEW: DRF router configuration
- `pockitflyer_backend/pokitflyer_api/urls.py` - MODIFY: include flyers.urls under /api/
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add pagination settings to REST_FRAMEWORK
- `pockitflyer_backend/flyers/tests/test_api.py` - NEW: API endpoint tests
- `pockitflyer_backend/flyers/tests/factories.py` - NEW (optional): test data factories

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: Serializer field inclusion/exclusion, nested serialization, computed fields, validation
- **Integration tests**: Full API requests with test database, pagination behavior, query optimization (select_related), filtering by is_active, ordering

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows DRF conventions and project YAGNI principles
- [ ] No N+1 queries in list endpoints (verified via testing)
- [ ] Minimal documentation for non-obvious serializer choices
- [ ] Changes committed with reference to task ID (m01-e01-t02)
- [ ] All TDD markers set to `tdd_green` after verifying tests pass
- [ ] Ready for m01-e01-t04 and m01-e01-t05 to add filtering and ranking

## Dependencies
- Requires: m01-e01-t01 (Django models must exist)
- Blocks: m01-e01-t04 (ranking algorithm), m01-e01-t05 (filters/search)

## Technical Notes

### Serializer Design
Per ARCHITECTURE.md: "Business logic enforced at model layer, not in serializers/views"
- Serializers handle data transformation only, not validation
- Model validation already implemented in m01-e01-t01
- Use `read_only=True` for computed fields and auto-timestamps

### N+1 Query Prevention
Critical for performance with nested serialization:
- Use `select_related()` for ForeignKey relationships (creator, location)
- Verify query count doesn't increase with result set size
- Test with Django's `assertNumQueries()` or django-debug-toolbar

### Pagination Strategy
Per epic notes: "Pagination for large result sets"
- DRF's PageNumberPagination is simple and sufficient for MVP
- Page size of 20 balances mobile performance with UX
- Can optimize later with CursorPagination if needed

### API Design Principles
- RESTful URL structure: `/api/flyers/`, `/api/creators/{id}/`
- Use HTTP status codes correctly: 200 (success), 404 (not found)
- Consistent response format: DRF's default JSON renderer
- AllowAny permissions for anonymous browsing (MVP requirement)

### ViewSet Patterns
- ModelViewSet: Full CRUD (but disable create/update/delete for read-only API)
- ReadOnlyModelViewSet: List and retrieve only (for creators)
- Custom actions: `@action` decorator for non-standard endpoints (creator's flyers)

### Testing with pytest-testmon
Per CLAUDE.md: Use `@pytest.mark.tdd_red` initially, verify tests pass, then change to `@pytest.mark.tdd_green`
- Integration tests should use Django's TestCase or APITestCase
- Create fixtures in setUp() or use factories for reusable test data
- Test both happy paths and error cases (404s, validation failures)

### DRF Testing Best Practices
- Use APIClient for endpoint testing
- Use `self.client.get()` instead of direct view calls
- Test response status codes, data structure, and content
- Verify pagination metadata in list responses

## References
- DRF Serializers: https://www.django-rest-framework.org/api-guide/serializers/
- DRF ViewSets: https://www.django-rest-framework.org/api-guide/viewsets/
- DRF Routers: https://www.django-rest-framework.org/api-guide/routers/
- DRF Pagination: https://www.django-rest-framework.org/api-guide/pagination/
- DRF Testing: https://www.django-rest-framework.org/api-guide/testing/
- Django select_related: https://docs.djangoproject.com/en/5.1/ref/models/querysets/#select-related
- Project ARCHITECTURE.md for tech stack and validation strategy
