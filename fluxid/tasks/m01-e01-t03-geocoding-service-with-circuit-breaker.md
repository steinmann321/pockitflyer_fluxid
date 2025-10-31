---
id: m01-e01-t03
title: Geocoding Service with Circuit Breaker
epic: m01-e01
milestone: m01
status: pending
---

# Task: Geocoding Service with Circuit Breaker

## Context
Part of Backend Flyer API and Data Services (m01-e01) in Milestone 1: Anonymous Flyer Browsing (m01).

Implements geocoding service integration using geopy to convert addresses to latitude/longitude coordinates. Follows the architecture principle of resilience by implementing circuit breaker pattern with exponential backoff to handle external service failures gracefully. Geocoding happens on the backend only - coordinates are stored in the database for frontend consumption.

## Implementation Guide for LLM Agent

### Objective
Create a geocoding service that converts addresses to coordinates using geopy with circuit breaker pattern and retry logic to ensure resilience against external service failures.

### Steps

1. **Install geopy dependency** (verify in requirements.txt)
   - Check `pockitflyer_backend/requirements.txt` for `geopy>=2.4.0`
   - If missing, add it and run `pip install -r requirements.txt`

2. **Create geocoding service** in `pockitflyer_backend/flyers/services/geocoding.py`

   **GeocodingService class**:
   - Initialize with geopy Nominatim geocoder (user_agent='pokitflyer')
   - Implement `geocode_address(address: str) -> tuple[float, float] | None`:
     - Takes address string
     - Returns (latitude, longitude) tuple or None on failure
     - Uses circuit breaker pattern (see step 3)
     - Implements retry logic with exponential backoff
     - Handles geopy exceptions gracefully
     - Logs failures without raising exceptions (return None instead)

3. **Implement circuit breaker pattern**

   **Circuit breaker states**:
   - CLOSED: Normal operation, requests pass through
   - OPEN: Too many failures, reject requests immediately without calling service
   - HALF_OPEN: After timeout, allow one test request to check if service recovered

   **Configuration** (class-level or settings):
   - Failure threshold: 5 consecutive failures → OPEN
   - Timeout: 60 seconds (OPEN → HALF_OPEN)
   - Success threshold: 2 consecutive successes in HALF_OPEN → CLOSED

   **Implementation approach** (simple, no external library needed):
   - Track state, failure count, last failure time as class attributes
   - Before geocoding: check circuit state
     - OPEN + timeout not elapsed → return None immediately
     - OPEN + timeout elapsed → set HALF_OPEN, attempt request
   - After geocoding attempt:
     - Success → reset failure count, CLOSED state
     - Failure → increment failure count, check threshold
   - Log state transitions

4. **Implement retry logic with exponential backoff**

   **Retry configuration**:
   - Max retries: 3
   - Initial delay: 1 second
   - Backoff multiplier: 2 (1s, 2s, 4s)
   - Only retry on timeout/network errors, not invalid address

   **Implementation**:
   - Wrap geopy call in retry loop
   - Catch specific exceptions: `GeocoderTimedOut`, `GeocoderServiceError`
   - Don't retry on `GeocoderQueryError` (invalid address)
   - Use `time.sleep()` for delays
   - Log each retry attempt

