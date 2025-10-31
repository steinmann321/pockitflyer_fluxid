---
id: m04-e02-t06
epic: m04-e02
title: Implement API Client Flyer Update Methods
status: pending
priority: high
tdd_phase: red
---

# Task: Implement API Client Flyer Update Methods

## Objective
Extend Flutter API client service with methods for retrieving user's flyers list and updating flyers.

## Acceptance Criteria
- [ ] Method `getUserFlyers({page, pageSize})` calls GET `/api/v1/users/me/flyers/`
- [ ] Returns paginated list of user's flyers with metadata
- [ ] Method `updateFlyer(flyerId, data)` calls PUT/PATCH `/api/v1/flyers/{id}/`
- [ ] Supports multipart/form-data for image uploads
- [ ] Handles image additions (new file uploads)
- [ ] Handles image removals (sends image IDs to delete)
- [ ] Handles image reordering (sends order sequence)
- [ ] Proper error handling for network failures
- [ ] Proper error handling for validation errors (400)
- [ ] Proper error handling for authorization errors (403)
- [ ] Returns updated flyer object on success
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- getUserFlyers success returns list
- getUserFlyers with pagination parameters
- getUserFlyers handles 401 (unauthenticated)
- getUserFlyers handles network errors
- getUserFlyers handles empty list
- updateFlyer success returns updated flyer
- updateFlyer with new images uploads files
- updateFlyer with removed images sends deletion list
- updateFlyer with reordered images sends new order
- updateFlyer handles 400 (validation errors)
- updateFlyer handles 403 (not owner)
- updateFlyer handles 404 (flyer not found)
- updateFlyer handles network errors
- Multipart encoding works correctly for image uploads

## Files to Modify/Create
- `pockitflyer_app/lib/services/api_client.dart` (extend existing service)
- `pockitflyer_app/test/services/api_client_test.dart`

## Dependencies
- M04-E02-T01 (Backend user flyers list API)
- M04-E02-T02 (Backend flyer update API)
- M02-E01-T05 (JWT token storage service)

## Notes
- Reuse existing API client infrastructure from previous milestones
- Use http.MultipartRequest for image uploads
- Send JWT token in Authorization header
- Parse error responses to extract validation messages
- Consider retry logic for network failures
- Image upload progress tracking would improve UX (optional enhancement)
- Ensure proper content-type headers for multipart requests
