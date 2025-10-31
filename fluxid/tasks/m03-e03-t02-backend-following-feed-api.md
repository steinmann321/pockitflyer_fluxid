---
id: m03-e03-t02
epic: m03-e03
title: Backend Following Feed API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Backend Following Feed API Endpoint

## Objective
Create Django REST API endpoint that returns flyers from creators followed by the authenticated user. The endpoint uses efficient JOIN queries with composite indexes for fast retrieval, supports pagination, and respects the same sorting logic as the main feed (recency + proximity).

## Acceptance Criteria
- [ ] API endpoint `GET /api/following/feed/` returns flyers from followed creators
- [ ] Query uses JOIN on Follow model filtering by current user as follower
- [ ] Results sorted by created_at descending + proximity to user location
- [ ] Pagination support (20 flyers per page, matches main feed)
- [ ] Query execution time <100ms for 100+ follows (use database indexes)
- [ ] Returns 401 if user not authenticated
- [ ] Returns same flyer serialization as main feed (all fields, images, distances)
- [ ] Accepts optional location parameters (lat, lon) for distance calculation
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Endpoint returns only flyers from creators followed by authenticated user
- Endpoint returns 401 for anonymous users
- Results sorted correctly (recency + proximity)
- Pagination works correctly (page size, next/previous links)
- Distance calculation accurate when location provided
- Query performance <100ms with 100+ follows (use database profiling)
- No duplicate flyers in results
- Unfollowed creators' flyers excluded from results
- Empty result set handled correctly (user following no creators or creators with no flyers)
- Multiple flyers from same followed creator all appear in feed

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (add FollowingFeedView)
- `pockitflyer_backend/flyers/urls.py` (add following/feed/ route)
- `pockitflyer_backend/flyers/tests/test_following_feed_api.py` (create API tests)

## Dependencies
- m03-e02-t01 (Follow model with indexes)
- m03-e02-t02 (Follow API endpoints)
- m01-e01-t04 (Main feed API structure)

## Notes
- Use Django's select_related() and prefetch_related() for efficient queries
- Query pattern: Flyer.objects.filter(creator__followers__follower=request.user).select_related('creator')
- Composite index on (follower_id, created_at) critical for performance
- Consider denormalizing follow relationships for faster queries if needed
- API response format identical to main feed for frontend compatibility
- Handle edge case: user follows creator who has no flyers (empty result acceptable)
