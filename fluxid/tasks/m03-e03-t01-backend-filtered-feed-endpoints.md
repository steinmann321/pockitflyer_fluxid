---
id: m03-e03-t01
title: Backend Filtered Feed Endpoints with Relationship Queries
epic: m03-e03
milestone: m03
status: pending
---

# Task: Backend Filtered Feed Endpoints with Relationship Queries

## Context
Part of Relationship Filtering (m03-e03) in Social engagement features (m03).

Creates backend API endpoints for filtering the flyer feed based on user relationships (favorites and following). These endpoints use efficient JOIN queries to return only flyers that match the user's favorites or flyers from creators the user follows. Supports combination with existing category tag filters.

## Implementation Guide for LLM Agent

### Objective
Implement `/api/feed/?relationship=favorites` and `/api/feed/?relationship=following` endpoints with optimized database queries, relationship JOIN logic, and combination with category tag filters.

### Steps
1. **Create or modify feed view to support relationship filtering**
   - File: `pockitflyer_backend/flyers/views.py` (or create if doesn't exist)
   - Add `relationship` query parameter handling to feed endpoint
   - Parse `relationship` parameter values: `favorites`, `following`
   - Validate that relationship filters require authentication
   - Return 401 if anonymous user attempts relationship filter

2. **Implement favorites feed query logic**
   - In the feed view handler, when `relationship=favorites`:
   - Use Django ORM JOIN: `Flyer.objects.filter(favorites__user=request.user).distinct()`
   - Ensure query uses the `favorites` relationship table (from m03-e01)
   - Add `.select_related()` or `.prefetch_related()` to prevent N+1 queries
   - Maintain existing feed ordering (e.g., by creation date descending)

3. **Implement following feed query logic**
   - In the feed view handler, when `relationship=following`:
   - Use Django ORM JOIN: `Flyer.objects.filter(creator__followers__follower=request.user).distinct()`
   - Ensure query uses the `following` relationship table (from m03-e02)
   - Add `.select_related('creator')` to optimize creator data fetching
   - Maintain existing feed ordering

4. **Implement filter combination logic**
   - When both `relationship` and `tags` query parameters are present:
   - Apply relationship filter first (JOIN with favorites or following)
   - Then apply category tag filter (AND logic): `.filter(tags__in=tag_list)`
   - Use `.distinct()` to avoid duplicate flyers from multiple tags
   - Example: `/api/feed/?relationship=favorites&tags=events,food`
   - Verify AND logic: only flyers that are favorited AND (tagged events OR tagged food)

5. **Add database indexing for relationship queries**
   - File: Create migration in `pockitflyer_backend/flyers/migrations/`
   - Add index on `favorites.user_id` (if not already indexed from m03-e01)
   - Add index on `favorites.flyer_id` (if not already indexed)
   - Add index on `following.follower_id` (if not already indexed from m03-e02)
   - Add index on `flyers.creator_id` (if not already indexed)
   - Run migration to apply indexes

6. **Create comprehensive test suite**
   - File: `pockitflyer_backend/tests/test_feed_relationship_filtering.py` (create new)
   - Test authenticated user with `relationship=favorites` returns only favorited flyers
   - Test authenticated user with `relationship=following` returns only flyers from followed creators
   - Test anonymous user with relationship filter returns 401
   - Test `relationship=favorites&tags=events` returns only favorited event flyers (AND logic)
   - Test relationship filter with zero relationships returns empty array
   - Test invalid relationship value returns 400
   - Test query performance: verify no N+1 queries using Django debug toolbar or query counting
   - Test with 1000+ relationships to ensure query remains under 400ms

7. **Update API documentation**
   - File: `pockitflyer_backend/README.md` or API docs file
   - Document new query parameters:
     - `?relationship=favorites` - Filter to favorited flyers (requires auth)
     - `?relationship=following` - Filter to flyers from followed creators (requires auth)
   - Document combination with tags: `?relationship=favorites&tags=events`
   - Document error responses: 401 for anonymous, 400 for invalid value

### Acceptance Criteria
- [ ] GET `/api/feed/?relationship=favorites` returns only flyers user has favorited [Test: create 5 flyers, favorite 2, verify response contains only 2]
- [ ] GET `/api/feed/?relationship=following` returns only flyers from followed creators [Test: follow 2 creators with 3 flyers each, verify response contains 6 flyers]
- [ ] Anonymous users receive 401 when using relationship filters [Test: unauthenticated request to both endpoints]
- [ ] Combination filter works: `/api/feed/?relationship=favorites&tags=events` [Test: favorite 5 flyers (3 events, 2 food), verify response contains only 3 event flyers]
- [ ] Empty relationships return empty array, not error [Test: user with zero favorites, zero following]
- [ ] Invalid relationship value returns 400 [Test: `?relationship=invalid`]
- [ ] Queries are optimized: no N+1 queries [Test: Django query counting shows constant queries regardless of result count]
- [ ] Query performance under 400ms [Test: 1000+ relationships, measure p95 response time]
- [ ] Database indexes exist on relationship foreign keys [Test: inspect migration files and database schema]
- [ ] Tests pass with >85% coverage for new code [Test: run pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/views.py` - MODIFY: add relationship filter handling to feed endpoint
- `pockitflyer_backend/flyers/migrations/XXXX_add_relationship_indexes.py` - NEW: database indexes for query optimization
- `pockitflyer_backend/tests/test_feed_relationship_filtering.py` - NEW: comprehensive test suite for relationship filtering
- `pockitflyer_backend/README.md` - MODIFY: document new API query parameters

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit test**: Relationship filter query logic in isolation, test query building, parameter validation
- **Integration test**: Full endpoint tests with test database, verify relationship JOINs work correctly, test filter combinations, test authentication enforcement, verify query performance with realistic data volumes

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Django REST Framework patterns)
- [ ] No console errors or warnings
- [ ] Database indexes created and applied
- [ ] API documentation updated
- [ ] Changes committed with reference to task ID: `m03-e03-t01`
- [ ] Ready for frontend integration (m03-e03-t02)

## Dependencies
- **Requires**: M03-E01 (Flyer favorites) - favorites relationship model must exist
- **Requires**: M03-E02 (Creator following) - following relationship model must exist
- **Requires**: M01 (Browse flyers) - base feed endpoint must exist
- **Requires**: M02 (User authentication) - JWT auth middleware must be in place
- **Blocks**: m03-e03-t02 (Frontend filter chips) - frontend needs these endpoints

## Technical Notes
- **Django ORM patterns**: Use `.select_related()` for foreign keys, `.prefetch_related()` for many-to-many and reverse foreign keys
- **Query optimization**: Use `.distinct()` to avoid duplicates from JOIN operations
- **Authentication**: Use Django's `@permission_classes([IsAuthenticated])` decorator or check `request.user.is_authenticated`
- **Filter combination**: Relationship filters are exclusive (favorites OR following, not both), but combine with category tags using AND logic
- **Error handling**: Return 400 for invalid parameters, 401 for auth required, 200 with empty array for valid but result-less queries
- **Performance targets**: Query response time < 400ms (p95), filter change to first content < 500ms total (including network)

## References
- Django QuerySet API: https://docs.djangoproject.com/en/stable/ref/models/querysets/
- Django REST Framework authentication: https://www.django-rest-framework.org/api-guide/authentication/
- Epic technical considerations: `/Users/jakob.steinmann/vscodeprojects/pockitflyer_fluxid/fluxid/epics/m03-e03-relationship-filtering.md` (lines 62-84)
