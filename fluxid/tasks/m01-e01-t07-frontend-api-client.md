---
id: m01-e01-t07
epic: m01-e01
title: Implement Feed API Client and Models
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Feed API Client and Models

## Objective
Create Flutter API client for feed endpoint and data models for Flyer, Creator, and pagination.

## Acceptance Criteria
- [ ] Data models with JSON serialization:
  - Flyer: id, title, description, creator, images, locationAddress, latitude, longitude, distanceKm, validFrom, validUntil, isValid
  - Creator: id, username, profilePictureUrl
  - PaginatedFeedResponse: results (List<Flyer>), count, next, previous
- [ ] FeedApiClient class with method: `Future<PaginatedFeedResponse> getFeed({required double lat, required double lng, int page = 1, int pageSize = 20})`
- [ ] HTTP client: dio or http package with proper error handling
- [ ] Base URL configuration: environment-based (debug/production)
- [ ] Request timeout: 10 seconds
- [ ] Error handling: network errors, timeout, 4xx/5xx responses with custom exceptions
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Model JSON serialization and deserialization
- Successful API call with various parameters
- Pagination parameters in request
- Network error handling (timeout, no connection, 4xx, 5xx)
- Mock HTTP responses (no actual network calls in tests)
- Error exception types and messages

## Files to Modify/Create
- `pockitflyer_app/lib/models/flyer.dart`
- `pockitflyer_app/lib/models/creator.dart`
- `pockitflyer_app/lib/models/paginated_response.dart`
- `pockitflyer_app/lib/services/feed_api_client.dart`
- `pockitflyer_app/lib/config/api_config.dart` (base URL)
- `pockitflyer_app/test/models/` (model tests)
- `pockitflyer_app/test/services/feed_api_client_test.dart`

## Dependencies
- m01-e01-t04 (Backend API must be defined)
- External: dio or http package, json_serializable

## Notes
- Use json_serializable for model code generation
- Base URLs: debug: http://localhost:8000, production: TBD
- Custom exceptions: NetworkException, TimeoutException, ServerException
- Model validation: ensure required fields are present in JSON
