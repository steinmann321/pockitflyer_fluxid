---
id: m02-e02-t04
epic: m02-e02
title: Create Profile Picture Upload API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Picture Upload API Endpoint

## Objective
Implement Django REST API endpoint for uploading profile pictures using multipart/form-data. Integrates with ImageStorageService for processing and storage.

## Acceptance Criteria
- [ ] POST `/api/users/me/profile/picture/` endpoint accepts image upload
- [ ] Requires JWT authentication
- [ ] Accepts multipart/form-data with "image" field
- [ ] Delegates to ImageStorageService for validation and processing
- [ ] Returns updated profile with new picture URLs
- [ ] Old profile picture deleted when new one uploaded
- [ ] Returns 400 for invalid image (wrong format, too large, corrupt)
- [ ] Returns 401 for unauthenticated requests
- [ ] Upload completes within 5 seconds for typical images
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Valid JPG upload with authentication
- Valid PNG upload converts to JPG
- Valid HEIC upload (iOS native format)
- Image exceeding 5MB returns 400 error
- Corrupt image file returns 400 error
- Non-image file returns 400 error
- Unauthenticated request returns 401
- Old picture deleted when new one uploaded
- Response includes full profile with updated picture URLs
- Upload time measured: verify < 5 seconds for 2MB image

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (ProfilePictureUploadView)
- `pockitflyer_backend/users/serializers.py` (ProfilePictureUploadSerializer)
- `pockitflyer_backend/users/urls.py` (picture upload route)
- `pockitflyer_backend/users/tests/test_profile_picture_api.py`

## Dependencies
- m02-e02-t03 (ImageStorageService)
- m02-e01-t02 (JWT authentication)
- m02-e02-t02 (Profile update API)

## Notes
- Use multipart/form-data for file uploads (not base64 JSON)
- Old picture cleanup prevents storage bloat
- Consider rate limiting for upload endpoint (prevent abuse)
- Response includes thumbnail URL for immediate UI update
- CORS configuration needed for image uploads from frontend
- File size validation happens before processing to save resources
