---
id: m01-e03-t01
epic: m01-e03
title: Implement Image Storage and Serving for Flyers
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Image Storage and Serving for Flyers

## Objective
Configure backend to handle flyer image uploads (1-5 images per flyer), store them efficiently, and serve them via API with proper URLs for frontend consumption.

## Acceptance Criteria
- [ ] Flyer model supports 1-5 images using related ImageModel (one-to-many)
- [ ] Images stored using Django's FileField/ImageField with Pillow backend
- [ ] Image filenames are unique (UUID-based) to prevent collisions
- [ ] API returns full image URLs (absolute paths) in flyer serializer
- [ ] Images served via Django's media URL configuration
- [ ] Image validation: max file size (5MB), allowed formats (JPEG, PNG, WebP)
- [ ] Cascade deletion: deleting flyer removes associated images from storage
- [ ] Image ordering preserved (first image is primary/thumbnail)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Image model creation and relationship to flyer
- Single image upload (1 image)
- Multiple image upload (5 images at maximum)
- Image ordering preservation
- Image URL generation in API response
- File validation (size limits, format restrictions)
- Invalid file handling (wrong format, too large, corrupted)
- Cascade deletion of images with flyer
- No images case (flyer with 0 images should fail validation)

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (add Image model)
- `pockitflyer_backend/flyers/serializers.py` (include images in FlyerSerializer)
- `pockitflyer_backend/flyers/tests/test_models.py` (image model tests)
- `pockitflyer_backend/flyers/tests/test_serializers.py` (image serialization tests)
- `pockitflyer_backend/pockitflyer_backend/settings.py` (MEDIA_ROOT, MEDIA_URL)
- `pockitflyer_backend/pockitflyer_backend/urls.py` (serve media in development)

## Dependencies
- Epic m01-e01 tasks (Flyer model must exist)
- Pillow library (already in tech stack)

## Notes
- Image model fields: `image` (ImageField), `flyer` (ForeignKey), `order` (IntegerField for sorting)
- Use `upload_to` parameter to organize images: `flyers/{flyer_id}/{uuid}.{ext}`
- For production, consider CDN integration (future enhancement)
- Primary image is the first in order (order=0)
- Frontend will handle image caching separately
