---
id: m04-e03-t08
title: Frontend API Client Integration
epic: m04-e03
status: pending
---

# Task: Frontend API Client Integration

## Description
Add API client methods for expiration extension, reactivation, and deletion operations. Integrate with backend endpoints.

## Scope
- Add `updateFlyerExpiration()` method to API client
- Add `deleteFlyer()` method to API client
- Handle authentication headers (JWT)
- Handle response parsing
- Handle error responses (400, 403, 404)
- Circuit breaker pattern for resilience
- Retry logic with exponential backoff
- Unit tests for all methods

## Success Criteria
- [ ] `updateFlyerExpiration(id, expirationDate, isActive)` method exists
- [ ] `deleteFlyer(id)` method exists
- [ ] Methods include JWT authentication headers
- [ ] Methods parse success responses correctly
- [ ] Methods parse error responses correctly
- [ ] Circuit breaker prevents cascading failures
- [ ] Retry logic handles transient failures
- [ ] All tests pass with `tdd_green` tag

## Test Cases
```dart
// tags: ['tdd_red']
test('updateFlyerExpiration sends correct request', () {
  // Verify HTTP method, URL, headers, body
});

// tags: ['tdd_red']
test('updateFlyerExpiration includes auth header', () {
  // Verify JWT token in Authorization header
});

// tags: ['tdd_red']
test('updateFlyerExpiration parses success response', () {
  // Verify response parsing
});

// tags: ['tdd_red']
test('updateFlyerExpiration handles 400 error', () {
  // Verify error handling
});

// tags: ['tdd_red']
test('updateFlyerExpiration handles 403 error', () {
  // Verify unauthorized error
});

// tags: ['tdd_red']
test('deleteFlyer sends DELETE request', () {
  // Verify HTTP method and URL
});

// tags: ['tdd_red']
test('deleteFlyer includes auth header', () {
  // Verify JWT token
});

// tags: ['tdd_red']
test('deleteFlyer handles 204 success', () {
  // Verify success handling
});

// tags: ['tdd_red']
test('deleteFlyer handles 404 error', () {
  // Verify not found handling
});

// tags: ['tdd_red']
test('Circuit breaker opens on repeated failures', () {
  // Verify circuit breaker behavior
});

// tags: ['tdd_red']
test('Retry logic with exponential backoff', () {
  // Verify retry behavior
});
```

## Dependencies
- M04-E03-T03 (Backend Reactivation API)
- M04-E03-T04 (Backend Hard Delete API)
- M01-E01-T07 (Frontend API Client)

## Acceptance
- All tests marked `tdd_green`
- API client methods work correctly
- Error handling robust
- Resilience patterns implemented
