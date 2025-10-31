---
id: m03-e03-t07
epic: m03-e03
title: API Client Feed Filter Methods
status: pending
priority: high
tdd_phase: red
---

# Task: API Client Feed Filter Methods

## Objective
Extend API client to support filtered feed requests (favorites, following) using either dedicated endpoints or filter query parameter. Methods handle authentication requirements and return same flyer data structure as main feed.

## Acceptance Criteria
- [ ] Method `getFavoritesFeed(lat, lon, page)` fetches favorited flyers
- [ ] Method `getFollowingFeed(lat, lon, page)` fetches followed creators' flyers
- [ ] Methods use GET /api/favorites/feed/ and /api/following/feed/ endpoints
- [ ] Alternative: extend existing `getFeed()` method with optional filter parameter
- [ ] Methods include authentication token in request headers
- [ ] Methods handle 401 errors gracefully (redirect to login or show message)
- [ ] Methods parse response into same Flyer model as main feed
- [ ] Methods support pagination (page parameter)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- getFavoritesFeed() sends correct API request
- getFollowingFeed() sends correct API request
- Methods include authentication token in headers
- Methods parse response correctly into Flyer models
- Methods handle 401 errors without crashing
- Methods handle 400/500 errors appropriately
- Methods support pagination parameter
- Mock HTTP tests for each method
- Integration tests with real API (optional, may be e2e)

## Files to Modify/Create
- `pockitflyer_app/lib/services/api_client.dart` (add filter feed methods)
- `pockitflyer_app/test/services/api_client_test.dart` (add filter method tests)

## Dependencies
- m03-e03-t01 (Backend favorites feed API)
- m03-e03-t02 (Backend following feed API)
- m01-e01-t07 (Existing API client structure)

## Notes
- Reuse existing getFeed() pagination and parsing logic
- Consider using named parameters for cleaner API: getFeed(filter: FilterType.favorites)
- Auth token: retrieve from secure storage service
- Error handling: throw custom exceptions (UnauthorizedException, etc.)
- Use http package or dio for HTTP requests
