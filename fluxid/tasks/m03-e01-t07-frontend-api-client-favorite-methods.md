---
id: m03-e01-t07
epic: m03-e01
title: Add Favorite Methods to API Client
status: pending
priority: high
tdd_phase: red
---

# Task: Add Favorite Methods to API Client

## Objective
Add createFavorite and deleteFavorite methods to API client service. Methods handle authentication headers, error responses, and return appropriate success/error states.

## Acceptance Criteria
- [ ] createFavorite(flyerId) method POSTs to /api/favorites/
- [ ] deleteFavorite(flyerId) method DELETEs to /api/favorites/{flyerId}/
- [ ] Both methods include JWT authentication token in headers
- [ ] Methods return Future<bool> indicating success/failure
- [ ] Methods handle network errors gracefully (timeout, connection failure)
- [ ] Methods handle HTTP error responses (400, 401, 404, 500)
- [ ] Methods parse and return response data on success
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- createFavorite makes POST request to correct endpoint
- createFavorite includes auth token in headers
- createFavorite returns true on successful response (201)
- createFavorite returns false on error response (400, 401, 404)
- createFavorite handles network timeout
- deleteFavorite makes DELETE request to correct endpoint
- deleteFavorite includes auth token in headers
- deleteFavorite returns true on successful response (204)
- deleteFavorite returns false on error response (401, 404)
- deleteFavorite handles network timeout

## Files to Modify/Create
- `pockitflyer_app/lib/services/api_client.dart` (add favorite methods)
- `pockitflyer_app/test/services/api_client_test.dart` (add favorite method tests)

## Dependencies
- m03-e01-t02 (favorite API endpoints must exist)
- m01-e01-t07 (API client base service must exist)

## Notes
- Use existing dio instance from API client
- Add auth token via dio interceptor or manual header
- POST body: {"flyer_id": flyerId}
- DELETE URL: /api/favorites/$flyerId/
- Handle 401 by triggering logout/re-authentication flow
- Consider retry logic for transient network errors (exponential backoff)
