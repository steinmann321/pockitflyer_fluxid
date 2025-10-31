---
id: m04-e02-t02
epic: m04-e02
title: Create Flyer Update API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyer Update API Endpoint

## Objective
Build Django REST API endpoint for authenticated users to update their own flyers with full edit capabilities including images, text, tags, location, and dates.

## Acceptance Criteria
- [ ] PUT/PATCH endpoint at `/api/v1/flyers/{id}/` requires JWT authentication
- [ ] User can only update flyers they created (403 for other users' flyers)
- [ ] Request accepts multipart/form-data for image uploads
- [ ] Supports updating: title, caption, info_field_1, info_field_2, category_tags, location_address, publication_date, expiration_date
- [ ] Image updates: add new images (respecting 1-5 limit), remove images by ID, reorder images
- [ ] Backend validates expiration_date > publication_date on updates
- [ ] Backend re-geocodes ONLY if location_address changed
- [ ] New images processed with Pillow (format validation, compression, orientation)
- [ ] Removed images deleted from storage (cleanup orphaned files)
- [ ] Model-layer validation prevents invalid states
- [ ] Response returns updated complete flyer object
- [ ] Circuit breaker wraps geocoding service calls with exponential backoff
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Authentication required (401 for unauthenticated)
- Authorization: user can update own flyers, not others' (403)
- 404 for non-existent flyer
- Text field updates persist correctly
- Category tag updates (add tags, remove tags, replace all)
- Date validation on update (expiration > publication)
- Image additions within 1-5 limit (reject if would exceed 5)
- Image removals (but prevent removing all - must keep at least 1)
- Image reordering persists correctly
- Address change triggers new geocoding
- Address unchanged skips geocoding (performance test)
- Geocoding service failures handled gracefully
- New image upload failures rollback transaction
- Storage cleanup for removed images
- Concurrent update handling (optimistic locking or last-write-wins)
- Partial updates via PATCH work correctly

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (FlyerUpdateView)
- `pockitflyer_backend/flyers/serializers.py` (FlyerUpdateSerializer)
- `pockitflyer_backend/flyers/services/image_storage.py` (cleanup method for removed images)
- `pockitflyer_backend/flyers/tests/test_views.py`
- `pockitflyer_backend/flyers/tests/test_update_validation.py`

## Dependencies
- M04-E02-T01 (User flyers list API)
- M04-E01-T01 (Flyer creation API and models)
- External: geopy library (for address changes)
- External: Pillow library (for new image uploads)

## Notes
- Compare location_address before geocoding to avoid unnecessary API calls
- Use Django signals or explicit cleanup for orphaned image files
- Consider optimistic locking using version field or updated_at comparison
- Validate creator ownership in view, not just serializer
- Transaction management: rollback all changes if any validation fails
- Return clear error messages for each validation failure
- Image order should be explicit (order field in FlyerImage model)
