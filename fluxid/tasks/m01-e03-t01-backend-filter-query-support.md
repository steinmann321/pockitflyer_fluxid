---
id: m01-e03-t01
title: Backend Filter Query Support
epic: m01-e03
milestone: m01
status: pending
---

# Task: Backend Filter Query Support

## Context
Part of Category and Proximity Filtering (m01-e03) in Browse and Discover Local Flyers (m01).

Extends the existing Backend Flyer API (m01-e01) to accept category and proximity filter query parameters, enabling the frontend to request filtered flyer feeds based on user selections.

## Implementation Guide for LLM Agent

### Objective
Add query parameter support to the flyer list API endpoint for category filtering (multi-select OR logic) and proximity filtering (distance-based), integrating with existing ranking algorithm.

### Steps
1. Update API endpoint to accept filter query parameters
   - Modify `GET /api/flyers/` endpoint handler
   - Add query parameters: `categories` (comma-separated: "events,nightlife,service"), `near_me` (boolean), `max_distance` (km, default 10)
   - Path: `pockitflyer_backend/flyers/views.py` or similar API view file
   - Validate query parameters (categories must be valid choices, max_distance must be positive number)

2. Implement category filter logic with multi-select OR
   - In flyer queryset filtering logic
   - If `categories` parameter provided, filter flyers WHERE category IN (selected_categories)
   - Multi-select OR logic: flyer matches if it has ANY of the selected categories
   - Example: `categories=events,nightlife` returns flyers tagged as Events OR Nightlife
   - Handle edge cases: empty categories (return all), invalid category (return 400 error)

3. Implement proximity filter logic
   - If `near_me=true`, filter flyers by distance from user location
   - User location obtained from query parameters: `lat`, `lng` (required when near_me=true)
   - Calculate distance using existing distance calculation utility (from m01-e01-t05)
   - Filter WHERE distance <= max_distance (default 10km)
   - Return 400 error if near_me=true but lat/lng missing

4. Combine filters with existing ranking
   - Apply category AND proximity filters BEFORE ranking
   - Filtered queryset → ranking algorithm → paginated response
   - Ensure filters don't break existing pagination
   - Maintain performance: use database-level filtering (WHERE clauses), not Python-level filtering

5. Update API serializer response (if needed)
   - No changes expected to response format
   - Ensure distance field is included in response (should already exist from m01-e01)
   - Verify all existing fields remain intact

6. Create comprehensive test suite
   - **Unit tests** for filter logic (8-12 tests):
     - Single category filter
     - Multiple category filter (OR logic)
     - All categories selected
     - No categories selected (returns all)
     - Invalid category (returns 400)
     - Proximity filter with valid lat/lng
     - Proximity filter without lat/lng (returns 400)
     - Combined category + proximity filters
     - Edge case: max_distance=0 (returns only exact location matches)
     - Edge case: no results after filtering
   - **Integration tests** with test database (4-6 tests):
     - Full API request with category filter
     - Full API request with proximity filter
     - Full API request with both filters
     - Verify pagination works with filters
     - Verify ranking algorithm applies after filtering
     - Performance test: filter on 100+ flyers

7. Update API documentation
   - Add query parameters to API schema (drf-spectacular)
   - Document parameter formats and valid values
   - Provide example requests in documentation

### Acceptance Criteria
- [ ] API accepts `categories` query parameter and filters flyers with OR logic [Test: GET /api/flyers/?categories=events,nightlife returns flyers tagged Events OR Nightlife]
- [ ] API accepts `near_me` and `max_distance` query parameters [Test: GET /api/flyers/?near_me=true&lat=47.3769&lng=8.5417&max_distance=5 returns flyers within 5km]
- [ ] Combined filters work correctly (category AND proximity) [Test: both filters active returns correct subset]
- [ ] Invalid query parameters return 400 with error details [Test: invalid category, missing lat/lng when near_me=true]
- [ ] Empty category filter returns all flyers [Test: categories= or no categories parameter]
- [ ] Filters integrate with existing ranking algorithm [Test: filtered results are ranked by recency/proximity/relevance]
- [ ] Pagination works with filters [Test: paginated requests with filters]
- [ ] All tests pass with >85% coverage on new filter code
- [ ] API documentation updated with new parameters

### Files to Create/Modify
- `pockitflyer_backend/flyers/views.py` - MODIFY: add filter query parameter handling to flyer list view
- `pockitflyer_backend/flyers/filters.py` - NEW: create filter class for category and proximity filtering (if using django-filter)
- `pockitflyer_backend/flyers/tests/test_filters.py` - NEW: unit tests for filter logic
- `pockitflyer_backend/flyers/tests/test_api_filters.py` - NEW: integration tests for API with filters
- API schema files (if using drf-spectacular) - MODIFY: update documentation

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: Filter logic functions (category OR logic, proximity distance calculation, parameter validation, edge cases)
- **Integration tests**: Full API requests with test database, verify filter + pagination + ranking integration, performance tests with larger datasets

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Django/DRF conventions
- [ ] No console errors or warnings
- [ ] Filter logic is efficient (database-level WHERE clauses)
- [ ] Changes committed with reference to task ID (m01-e03-t01)
- [ ] Ready for frontend integration (m01-e03-t02)

## Dependencies
- Requires: m01-e01-t02 (REST API endpoints exist), m01-e01-t05 (distance calculation utility exists)
- Blocks: m01-e03-t02 (Filter UI), m01-e03-t03 (Filter State Management)

## Technical Notes
- Use Django ORM Q objects for multi-select OR logic: `Q(category='events') | Q(category='nightlife')`
- Consider using django-filter library for cleaner filter implementation (optional, evaluate if it reduces code)
- Proximity filter requires user location from query params (lat/lng) - frontend will send this
- Distance calculation should use existing utility from m01-e01-t05 (don't duplicate code)
- Maintain backward compatibility: API should work with no filters (returns all flyers as before)
- Performance: ensure database indexes exist on `category` field (should be in place from m01-e01-t01)

## References
- Django QuerySet filtering: https://docs.djangoproject.com/en/5.1/topics/db/queries/#retrieving-specific-objects-with-filters
- Django Q objects: https://docs.djangoproject.com/en/5.1/topics/db/queries/#complex-lookups-with-q-objects
- DRF filtering: https://www.django-rest-framework.org/api-guide/filtering/
- Existing ranking algorithm implementation (m01-e01-t04)
- Existing distance calculation utility (m01-e01-t05)
