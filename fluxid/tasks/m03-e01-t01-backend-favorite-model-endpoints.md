---
id: m03-e01-t01
title: Backend Favorite Relationship Model and Endpoints
epic: m03-e01
milestone: m03
status: pending
---

# Task: Backend Favorite Relationship Model and Endpoints

## Context
Part of Flyer Favorites (m03-e01) in Milestone 3.

Implements the backend foundation for favorite functionality: a User-Flyer relationship model with database constraints and indexing, plus API endpoints for favorite/unfavorite operations. This establishes the data persistence layer and business logic for authenticated users saving flyers.

## Implementation Guide for LLM Agent

### Objective
Create Favorite model with User-Flyer relationship, database constraints/indexes, and authenticated API endpoints for favorite/unfavorite operations.

### Steps
1. Create Favorite model in Django
   - Create new file `pockitflyer_backend/flyers/models.py` (or add to existing if it exists)
   - Define `Favorite` model with:
     - `user` ForeignKey to Django User model (on_delete=CASCADE)
     - `flyer` ForeignKey to Flyer model (on_delete=CASCADE)
     - `created_at` DateTimeField (auto_now_add=True)
   - Add unique constraint on (user, flyer) pair via Meta class: `unique_together = [['user', 'flyer']]`
   - Add database indexes:
     - Index on `user` field (for "get all favorites for user" queries)
     - Index on `flyer` field (for "get favorite count for flyer" queries)
   - Define `__str__` method: return f"{user.email} favorited {flyer.title}"

2. Create and run database migration
   - Run: `python manage.py makemigrations`
   - Run: `python manage.py migrate`
   - Verify migration file includes unique constraint and indexes

3. Create serializer for Favorite operations
   - Create new file `pockitflyer_backend/flyers/serializers.py` (or add to existing)
   - Define `FavoriteSerializer`:
     - Fields: `id`, `flyer_id`, `created_at`
     - Read-only fields: `id`, `created_at`
   - Define `FavoriteCreateSerializer`:
     - Field: `flyer_id` (write-only, required)
     - Validate `flyer_id` exists in database
     - Handle duplicate favorite attempts gracefully (return existing or error message)

