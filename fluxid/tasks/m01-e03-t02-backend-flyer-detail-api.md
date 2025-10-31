---
id: m01-e03-t02
epic: m01-e03
title: Create Flyer Detail API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyer Detail API Endpoint

## Objective
Create a dedicated API endpoint to retrieve full details of a single flyer by ID, including all images, complete description, and location data needed for detail view and map integration.

## Acceptance Criteria
- [ ] Endpoint: `GET /api/flyers/{id}/` returns single flyer details
- [ ] Response includes all flyer fields (title, description, category, dates, location, creator)
- [ ] Response includes all images with URLs in correct order (order field)
- [ ] Response includes distance if user location provided (optional query params: lat, lng)
- [ ] Returns 404 for non-existent flyer IDs
- [ ] Returns 404 for expired flyers (valid_until < today)
- [ ] Creator information included (username, profile_picture if available)
- [ ] Response time < 200ms for single flyer lookup
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Valid flyer ID returns complete data
- Invalid/non-existent flyer ID returns 404
- Expired flyer returns 404
- Images returned in correct order
- Distance calculation when user location provided
- No distance when user location not provided
- Creator data properly serialized
- All required fields present in response
- Optional fields handled correctly (null/missing)
- Permission handling (anonymous users can view)

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (add FlyerDetailView)
- `pockitflyer_backend/flyers/urls.py` (add detail route)
- `pockitflyer_backend/flyers/serializers.py` (create detailed serializer if needed)
- `pockitflyer_backend/flyers/tests/test_views.py` (detail endpoint tests)

## Dependencies
- Task m01-e03-t01 (image storage must be implemented)
- Epic m01-e01 tasks (Flyer model and creator relationship)

## Notes
- Use Django REST Framework's RetrieveAPIView or equivalent
- Detail serializer can be more comprehensive than list serializer
- Distance calculation reuses logic from feed API
- Anonymous access allowed (authentication required later in M02/M03)
- Response format matches frontend expectations for detail screen
