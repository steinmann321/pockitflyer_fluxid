---
id: m03-e02-t01
title: Backend Following Relationship Model and Endpoints
epic: m03-e02
milestone: m03
status: pending
---

# Task: Backend Following Relationship Model and Endpoints

## Context
Part of Creator Following (m03-e02) in Milestone 3.

Implements the backend foundation for creator following functionality: a User-User relationship model with database constraints to prevent self-follows and duplicates, plus API endpoints for follow/unfollow operations. This establishes the data persistence layer and business logic for authenticated users following creators.

## Implementation Guide for LLM Agent

### Objective
Create Follow model with User-User relationship, database constraints (unique pair, no self-follows), indexes for efficient queries, and authenticated API endpoints for follow/unfollow operations.

### Steps
1. Create Follow model in Django
   - Create new file `pockitflyer_backend/users/models.py` (or add to existing if it exists)
   - Define `Follow` model with:
     - `follower` ForeignKey to Django User model (on_delete=CASCADE, related_name='following')
     - `followee` ForeignKey to Django User model (on_delete=CASCADE, related_name='followers')
     - `created_at` DateTimeField (auto_now_add=True)
   - Add unique constraint on (follower, followee) pair via Meta class: `unique_together = [['follower', 'followee']]`
   - Add check constraint to prevent self-follows: `CheckConstraint(check=~Q(follower=F('followee')), name='prevent_self_follow')`
   - Add database indexes:
     - Index on `follower` field (for "get all users I'm following" queries)
     - Index on `followee` field (for "get all my followers" queries)
   - Define `__str__` method: return f"{follower.email} follows {followee.email}"

2. Create and run database migration
   - Run: `python manage.py makemigrations`
   - Run: `python manage.py migrate`
   - Verify migration file includes unique constraint, check constraint, and indexes

3. Create serializer for Follow operations
   - Create new file `pockitflyer_backend/users/serializers.py` (or add to existing)
   - Define `FollowSerializer`:
     - Fields: `id`, `followee_id`, `followee_email`, `followee_name`, `created_at`
     - Read-only fields: `id`, `followee_email`, `followee_name`, `created_at`
     - Include followee details for frontend display
   - Define `FollowCreateSerializer`:
     - Field: `followee_id` (write-only, required)
     - Validate `followee_id` exists in database
     - Validate `followee_id != follower_id` (prevent self-follow at serializer level too)
     - Handle duplicate follow attempts gracefully (return existing or error message)

