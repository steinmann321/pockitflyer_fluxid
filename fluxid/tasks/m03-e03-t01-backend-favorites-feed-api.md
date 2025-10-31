---
id: m03-e03-t01
epic: m03-e03
title: Backend Favorites Feed API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Backend Favorites Feed API Endpoint

## Objective
Create Django REST API endpoint that returns flyers favorited by the authenticated user. The endpoint uses efficient JOIN queries with composite indexes for fast retrieval, supports pagination, and respects the same sorting logic as the main feed (recency + proximity).

## Acceptance Criteria
- [ ] API endpoint `GET /api/favorites/feed/` returns favorited flyers for authenticated user
- [ ] Query uses JOIN on Favorite model filtering by current user ID
- [ ] Results sorted by created_at descending + proximity to user location
- [ ] Pagination support (20 flyers per page, matches main feed)
- [ ] Query execution time <100ms for 100+ favorites (use database indexes)
- [ ] Returns 401 if user not authenticated
- [ ] Returns same flyer serialization as main feed (all fields, images, distances)
- [ ] Accepts optional location parameters (lat, lon) for distance calculation
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Endpoint returns only flyers favorited by authenticated user
- Endpoint returns 401 for anonymous users
- Results sorted correctly (recency + proximity)
- Pagination works correctly (page size, next/previous links)
- Distance calculation accurate when location provided
- Query performance <100ms with 100+ favorites (use database profiling)
- No duplicate flyers in results
- Unfavorited flyers excluded from results
- Empty result set handled correctly (user with no favorites)

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (add FavoritesFeedView)
- `pockitflyer_backend/flyers/urls.py` (add favorites/feed/ route)
- `pockitflyer_backend/flyers/tests/test_favorites_feed_api.py` (create API tests)

## Dependencies
- m03-e01-t01 (Favorite model with indexes)
- m03-e01-t02 (Favorite API endpoints)
- m01-e01-t04 (Main feed API structure)

## Notes
- Use Django's select_related() and prefetch_related() for efficient queries
- Query pattern: Flyer.objects.filter(favorites__user=request.user).select_related('creator')
- Composite index on (user_id, created_at) critical for performance
- Distance calculation: use haversine formula or PostGIS if available
- Consider caching favorite IDs per user to reduce query load
- API response format identical to main feed for frontend compatibility
