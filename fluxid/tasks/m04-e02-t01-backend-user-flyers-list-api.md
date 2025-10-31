---
id: m04-e02-t01
epic: m04-e02
title: Create User Flyers List API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create User Flyers List API Endpoint

## Objective
Build Django REST API endpoint to retrieve all flyers created by the authenticated user for display on their profile page.

## Acceptance Criteria
- [ ] GET endpoint at `/api/v1/users/me/flyers/` requires JWT authentication
- [ ] Returns paginated list of all flyers created by authenticated user
- [ ] Flyers ordered by publication_date descending (newest first)
- [ ] Each flyer includes: id, title, images (thumbnail URLs), status (active/expired/scheduled), publication_date, expiration_date, location_address, category_tags
- [ ] Status computed based on current date vs publication/expiration dates
- [ ] Empty list returned for users with no flyers (not 404)
- [ ] Pagination parameters: page, page_size (default 20, max 100)
- [ ] Response includes pagination metadata (count, next, previous)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Authentication required (401 for unauthenticated)
- User with 0 flyers returns empty list
- User with 1 flyer returns single item
- User with many flyers returns paginated results
- Flyers ordered by publication_date descending
- Status correctly computed for active flyers (publication_date <= now < expiration_date)
- Status correctly computed for expired flyers (now >= expiration_date)
- Status correctly computed for scheduled flyers (now < publication_date)
- User only sees their own flyers (not other users' flyers)
- Pagination works correctly (page 1, page 2, invalid pages)
- Image URLs correctly generated for thumbnails
- Category tags properly serialized

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (UserFlyersListView)
- `pockitflyer_backend/flyers/serializers.py` (UserFlyerListSerializer)
- `pockitflyer_backend/flyers/tests/test_views.py`

## Dependencies
- M02-E01 (JWT authentication infrastructure)
- M04-E01-T01 (Flyer model and creation API)

## Notes
- Filter by `creator=request.user` to ensure users only see their own flyers
- Status should be computed property, not stored in database
- Include only thumbnail URL for first image to minimize response size
- Consider adding filters (status, category) in future iterations if needed
- Use DRF pagination classes for consistent pagination behavior
