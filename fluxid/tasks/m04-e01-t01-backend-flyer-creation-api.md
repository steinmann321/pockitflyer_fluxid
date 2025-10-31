---
id: m04-e01-t01
epic: m04-e01
title: Create Flyer Creation API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyer Creation API Endpoint

## Objective
Build Django REST API endpoint for authenticated users to create flyers with image upload, text fields, category tags, address geocoding, and date validation.

## Acceptance Criteria
- [ ] POST endpoint at `/api/v1/flyers/` requires JWT authentication
- [ ] Request accepts multipart/form-data for image uploads (1-5 images)
- [ ] Request fields: title, caption, info_field_1, info_field_2, category_tags (array), location_address, publication_date, expiration_date
- [ ] Backend validates all required fields (images, title, location_address, publication_date, expiration_date)
- [ ] Backend validates expiration_date > publication_date
- [ ] Backend geocodes location_address to latitude/longitude using geopy
- [ ] Images processed using Pillow (format validation, compression, orientation correction)
- [ ] Flyer creator automatically set to authenticated user
- [ ] Response returns complete flyer object including geocoordinates
- [ ] Circuit breaker wraps geocoding service calls with exponential backoff
- [ ] Proper error responses for validation failures, geocoding failures, image processing errors
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Authentication required (401 for unauthenticated)
- Image count validation (0 images rejected, 1-5 accepted, 6+ rejected)
- Image format validation (JPEG/PNG/HEIC accepted, others rejected)
- Text field character limits enforced
- Category tag validation (valid tags accepted, invalid rejected)
- Address geocoding success and failure scenarios
- Date validation (expiration > publication, past dates handling)
- Geocoding service timeout handling with circuit breaker
- Geocoding service down/unavailable scenarios
- Image processing errors (corrupted files, oversized files)
- Complete flyer object returned on success
- Database persistence verification

## Files to Modify/Create
- `pockitflyer_backend/flyers/views.py` (FlyerCreateView)
- `pockitflyer_backend/flyers/serializers.py` (FlyerCreateSerializer)
- `pockitflyer_backend/flyers/services/geocoding.py` (geocoding service with circuit breaker)
- `pockitflyer_backend/flyers/services/image_processing.py` (Pillow integration)
- `pockitflyer_backend/flyers/tests/test_views.py`
- `pockitflyer_backend/flyers/tests/test_geocoding_service.py`
- `pockitflyer_backend/flyers/tests/test_image_processing.py`

## Dependencies
- M02-E01 (JWT authentication infrastructure)
- m01-e01-t02 (Flyer and FlyerImage models)
- External: geopy library
- External: Pillow library

## Notes
- Use `geopy.geocoders.Nominatim` with user_agent configuration
- Circuit breaker settings: 3 failures trigger open, 60s timeout, exponential backoff
- Image compression: max 2048px width/height, 85% JPEG quality
- Default publication_date: now, default expiration_date: now + 30 days
- Cleanup uploaded images on creation failure (transaction rollback)
- Geocoding timeout: 10 seconds per request
- Return clear error messages for address not found vs geocoding service unavailable
