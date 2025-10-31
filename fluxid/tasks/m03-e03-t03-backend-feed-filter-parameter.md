---
id: m03-e03-t03
epic: m03-e03
title: Add Filter Parameter to Main Feed API
status: pending
priority: medium
tdd_phase: red
---

# Task: Add Filter Parameter to Main Feed API

## Objective
Extend main feed API endpoint to accept optional `filter` query parameter ('all', 'favorites', 'following') allowing single unified endpoint for all feed views. This provides cleaner REST design alternative to separate endpoints.

## Acceptance Criteria
- [ ] Main feed endpoint `GET /api/flyers/` accepts optional `?filter=` parameter
- [ ] `filter=all` or no filter parameter returns all nearby flyers (default behavior)
- [ ] `filter=favorites` returns favorited flyers (delegates to favorites logic)
- [ ] `filter=following` returns followed creators' flyers (delegates to following logic)
- [ ] Invalid filter values return 400 Bad Request with error message
- [ ] Filter parameter requires authentication (401 for favorites/following if anonymous)
- [ ] All filter modes respect same pagination and sorting logic
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Default behavior (no filter) returns all flyers
- filter=all explicitly returns all flyers
- filter=favorites returns only favorited flyers
- filter=following returns only followed creators' flyers
- Invalid filter values return 400 error
- Anonymous users get 401 for favorites/following filters
- Anonymous users can use filter=all or no filter
- Pagination works across all filter modes
- Sorting consistent across all filter modes

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (modify FlyerFeedView to handle filter parameter)
- `pockitflyer_backend/flyers/tests/test_feed_filter_parameter.py` (create filter parameter tests)

## Dependencies
- m03-e03-t01 (Favorites feed logic)
- m03-e03-t02 (Following feed logic)
- m01-e01-t04 (Main feed API)

## Notes
- This task provides alternative REST design to separate /favorites/feed/ and /following/feed/ endpoints
- Frontend can choose either approach: separate endpoints or unified endpoint with filter parameter
- Filter logic should delegate to existing favorites/following query methods for DRY principle
- Consider using Django's Q objects for conditional query building
- Filter validation: use Django serializer field with choices=['all', 'favorites', 'following']
