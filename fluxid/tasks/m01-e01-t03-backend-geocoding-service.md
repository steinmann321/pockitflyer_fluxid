---
id: m01-e01-t03
epic: m01-e01
title: Implement Geocoding Service with Circuit Breaker
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Geocoding Service with Circuit Breaker

## Objective
Create service layer for address-to-coordinate conversion using geopy with circuit breaker pattern and retry logic.

## Acceptance Criteria
- [ ] GeocodingService class with `geocode(address: str) -> tuple[float, float]` method
- [ ] Uses geopy Nominatim geocoder with proper user agent
- [ ] Circuit breaker implementation:
  - Opens after 3 consecutive failures
  - Half-open state after 60 second cooldown
  - Closed after 2 successful requests in half-open state
- [ ] Retry logic with exponential backoff (3 attempts, 1s/2s/4s delays)
- [ ] Timeout per request: 5 seconds
- [ ] Raises GeocodingError on failure with clear error message
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Successful geocoding for various address formats
- Invalid address handling
- Service timeout behavior
- Circuit breaker state transitions (closed -> open -> half-open -> closed)
- Retry mechanism with exponential backoff
- Error handling and custom exception raising
- Mock external geopy calls (no actual network requests in tests)

## Files to Modify/Create
- `pockitflyer_backend/flyers/services/geocoding.py` (GeocodingService, GeocodingError)
- `pockitflyer_backend/flyers/services/__init__.py`
- `pockitflyer_backend/flyers/tests/test_services/test_geocoding.py`

## Dependencies
- External: `geopy` library
- External: circuit breaker library (e.g., `pybreaker`) or custom implementation

## Notes
- Circuit breaker state is in-memory (resets on server restart)
- User agent for Nominatim: "PockitFlyer/1.0"
- Geocoding happens on flyer creation only, not on every feed request
- Backend owns 100% of geocoding logic - frontend never geocodes
