---
id: m01-e05-t08
epic: m01-e05
title: E2E Test - Error Handling with Actual Service Failures (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Error Handling with Actual Service Failures (No Mocks)

## Objective
Validate robust error handling across all M01 workflows by testing with actual service failures including geocoding timeouts, network disconnections, location permission denials, and empty database states without mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_error_handling.yaml`
- [ ] Error scenario tests:
  1. **Geocoding Service Failure**:
     - Configure backend geocoding with timeout (e.g., 1 second)
     - Seed flyer with address that takes >1 second to geocode (simulate slow response)
     - Assert: circuit breaker activates, fallback behavior triggered
     - Assert: flyer still saved with null coordinates, app shows error indicator
     - Assert: retry mechanism works (subsequent geocoding attempt succeeds)
  2. **Network Disconnection**:
     - Launch app, load feed (cached data)
     - Disable network (iOS Airplane Mode or Network Link Conditioner)
     - Pull-to-refresh
     - Assert: network error UI displayed ("No internet connection")
     - Assert: cached data still visible (graceful degradation)
     - Assert: retry button shown
     - Re-enable network, tap retry
     - Assert: feed refreshes successfully
  3. **Location Permission Denied**:
     - Launch app (fresh install)
     - Deny location permission
     - Assert: permission denied UI shown
     - Assert: feed loads with default sorting (not distance-based)
     - Assert: "Near Me" filter disabled/hidden
     - Assert: re-request permission button shown
     - Tap re-request, grant permission
     - Assert: feed reloads with distance calculations
  4. **Empty Database**:
     - Start backend with 0 flyers in database
     - Launch app
     - Assert: empty state UI displayed ("No flyers in your area yet")
     - Assert: pull-to-refresh works (no crash on empty results)
     - Add flyer via backend
     - Pull-to-refresh
     - Assert: new flyer appears (empty state → data state transition)
  5. **Backend Unavailable**:
     - Launch app with cached data
     - Stop backend server
     - Navigate to profile (requires API call)
     - Assert: network error UI displayed
     - Assert: retry button shown
     - Start backend server
     - Tap retry
     - Assert: profile loads successfully
  6. **Invalid Image URLs**:
     - Seed flyer with broken image URL (404)
     - Launch app, navigate to flyer detail
     - Assert: placeholder image shown (no crash)
     - Assert: error logged (for debugging)
  7. **Malformed API Response**:
     - Configure backend to return invalid JSON (simulate server error)
     - Launch app
     - Assert: error UI displayed ("Something went wrong")
     - Assert: no crash, no blank screen
     - Fix backend, retry
     - Assert: recovers successfully
  8. **Database Query Timeout**:
     - Seed database with complex data causing slow query (>2 seconds)
     - Apply filter triggering slow query
     - Assert: loading indicator shown (not frozen UI)
     - Assert: timeout error after 5 seconds
     - Assert: retry option available
  9. **Location Services Disabled** (iOS Setting):
     - Disable location services globally (iOS Settings)
     - Launch app
     - Assert: location disabled UI shown
     - Assert: feed loads without distances
     - Assert: prompt to enable location in Settings
  10. **Memory Pressure**:
     - Trigger iOS memory warning (simulate low memory)
     - Assert: app doesn't crash
     - Assert: image caches cleared to free memory
     - Assert: feed reloads correctly after warning
- [ ] Error recovery validations:
  - All errors show user-friendly messages (no stack traces, no technical jargon)
  - All errors provide retry/recovery option (button or pull-to-refresh)
  - Cached data preserved during errors (graceful degradation)
  - State restored correctly after error recovery
- [ ] Error logging validations:
  - All errors logged to backend (for debugging)
  - Error logs include context (user action, timestamp, device info)
  - No sensitive data in error logs (no user location, no passwords)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Geocoding service: timeout, network error, invalid response, circuit breaker
- Network errors: disconnection, timeout, DNS failure, SSL error
- Location permissions: denied, not determined, restricted (parental controls), globally disabled
- Database states: empty, large (slow queries), corrupted data
- Backend failures: server down, 500 errors, malformed responses, rate limiting
- Image loading: 404, timeout, invalid format, corrupted file
- API errors: 400 (bad request), 401 (unauthorized), 403 (forbidden), 404 (not found), 500 (server error)
- iOS system: low memory, background termination, permission changes while app running
- Recovery mechanisms: retry, pull-to-refresh, permission re-request, cache fallback

## Files to Modify/Create
- `maestro/flows/m01-e05/error_geocoding_failure.yaml`
- `maestro/flows/m01-e05/error_network_disconnection.yaml`
- `maestro/flows/m01-e05/error_location_permission_denied.yaml`
- `maestro/flows/m01-e05/error_empty_database.yaml`
- `maestro/flows/m01-e05/error_backend_unavailable.yaml`
- `maestro/flows/m01-e05/error_invalid_images.yaml`
- `maestro/flows/m01-e05/error_malformed_responses.yaml`
- `maestro/flows/m01-e05/error_recovery_all_scenarios.yaml`
- `pockitflyer_backend/scripts/simulate_geocoding_timeout.py`
- `pockitflyer_backend/scripts/simulate_server_errors.py`

## Dependencies
- m01-e05-t01 (E2E test data infrastructure)
- m01-e01-t03 (geocoding service with circuit breaker)
- All previous E2E workflow tests (t02-t07)

## Notes
**Critical: REAL SERVICE FAILURES**
- Actual geocoding timeouts (not mocked)
- Actual network disconnections (iOS Airplane Mode or Network Link Conditioner)
- Actual location permission flows (iOS system dialogs)
- Actual backend server stop/start
- Actual database empty state (0 records)

**Geocoding Circuit Breaker Testing**:
- Circuit breaker pattern: after N failures, stop calling geocoding service
- Test sequence:
  1. Configure geocoding timeout: 1 second
  2. Seed 5 flyers with slow-geocoding addresses
  3. Backend attempts geocoding on flyer creation
  4. First 3 failures: circuit breaker still closed (retries)
  5. After 3 failures: circuit breaker opens (stops calling geopy)
  6. Flyers 4-5: saved with null coordinates (circuit open, no geocoding attempted)
  7. Wait circuit breaker timeout (e.g., 30 seconds)
  8. Circuit breaker half-open: next flyer triggers retry
  9. If geocoding succeeds: circuit breaker closes (normal operation resumed)

**Network Error Simulation**:
- Method 1: iOS Airplane Mode (complete disconnection)
- Method 2: Network Link Conditioner (100% packet loss)
- Method 3: Stop backend server (specific API failures)
- Test each method to ensure all error paths covered

**Location Permission Flows** (iOS):
- **Not Determined**: First launch, no permission requested yet
  - App should request permission on first use
- **Denied**: User explicitly denied
  - Show error UI with "Settings" button
- **Restricted**: Parental controls prevent location access
  - Show error UI (can't change permission)
- **Authorized When In Use**: Permission granted
  - App can use location (normal operation)
- **Globally Disabled**: Location services off in iOS Settings
  - Show error UI with "Settings" button

**Error Message Guidelines**:
- User-friendly language (no technical jargon)
- Clear actionable steps ("Tap retry", "Enable location in Settings")
- No stack traces visible to user (logged for debugging only)
- Consistent error UI across all error types (same styling, same patterns)

**Example Error Messages**:
- Geocoding failure: "Unable to calculate distance. Showing flyers without distance."
- Network error: "No internet connection. Showing cached flyers."
- Location denied: "Location permission required to show nearby flyers. Tap to enable in Settings."
- Empty database: "No flyers in your area yet. Check back soon!"
- Backend unavailable: "Unable to connect to server. Please try again."
- Invalid image: "Image not available"

**Error Logging**:
- All errors logged to backend (if network available)
- Log structure:
  ```json
  {
    "error_type": "geocoding_timeout",
    "timestamp": "2025-01-15T10:30:00Z",
    "user_id": null,  // Anonymous in M01
    "device_info": "iOS 17.2, iPhone 14 Simulator",
    "context": "Creating flyer with address '123 Slow St, Zurich'",
    "error_message": "Geocoding timeout after 1 second"
  }
  ```
- No sensitive data: no user location coordinates, no user input, no tokens

**Recovery Testing**:
- Every error scenario must have recovery test:
  1. Trigger error
  2. Verify error UI displayed
  3. Fix underlying issue (re-enable network, start backend, etc.)
  4. Trigger recovery (retry button, pull-to-refresh, re-request permission)
  5. Verify app returns to normal operation
  6. Verify state preserved correctly (no data loss)

**Memory Pressure Simulation** (iOS):
- Use Xcode Memory Debug tool to trigger warning
- Alternatively: load many large images to naturally trigger memory pressure
- Test that app responds correctly:
  - Clears image caches
  - Releases unused resources
  - Doesn't crash
  - Reloads data when memory available again

**API Error Status Codes**:
- 400 Bad Request: Invalid filter parameters → show "Invalid filter" error
- 401 Unauthorized: Not relevant for M01 (anonymous), but prepare for M02
- 403 Forbidden: Rate limiting → show "Too many requests, please wait"
- 404 Not Found: Flyer/user deleted → show "Content not found"
- 500 Server Error: Backend crash → show "Server error, please try again"
- 503 Service Unavailable: Backend maintenance → show "Service temporarily unavailable"
