---
id: m02-e02-t03
epic: m02-e02
title: Create Image Storage Service with Pillow Processing
status: pending
priority: high
tdd_phase: red
---

# Task: Create Image Storage Service with Pillow Processing

## Objective
Implement Django service class for handling profile picture uploads with image processing using Pillow. Service handles validation, resizing, format conversion, and storage with circuit breaker pattern for resilience.

## Acceptance Criteria
- [ ] ImageStorageService class with upload, resize, and storage methods
- [ ] Accepts image uploads in JPG, PNG, HEIC formats
- [ ] Max upload size: 5MB (validate before processing)
- [ ] Resize images to 512x512px (maintain aspect ratio with padding)
- [ ] Generate thumbnail: 128x128px
- [ ] Convert all images to JPG format for storage (optimize file size)
- [ ] Store original, resized, and thumbnail versions
- [ ] Circuit breaker pattern with exponential backoff for Pillow operations
- [ ] Return absolute URLs for stored images
- [ ] Handle corrupt/invalid image files gracefully
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Upload valid JPG image: validates, processes, stores correctly
- Upload valid PNG image: converts to JPG
- Upload valid HEIC image: converts to JPG (iOS format)
- Image exceeding 5MB returns error
- Corrupt image file returns error without crashing
- Non-image file returns error
- Unsupported format returns error
- Circuit breaker triggers on Pillow failure
- Retry logic with exponential backoff works correctly
- Thumbnail generation produces correct dimensions
- Aspect ratio maintained with padding (letterbox/pillarbox)

## Files to Modify/Create
- `pockitflyer_backend/users/services/image_storage.py` (ImageStorageService)
- `pockitflyer_backend/users/services/__init__.py`
- `pockitflyer_backend/users/tests/test_image_storage_service.py`
- `pockitflyer_backend/pockitflyer_backend/settings.py` (MEDIA_ROOT, MEDIA_URL config)

## Dependencies
- m02-e01-t01 (Profile model with ImageField)
- External: Pillow library (install via pip)

## Notes
- Circuit breaker pattern: fail fast after 3 consecutive Pillow failures
- Exponential backoff: 1s, 2s, 4s between retries
- Store images in MEDIA_ROOT/profile_pictures/{user_id}/
- Use UUIDs for filenames to avoid collisions
- Clean up old images when new one uploaded (garbage collection)
- HEIC support requires Pillow with pillow-heif plugin
- Consider image orientation EXIF data (auto-rotate)
- Padding color for aspect ratio adjustment: white or transparent