5. **Create helper function for Location model integration**

   **Function**: `geocode_and_update_location(location: Location) -> bool`
   - Takes Location instance with address field populated
   - Calls GeocodingService.geocode_address()
   - If successful: update location.latitude, location.longitude, save()
   - If failed: log error, return False (don't raise exception)
   - Return True on success, False on failure

6. **Add service configuration to settings** in `pockitflyer_backend/pokitflyer_api/settings.py`
   - Add GEOCODING settings dict:
     ```python
     GEOCODING = {
         'USER_AGENT': 'pokitflyer',
         'CIRCUIT_BREAKER': {
             'FAILURE_THRESHOLD': 5,
             'TIMEOUT_SECONDS': 60,
             'SUCCESS_THRESHOLD': 2,
         },
         'RETRY': {
             'MAX_ATTEMPTS': 3,
             'INITIAL_DELAY': 1.0,
             'BACKOFF_MULTIPLIER': 2.0,
         }
     }
     ```

7. **Create comprehensive test suite** in `pockitflyer_backend/flyers/tests/test_geocoding.py`

   **GeocodingService tests** (unit tests with mocked geopy):
   - **Happy path**:
     - Valid address returns correct coordinates
     - Multiple addresses geocoded successfully
   - **Error handling**:
     - Invalid address returns None (not exception)
     - Network timeout triggers retry logic
     - After max retries, returns None
   - **Retry logic**:
     - First request times out, second succeeds → returns coordinates
     - Exponential backoff delays verified (mock time.sleep)
     - Max retry limit enforced
   - **Circuit breaker**:
     - CLOSED state: requests pass through normally
     - After 5 failures → OPEN state, immediate rejection
     - OPEN state: requests return None without calling geopy
     - After 60s timeout → HALF_OPEN, test request allowed
     - HALF_OPEN success → CLOSED
     - HALF_OPEN failure → back to OPEN
   - **Edge cases**:
     - Empty address string
     - Very long address string
     - Special characters in address
     - International addresses (non-ASCII characters)

   **Integration tests** (with real geopy, rate-limited):
   - Real address geocoding (use well-known address: "1600 Amphitheatre Parkway, Mountain View, CA")
   - Verify coordinates within reasonable range
   - Test only 1-2 addresses to avoid rate limiting

   **Helper function tests**:
   - `geocode_and_update_location()` updates Location model on success
   - Returns True/False correctly
   - Doesn't raise exceptions on failure

8. **Document service usage** in code comments
   - Explain circuit breaker pattern (why it's needed)
   - Document retry strategy
   - Add example usage in docstrings

### Acceptance Criteria
- [ ] Valid address geocoded to correct coordinates [Test: "1600 Amphitheatre Parkway, Mountain View, CA"]
- [ ] Invalid address returns None without exception [Test: empty string, gibberish]
- [ ] Retry logic attempts 3 times with exponential backoff [Test: mock timeouts, verify delays]
- [ ] Circuit breaker OPENS after 5 consecutive failures [Test: force 5 failures, verify state]
- [ ] Circuit breaker OPEN state rejects requests immediately [Test: verify no geopy calls while OPEN]
- [ ] Circuit breaker transitions to HALF_OPEN after 60s timeout [Test: mock time, verify transition]
- [ ] Circuit breaker CLOSES after success in HALF_OPEN [Test: successful request after timeout]
- [ ] `geocode_and_update_location()` updates Location model [Test: call with Location instance, verify lat/long saved]
- [ ] Service handles international addresses [Test: non-ASCII characters]
- [ ] All failures logged appropriately [Test: verify log messages]
- [ ] All tests pass with >85% coverage [Test: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/services/__init__.py` - NEW: empty init file
- `pockitflyer_backend/flyers/services/geocoding.py` - NEW: GeocodingService class, helper functions
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add GEOCODING configuration
- `pockitflyer_backend/flyers/tests/test_geocoding.py` - NEW: geocoding service tests
- `pockitflyer_backend/requirements.txt` - MODIFY: add geopy if missing

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: Circuit breaker state machine, retry logic, exponential backoff calculation, error handling (mocked geopy)
- **Integration tests**: Real geocoding with geopy (limited to 1-2 requests to avoid rate limiting), Location model integration

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project resilience principles (circuit breaker, retries)
- [ ] No exceptions raised on geocoding failures (returns None)
- [ ] Circuit breaker behavior verified through testing
- [ ] Minimal documentation explaining circuit breaker pattern
- [ ] Changes committed with reference to task ID (m01-e01-t03)
- [ ] All TDD markers set to `tdd_green` after verifying tests pass
- [ ] Ready for use in flyer creation workflows (future epics)

## Dependencies
- Requires: m01-e01-t01 (Location model must exist)
- geopy library (external dependency)
- No blocking dependencies for other tasks in this epic

## Technical Notes

### Why Circuit Breaker?
Per ARCHITECTURE.md: "All external service calls use circuit breakers and retry mechanisms with exponential backoff"
- Prevents cascading failures: If geocoding service is down, don't keep hammering it
- Fail fast: When circuit is OPEN, return immediately instead of waiting for timeout
- Self-healing: Automatically tests service recovery and closes circuit when healthy

### Circuit Breaker Pattern Explained
1. **CLOSED (normal)**: All requests go through. Track failures.
2. **Failure threshold exceeded**: Open circuit. Start timeout timer.
3. **OPEN (failing)**: Reject all requests immediately. Don't call external service.
4. **Timeout elapsed**: Transition to HALF_OPEN. Allow one test request.
5. **HALF_OPEN (testing)**: If request succeeds → CLOSED. If fails → OPEN again.

This prevents overwhelming a failing service while periodically checking for recovery.

### Why No External Circuit Breaker Library?
Per YAGNI principle in CLAUDE.md: "No unnecessary frameworks, libraries, or design patterns"
- Simple state machine is ~50 lines of code
- No need for complex libraries (pybreaker, circuitbreaker) for this use case
- Full control over behavior and easier to test

### Geocoding Service Choice
Using geopy with Nominatim (OpenStreetMap):
- Free, no API key required (good for MVP)
- Rate limited: 1 request/second (acceptable for backend geocoding)
- Good international coverage
- Can switch to Google Maps API later if needed (same geopy interface)

### Retry Strategy
Exponential backoff prevents overwhelming the service:
- 1s, 2s, 4s delays give service time to recover
- Only retry transient errors (timeouts), not permanent errors (invalid address)
- Max 3 attempts balances resilience with response time

### Testing with Mocks
Use `unittest.mock` to simulate geopy behavior:
- Mock successful geocoding: return (lat, long)
- Mock timeout: raise `GeocoderTimedOut`
- Mock invalid address: raise `GeocoderQueryError`
- Mock time.sleep to speed up tests
- Verify exact call counts to ensure retry/circuit breaker logic

### Integration with Location Model
This service is called during flyer creation (future epic):
1. User provides address in flyer form
2. Backend creates Location instance with address
3. Call `geocode_and_update_location(location)` before saving Flyer
4. If geocoding fails, reject flyer creation with error message

### Logging Strategy
Per minimal documentation principle:
- Log state transitions (CLOSED → OPEN, OPEN → HALF_OPEN)
- Log geocoding failures (address, error type)
- Don't log successful geocoding (clutters logs)
- Use appropriate log levels: INFO for state changes, WARNING for failures

## References
- geopy documentation: https://geopy.readthedocs.io/
- Circuit Breaker Pattern: https://martinfowler.com/bliki/CircuitBreaker.html
- geopy Nominatim: https://geopy.readthedocs.io/en/stable/#nominatim
- Python unittest.mock: https://docs.python.org/3/library/unittest.mock.html
- Project ARCHITECTURE.md for resilience principles
- Project CLAUDE.md for YAGNI and minimal dependencies