4. Implement follow/unfollow API endpoints
   - Create new file `pockitflyer_backend/users/views.py` (or add to existing)
   - **POST /api/users/{user_id}/follow/** - Follow user:
     - Require authentication (use `@permission_classes([IsAuthenticated])`)
     - Extract user_id (followee) from URL
     - Check if followee exists (return 404 if not)
     - Check if followee == current user (return 400 "Cannot follow yourself")
     - Check if follow already exists for (follower, followee)
     - If exists: return 200 with existing follow (idempotent)
     - If not exists: create follow, return 201
     - Handle errors: user not found (404), self-follow (400), database errors (500)
   - **DELETE /api/users/{user_id}/follow/** - Unfollow user:
     - Require authentication
     - Extract user_id (followee) from URL
     - Find follow for (current_user, followee)
     - If exists: delete, return 204 No Content
     - If not exists: return 404 with message "Not following this user"
   - **GET /api/users/me/following/** - List users I'm following:
     - Require authentication
     - Query all follows where follower=current_user
     - Return list of follows with followee details
     - Use select_related to avoid N+1 queries
     - Order by created_at descending (most recent first)
   - **GET /api/users/me/followers/** - List my followers (optional for future):
     - Require authentication
     - Query all follows where followee=current_user
     - Return list of follows with follower details
     - Use select_related to avoid N+1 queries
     - Order by created_at descending

5. Register URL routes
   - Create/modify `pockitflyer_backend/users/urls.py`
   - Add routes:
     - `POST users/<int:user_id>/follow/` → follow view
     - `DELETE users/<int:user_id>/follow/` → unfollow view
     - `GET users/me/following/` → list following view
     - `GET users/me/followers/` → list followers view (optional)
   - Include in main `pockitflyer_backend/pokitflyer_api/urls.py` under `/api/` prefix

6. Create comprehensive test suite
   - Create new file `pockitflyer_backend/tests/test_follows.py`
   - **Model tests**:
     - Test unique constraint prevents duplicate (follower, followee) pairs
     - Test check constraint prevents self-follows (follower == followee)
     - Test cascade deletion when follower deleted
     - Test cascade deletion when followee deleted
     - Test string representation
   - **Endpoint tests** (use Django REST Framework test client):
     - **POST /follow tests**:
       - Authenticated user can follow another user (returns 201)
       - Following same user twice is idempotent (returns 200)
       - Cannot follow yourself (returns 400 "Cannot follow yourself")
       - Anonymous user gets 401 Unauthorized
       - Invalid user_id returns 404
       - Multiple users can follow same creator
       - Concurrent follow requests handled correctly
     - **DELETE /follow tests**:
       - Authenticated user can unfollow (returns 204)
       - Unfollowing non-followed user returns 404
       - Anonymous user gets 401 Unauthorized
       - Cannot unfollow another user's follow relationship
     - **GET /following tests**:
       - Returns list of users I'm following with details
       - Empty list for user following no one
       - Anonymous user gets 401 Unauthorized
       - Follows ordered by created_at descending
       - No N+1 query issues (verify query count)
     - **GET /followers tests** (optional):
       - Returns list of my followers with details
       - Empty list for user with no followers
       - Anonymous user gets 401 Unauthorized
   - **Performance tests**:
     - Verify database indexes used in queries
     - Concurrent follow requests handled correctly
     - Query performance acceptable with 1000+ follows per user

### Acceptance Criteria
- [ ] Follow model created with follower/followee foreign keys and created_at field [Test: model fields exist and are correct types]
- [ ] Unique constraint prevents duplicate (follower, followee) pairs [Test: attempt to create duplicate raises IntegrityError]
- [ ] Check constraint prevents self-follows [Test: attempt follower=followee raises IntegrityError]
- [ ] Database indexes on follower_id and followee_id [Test: check migration file includes indexes]
- [ ] POST /api/users/{id}/follow/ creates follow for authenticated user [Test: valid request returns 201 with follow data]
- [ ] Following same user twice is idempotent [Test: second POST returns 200, no duplicate created]
- [ ] Cannot follow yourself [Test: POST with own user_id returns 400]
- [ ] DELETE /api/users/{id}/follow/ removes follow [Test: returns 204, follow deleted from database]
- [ ] GET /api/users/me/following/ lists users I'm following [Test: returns follows with followee details, newest first]
- [ ] Anonymous users get 401 for all endpoints [Test: requests without auth header]
- [ ] Invalid user_id returns 404 [Test: POST follow for non-existent user]
- [ ] No N+1 query issues in list following [Test: verify query count doesn't increase with number of follows]
- [ ] All tests pass with >90% coverage [Run: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/users/models.py` - NEW/MODIFY: Follow model with constraints and indexes
- `pockitflyer_backend/users/serializers.py` - NEW/MODIFY: FollowSerializer and FollowCreateSerializer
- `pockitflyer_backend/users/views.py` - NEW/MODIFY: follow/unfollow/list endpoints
- `pockitflyer_backend/users/urls.py` - NEW/MODIFY: URL routing for follow endpoints
- `pockitflyer_backend/pokitflyer_api/urls.py` - MODIFY: include users URLs if not already
- `pockitflyer_backend/tests/test_follows.py` - NEW: comprehensive test suite
- `pockitflyer_backend/users/migrations/XXXX_create_follow.py` - GENERATED: database migration

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - Follow model constraints (unique, check, cascading)
  - Serializer validation logic (self-follow prevention)
  - View business logic with mocked database
- **Integration tests**:
  - Full API endpoint tests with test database
  - Authentication flow (token required)
  - Database query performance (N+1 prevention)
  - Concurrent request handling
  - Error scenarios (404, 401, 400, 500)
  - Self-follow prevention at database and application level

### Definition of Done
- [ ] Code written and passes all tests (>90% coverage)
- [ ] Migration applied successfully to database
- [ ] API endpoints tested with authentication
- [ ] Self-follow prevention verified at database and application level
- [ ] No N+1 query issues verified
- [ ] Code follows Django REST Framework conventions
- [ ] No console errors or warnings
- [ ] Changes committed with reference to task ID (m03-e02-t01)
- [ ] Ready for frontend integration (m03-e02-t02)

## Dependencies
- Requires: M02 (User authentication) - JWT auth system must exist
- Requires: M01 (Browse flyers) - Flyer cards must display creator information
- Blocks: m03-e02-t02 (Frontend follow button)

## Technical Notes
**Authentication Requirements**:
- All endpoints require JWT authentication (from M02)
- Use Django REST Framework's `IsAuthenticated` permission class
- Extract current user from `request.user`

**Database Constraints**:
- CRITICAL: Use `unique_together = [['follower', 'followee']]` in model Meta to prevent duplicates at database level
- CRITICAL: Use `CheckConstraint` to prevent self-follows at database level
- This is more reliable than application-level checks

**Self-Follow Prevention**:
- Implement at TWO levels:
  1. Database constraint: `CheckConstraint(check=~Q(follower=F('followee')), name='prevent_self_follow')`
  2. Serializer validation: Check `followee_id != follower_id` before creating
  3. View validation: Return 400 "Cannot follow yourself" in view
- Test all three levels to ensure robustness

**Performance Considerations**:
- Index on `follower_id`: Optimizes "get all users I'm following" queries
- Index on `followee_id`: Optimizes "get all my followers" queries
- Use `select_related('followee')` or `select_related('follower')` when querying to avoid N+1 queries
- Performance target: API response time < 300ms (p95)

**Idempotency**:
- POST /follow should be idempotent - following twice returns existing follow (200 OK)
- This prevents errors in UI when user taps multiple times

**Error Handling**:
- Return appropriate HTTP status codes (401, 404, 400, 500)
- Provide clear error messages in response body:
  - 400: "Cannot follow yourself"
  - 404: "User not found" or "Not following this user"
- Log errors for debugging (but don't expose internal details to client)

**Django Conventions**:
- Use Django's built-in User model (django.contrib.auth.models.User)
- Follow Django REST Framework viewset patterns if preferred over function views
- Use Django's timezone-aware datetime fields (auto_now_add=True)
- Use `related_name` for clarity: `following` (users I follow), `followers` (users who follow me)

**Differences from Favorites (m03-e01-t01)**:
- User-User relationship instead of User-Flyer
- Self-follow prevention required (extra constraint)
- Bidirectional indexing (follower AND followee)
- May need both "following" and "followers" endpoints

## References
- Django REST Framework Authentication: https://www.django-rest-framework.org/api-guide/authentication/
- Django Model Constraints: https://docs.djangoproject.com/en/stable/ref/models/constraints/
- Django CheckConstraint: https://docs.djangoproject.com/en/stable/ref/models/constraints/#checkconstraint
- Django Database Indexing: https://docs.djangoproject.com/en/stable/ref/models/indexes/
