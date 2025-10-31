---
id: m01-e02-t01
epic: m01-e02
title: Extend Flyer API with Filter and Search Parameters
status: pending
priority: high
tdd_phase: red
---

# Task: Extend Flyer API with Filter and Search Parameters

## Objective
Extend the flyer feed API endpoint to accept filter parameters (categories, proximity) and search query, returning filtered results with efficient database queries.

## Acceptance Criteria
- [ ] API accepts `categories` query parameter (multi-select, comma-separated: events,nightlife,service)
- [ ] API accepts `near_me` boolean parameter with `latitude`, `longitude`, `radius` (default 5km)
- [ ] API accepts `search` query parameter for text search (searches title and description)
- [ ] Category filter uses OR logic: returns flyers matching ANY selected category
- [ ] Near Me filter uses AND logic: combines with category filters
- [ ] Search uses AND logic: combines with all active filters
- [ ] Search is case-insensitive and matches partial words
- [ ] Returns appropriate empty results when no flyers match filters
- [ ] API response time < 500ms for filtered queries (1000+ flyers in DB)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Single category filter (events only, nightlife only, service only)
- Multiple category filters (events OR nightlife, all three categories)
- No category selected (returns all flyers)
- Near Me filter alone (various distances, boundary cases)
- Category + Near Me combination
- Search alone (title matches, description matches, case insensitivity)
- Search + category combination
- Search + Near Me combination
- All filters combined
- Empty result scenarios (no matches, no nearby flyers)
- Special characters in search query
- Performance test with 1000+ flyers

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (extend FlyerListView)
- `pockitflyer_backend/flyers/tests/test_views.py` (add filter/search tests)
- `pockitflyer_backend/flyers/serializers.py` (if needed for validation)

## Dependencies
- Epic m01-e01 tasks (Flyer model and basic API must exist)
- Task m01-e02-t02 (database indexes for performance)

## Notes
- Use Django ORM Q objects for OR logic in category filters
- Use geodesic distance calculation for proximity (already implemented in geocoding service)
- Use `icontains` for search queries (case-insensitive LIKE)
- Debouncing is handled on frontend, backend processes all requests
- Proximity threshold configurable via settings, default 5km
- Return distance in API response for Near Me results (useful for sorting)
