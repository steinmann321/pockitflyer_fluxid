---
id: m04-e01-t13
epic: m04-e01
title: Create Category List API Endpoint
status: pending
priority: medium
tdd_phase: red
---

# Task: Create Category List API Endpoint

## Objective
Build Django REST API endpoint to retrieve all active categories for frontend selection UI.

## Acceptance Criteria
- [ ] GET endpoint at `/api/v1/categories/`
- [ ] No authentication required (public endpoint)
- [ ] Returns all active categories ordered by display_order
- [ ] Response includes: id, name, slug for each category
- [ ] Caching: 1-hour cache header (categories rarely change)
- [ ] Pagination not needed (small, fixed dataset)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Successful category list retrieval
- Only active categories returned
- Correct ordering by display_order
- Response format validation
- Cache headers present
- Inactive categories excluded
- Empty state (no active categories)

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (CategoryListView)
- `pockitflyer_backend/flyers/serializers.py` (CategorySerializer)
- `pockitflyer_backend/flyers/tests/test_views.py` (category endpoint tests)

## Dependencies
- m04-e01-t02 (Category model)

## Notes
- Simple read-only endpoint
- Cache categories in frontend after first fetch
- Consider ETag for cache validation
- Response example:
  ```json
  {
    "categories": [
      {"id": 1, "name": "Events", "slug": "events"},
      {"id": 2, "name": "Nightlife", "slug": "nightlife"},
      ...
    ]
  }
  ```