4. Implement favorite/unfavorite API endpoints
   - Create new file `pockitflyer_backend/flyers/views.py` (or add to existing)
   - **POST /api/flyers/{flyer_id}/favorite/** - Add favorite:
     - Require authentication (use `@permission_classes([IsAuthenticated])`)
     - Extract flyer_id from URL
     - Check if favorite already exists for (user, flyer)
     - If exists: return 200 with existing favorite (idempotent)
     - If not exists: create favorite, return 201
     - Handle errors: flyer not found (404), database errors (500)
   - **DELETE /api/flyers/{flyer_id}/favorite/** - Remove favorite:
     - Require authentication
     - Extract flyer_id from URL
     - Find favorite for (user, flyer)
     - If exists: delete, return 204 No Content
     - If not exists: return 404 with message "Favorite not found"
   - **GET /api/users/me/favorites/** - List user's favorites:
     - Require authentication
     - Query all favorites for current user
     - Return list of favorites with flyer details
     - Use select_related/prefetch_related to avoid N+1 queries
     - Order by created_at descending (most recent first)

5. Register URL routes
   - Create/modify `pockitflyer_backend/flyers/urls.py`
   - Add routes:
     - `POST flyers/<int:flyer_id>/favorite/` → favorite view
     - `DELETE flyers/<int:flyer_id>/favorite/` → unfavorite view
     - `GET users/me/favorites/` → list favorites view
   - Include in main `pockitflyer_backend/pokitflyer_api/urls.py` under `/api/` prefix

6. Create comprehensive test suite
   - Create new file `pockitflyer_backend/tests/test_favorites.py`
   - **Model tests**:
     - Test unique constraint prevents duplicate (user, flyer) pairs
     - Test cascade deletion when user deleted
     - Test cascade deletion when flyer deleted
     - Test string representation
   - **Endpoint tests** (use Django REST Framework test client):
     - **POST /favorite tests**:
       - Authenticated user can favorite flyer (returns 201)
       - Favoriting same flyer twice is idempotent (returns 200)
       - Anonymous user gets 401 Unauthorized
       - Invalid flyer_id returns 404
       - Multiple users can favorite same flyer
     - **DELETE /favorite tests**:
       - Authenticated user can unfavorite (returns 204)
       - Unfavoriting non-existent favorite returns 404
       - Anonymous user gets 401 Unauthorized
       - Cannot unfavorite another user's favorite
     - **GET /favorites tests**:
       - Returns list of user's favorites with flyer details
       - Empty list for user with no favorites
       - Anonymous user gets 401 Unauthorized
       - Favorites ordered by created_at descending
       - No N+1 query issues (verify query count)
   - **Performance tests**:
     - Verify database indexes used in queries (use Django debug toolbar or explain)
     - Concurrent favorite requests handled correctly
     - Query performance acceptable with 1000+ favorites per user

### Acceptance Criteria
- [ ] Favorite model created with user/flyer foreign keys and created_at field [Test: model fields exist and are correct types]
- [ ] Unique constraint prevents duplicate (user, flyer) pairs [Test: attempt to create duplicate raises IntegrityError]
- [ ] Database indexes on user_id and flyer_id [Test: check migration file includes indexes]
- [ ] POST /api/flyers/{id}/favorite/ creates favorite for authenticated user [Test: valid request returns 201 with favorite data]
- [ ] Favoriting same flyer twice is idempotent [Test: second POST returns 200, no duplicate created]
- [ ] DELETE /api/flyers/{id}/favorite/ removes favorite [Test: returns 204, favorite deleted from database]
- [ ] GET /api/users/me/favorites/ lists user's favorites [Test: returns favorites with flyer details, newest first]
- [ ] Anonymous users get 401 for all endpoints [Test: requests without auth header]
- [ ] Invalid flyer_id returns 404 [Test: POST favorite for non-existent flyer]
- [ ] No N+1 query issues in list favorites [Test: verify query count doesn't increase with number of favorites]
- [ ] All tests pass with >90% coverage [Run: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/models.py` - NEW/MODIFY: Favorite model with constraints and indexes
- `pockitflyer_backend/flyers/serializers.py` - NEW/MODIFY: FavoriteSerializer and FavoriteCreateSerializer
- `pockitflyer_backend/flyers/views.py` - NEW/MODIFY: favorite/unfavorite/list endpoints
- `pockitflyer_backend/flyers/urls.py` - NEW/MODIFY: URL routing for favorite endpoints
- `pockitflyer_backend/pokitflyer_api/urls.py` - MODIFY: include flyers URLs if not already
- `pockitflyer_backend/tests/test_favorites.py` - NEW: comprehensive test suite
- `pockitflyer_backend/flyers/migrations/XXXX_create_favorite.py` - GENERATED: database migration

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - Favorite model constraints (unique, cascading)
  - Serializer validation logic
  - View business logic with mocked database
- **Integration tests**:
  - Full API endpoint tests with test database
  - Authentication flow (token required)
  - Database query performance (N+1 prevention)
  - Concurrent request handling
  - Error scenarios (404, 401, 500)

### Definition of Done
- [ ] Code written and passes all tests (>90% coverage)
- [ ] Migration applied successfully to database
- [ ] API endpoints tested with authentication
- [ ] No N+1 query issues verified
- [ ] Code follows Django REST Framework conventions
- [ ] No console errors or warnings
- [ ] Changes committed with reference to task ID (m03-e01-t01)
- [ ] Ready for frontend integration (m03-e01-t02)

## Dependencies
- Requires: M02 (User authentication) - JWT auth system must exist
- Requires: M01 (Browse flyers) - Flyer model must exist
- Blocks: m03-e01-t02 (Frontend favorite button)

## Technical Notes
**Authentication Requirements**:
- All endpoints require JWT authentication (from M02)
- Use Django REST Framework's `IsAuthenticated` permission class
- Extract current user from `request.user`

**Database Constraints**:
- CRITICAL: Use `unique_together = [['user', 'flyer']]` in model Meta to prevent duplicates at database level
- This is more reliable than application-level checks

**Performance Considerations**:
- Index on `user_id`: Optimizes "get all favorites for user" queries
- Index on `flyer_id`: Optimizes "get favorite count for flyer" (if needed later)
- Use `select_related('flyer')` when querying favorites to avoid N+1 queries
- Performance target: API response time < 300ms (p95)

**Idempotency**:
- POST /favorite should be idempotent - favoriting twice returns existing favorite (200 OK)
- This prevents errors in UI when user taps multiple times

**Error Handling**:
- Return appropriate HTTP status codes (401, 404, 500)
- Provide clear error messages in response body
- Log errors for debugging (but don't expose internal details to client)

**Django Conventions**:
- Use Django's built-in User model (django.contrib.auth.models.User)
- Follow Django REST Framework viewset patterns if preferred over function views
- Use Django's timezone-aware datetime fields (auto_now_add=True)

## References
- Django REST Framework Authentication: https://www.django-rest-framework.org/api-guide/authentication/
- Django Model Constraints: https://docs.djangoproject.com/en/stable/ref/models/constraints/
- Django Database Indexing: https://docs.djangoproject.com/en/stable/ref/models/indexes/
