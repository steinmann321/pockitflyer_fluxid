---
id: m04-e01-t11
epic: m04-e01
title: Integrate Flyer Creation API Client
status: pending
priority: high
tdd_phase: red
---

# Task: Integrate Flyer Creation API Client

## Objective
Add createFlyer method to API client for multipart/form-data submission with images and flyer data.

## Acceptance Criteria
- [ ] createFlyer method in ApiClient
- [ ] Parameters: images (List<File>), title, caption, info fields, category IDs, address, dates
- [ ] Multipart/form-data encoding for image uploads
- [ ] JWT token included in Authorization header
- [ ] Progress callback for upload progress (0-100%)
- [ ] Timeout: 60 seconds for large uploads
- [ ] Error handling: network errors, validation errors, server errors
- [ ] Response parsing: complete Flyer object with geocoordinates
- [ ] Retry logic: 3 attempts with exponential backoff
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Successful flyer creation
- Multipart/form-data encoding
- Authorization header included
- Upload progress callback
- Network error handling
- Validation error parsing
- Server error handling
- Timeout handling
- Retry logic verification
- Response parsing
- Mock API tests

## Files to Modify/Create
- `pockitflyer_app/lib/services/api_client.dart` (add createFlyer method)
- `pockitflyer_app/lib/models/flyer.dart` (ensure complete model)
- `pockitflyer_app/test/services/api_client_test.dart`

## Dependencies
- m04-e01-t01 (backend API endpoint)
- Flutter `http` or `dio` package for multipart uploads

## Notes
- Use `http.MultipartRequest` or `dio.FormData`
- Images as `MultipartFile` with field names: image_1, image_2, etc.
- Other fields as form fields (text)
- Category IDs as comma-separated or array
- Dates as ISO 8601 format
- Progress callback updates UI progress indicator
- Parse validation errors into user-friendly messages
- Timeout allows large image uploads over slow networks
