---
id: m03-e01-t02
epic: m03-e01
title: Implement Favorite API Endpoints
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Favorite API Endpoints

## Objective
Create Django REST API endpoints for creating and deleting favorites. Endpoints require authentication, handle duplicate favorites gracefully, and return appropriate responses for success and error cases.

## Acceptance Criteria
- [ ] POST /api/favorites/ endpoint creates favorite (requires flyer_id in request body)
- [ ] DELETE /api/favorites/{flyer_id}/ endpoint deletes favorite
- [ ] Both endpoints require authentication (401 if anonymous)
- [ ] POST handles duplicate favorite gracefully (returns 200/201, not error)
- [ ] DELETE handles non-existent favorite gracefully (returns 204, not error)
- [ ] POST returns 201 with favorite data on creation
- [ ] DELETE returns 204 on successful deletion
- [ ] Validation errors return 400 with error details
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- POST endpoint creates favorite relationship (authenticated user)
- POST endpoint returns 401 for anonymous user
- POST endpoint handles duplicate favorite (idempotent)
- POST endpoint returns 400 for invalid flyer_id
- POST endpoint returns 404 for non-existent flyer
- DELETE endpoint removes favorite relationship
- DELETE endpoint returns 401 for anonymous user
- DELETE endpoint handles non-existent favorite (idempotent)
- DELETE endpoint validates flyer_id parameter
- Response serialization includes correct data (user_id, flyer_id, created_at)

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (add FavoriteViewSet)
- `pockitflyer_backend/flyers/serializers.py` (add FavoriteSerializer)
- `pockitflyer_backend/flyers/urls.py` (register favorite routes)
- `pockitflyer_backend/flyers/tests/test_views.py` (add favorite API tests)

## Dependencies
- m03-e01-t01 (Favorite model must exist)
- m02-e01-t02 (JWT authentication must be implemented)

## Notes
- Use DRF ViewSet with create and destroy actions
- Idempotent behavior: POST duplicate favorite succeeds, DELETE non-existent favorite succeeds
- DELETE uses flyer_id in URL, not favorite.id (simpler client logic)
- Lookup favorite by (user=request.user, flyer_id=flyer_id) for DELETE
- Consider using get_or_create for POST to ensure idempotency
