---
id: m01-e05-t02
title: Location Tracking and Coordinate Retrieval
epic: m01-e05
milestone: m01
status: complete
---

# Task: Location Tracking and Coordinate Retrieval

## Context
Part of Location Services and Navigation (m01-e05) in Milestone 01 (m01).

Implements device location tracking to retrieve user's current coordinates for distance calculations and proximity filtering. This task builds on the permission service (m01-e05-t01) to provide reliable location data with error handling, accuracy validation, and efficient update mechanisms.

## Implementation Guide for LLM Agent

### Objective
Create location tracking service that retrieves user's current coordinates, monitors location updates, validates accuracy, and handles all error scenarios with proper fallbacks.

### Steps
1. Create location coordinate model
   - File: `pockitflyer_app/lib/models/user_location.dart`
   - Class: `UserLocation`
   - Fields:
     - `double latitude`
     - `double longitude`
     - `double accuracy` (in meters)
     - `DateTime timestamp`
     - `bool isMocked` (for simulator detection)
   - Methods:
     - `bool get isAccurate` - returns true if accuracy ≤ 100 meters
     - `Duration get age` - time since location was obtained
     - `bool get isStale` - returns true if older than 5 minutes
     - `factory UserLocation.fromGeolocatorPosition(Position position)` - converter
     - `toJson()` / `fromJson()` for serialization

2. Create location tracking service
   - File: `pockitflyer_app/lib/services/location_tracking_service.dart`
   - Class: `LocationTrackingService`
   - Dependencies: `LocationPermissionService` (from m01-e05-t01)
   - Methods:
     - `Future<UserLocation?> getCurrentLocation()` - single location fetch
     - `Stream<UserLocation> get locationStream` - continuous updates
     - `Future<void> startTracking()` - begin location monitoring
     - `Future<void> stopTracking()` - stop location monitoring
     - `UserLocation? get lastKnownLocation` - cached location
     - `bool get isTracking` - tracking state

3. Implement location retrieval with retry logic
   - Use `geolocator.getCurrentPosition()` with settings:
     - `desiredAccuracy: LocationAccuracy.high` (iOS kCLLocationAccuracyBest)
     - `timeLimit: Duration(seconds: 10)` (timeout)
   - Retry mechanism:
     - First attempt: high accuracy, 10s timeout
     - Second attempt (if failed): medium accuracy, 15s timeout
     - Third attempt (if failed): low accuracy, 20s timeout
     - After 3 failures: return null and emit error
   - Exponential backoff between retries: 2s, 4s, 8s
   - Check permission before each retrieval attempt
   - Cache last successful location (survives retries)

4. Implement location stream with smart updates
   - Use `geolocator.getPositionStream()` with settings:
     - `accuracy: LocationAccuracy.high`
     - `distanceFilter: 50` (update only if moved ≥50 meters)
     - `timeInterval: Duration(minutes: 1)` (max update frequency)
   - Only emit location if:
     - Accuracy is better than previous location OR
     - Position changed by ≥50 meters OR
     - Location is stale (>5 minutes old)
   - Automatically request permission if not granted
   - Handle permission changes (stream stops if denied)

5. Implement error handling and edge cases
   - Create error types:
     - `LocationPermissionDenied` - no permission
     - `LocationServicesDisabled` - GPS/location services off
     - `LocationTimeout` - retrieval timed out
     - `LocationAccuracyInsufficient` - accuracy too poor (>500m)
   - Handle each error with specific user message
   - Detect simulator/mock locations using `position.isMocked`
   - Provide fallback behavior:
     - If permission denied: return null, don't crash
     - If timeout: return last known location if available
     - If GPS disabled: prompt user to enable in Settings

6. Implement background tracking management
   - Track app lifecycle state
   - Pause location stream when app in background (battery optimization)
   - Resume location stream when app returns to foreground
   - Save last location to cache before pausing
   - Reload cached location on resume

7. Create comprehensive test suite
   - File: `pockitflyer_app/test/models/user_location_test.dart`
   - Unit tests for UserLocation model:
     - Test: `isAccurate` returns true for ≤100m accuracy
     - Test: `isStale` returns true for >5 minute old locations
     - Test: `age` calculation is correct
     - Test: fromGeolocatorPosition converts correctly
     - Test: JSON serialization round-trip

   - File: `pockitflyer_app/test/services/location_tracking_service_test.dart`
   - Unit tests for LocationTrackingService:
     - Test: `getCurrentLocation` returns valid location when permission granted
     - Test: `getCurrentLocation` returns null when permission denied
     - Test: Retry logic attempts 3 times with decreasing accuracy
     - Test: Exponential backoff delays between retries (2s, 4s, 8s)
     - Test: `locationStream` emits updates when position changes ≥50m
     - Test: `locationStream` filters updates if accuracy is worse
     - Test: `locationStream` emits if location is stale (>5 min)
     - Test: `startTracking` requests permission if not granted
     - Test: `stopTracking` cancels location stream
     - Test: Last known location cached and returned on timeout
     - Test: Background/foreground lifecycle pauses/resumes tracking
   - Mock `geolocator` package and `LocationPermissionService`

8. Add location tracking to dependency injection
   - File: `pockitflyer_app/lib/services/service_locator.dart` (create if doesn't exist)
   - Register `LocationTrackingService` as singleton
   - Inject `LocationPermissionService` dependency
   - Provide access method: `getIt<LocationTrackingService>()`

### Acceptance Criteria
- [ ] Service retrieves current location with coordinates and accuracy [Test: call getCurrentLocation, verify latitude/longitude/accuracy]
- [ ] Retry logic attempts 3 times with decreasing accuracy requirements [Test: mock failures, verify 3 attempts]
- [ ] Location stream emits updates only when moved ≥50m or stale [Test: mock position changes, verify filtering]
- [ ] Permission denial handled gracefully (returns null, no crash) [Test: mock denied permission, call getCurrentLocation]
- [ ] Timeout returns last known location if available [Test: mock timeout, verify cached location returned]
- [ ] Location tracking pauses in background, resumes in foreground [Test: simulate app lifecycle, verify tracking state]
- [ ] Location accuracy validated (≤100m for `isAccurate`) [Test: create locations with various accuracies]
- [ ] Location staleness detected (>5 min for `isStale`) [Test: create old location, verify isStale]
- [ ] Tests pass with ≥85% coverage [Test: run flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/models/user_location.dart` - NEW: location coordinate model
- `pockitflyer_app/lib/services/location_tracking_service.dart` - NEW: tracking service
- `pockitflyer_app/lib/services/service_locator.dart` - NEW or MODIFY: register service
- `pockitflyer_app/test/models/user_location_test.dart` - NEW: model tests
- `pockitflyer_app/test/services/location_tracking_service_test.dart` - NEW: service tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - UserLocation model: accuracy validation, staleness detection, age calculation, JSON serialization
  - LocationTrackingService: getCurrentLocation with mocked geolocator responses
  - Retry logic: verify 3 attempts, exponential backoff timing
  - Error handling: permission denied, timeout, GPS disabled, insufficient accuracy
  - Location filtering: distance-based, accuracy-based, staleness-based

- **Integration tests**:
  - Full location retrieval workflow with mocked permission service
  - Location stream with simulated position changes over time
  - Background/foreground lifecycle with tracking state transitions
  - Caching and cache retrieval on failures

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (TDD markers, minimal docs)
- [ ] No console errors or warnings
- [ ] Location retrieval handles all error scenarios
- [ ] Retry logic with exponential backoff implemented
- [ ] Location stream filters redundant updates
- [ ] Background tracking management implemented
- [ ] Changes committed with reference to task ID (m01-e05-t02)
- [ ] Ready for distance calculation service (m01-e05-t03) to use

## Dependencies
- Requires: m01-e05-t01 (LocationPermissionService for authorization checks)
- Blocks: m01-e05-t03 (distance calculations need user coordinates)

## Technical Notes
**iOS Location Accuracy Levels** (mapped to geolocator):
- `LocationAccuracy.high` → kCLLocationAccuracyBest (~5-10m)
- `LocationAccuracy.medium` → kCLLocationAccuracyNearestTenMeters (~10m)
- `LocationAccuracy.low` → kCLLocationAccuracyHundredMeters (~100m)

**Distance Filter Strategy**:
- 50m threshold balances accuracy vs battery usage
- Prevents excessive updates when user is stationary
- iOS will wake app for significant location changes even in background (if configured)

**Location Staleness**:
- 5-minute threshold chosen for flyer discovery use case
- User's location unlikely to change significantly in 5 minutes for browsing
- Refresh location before critical operations (proximity filtering)

**Simulator Detection**:
- iOS simulator returns `isMocked: true` for simulated locations
- Useful for debugging and testing
- Production app should work with mocked locations (simulators)

**Caching Strategy**:
- Cache last valid location in memory (not persistent storage)
- Use cached location as fallback on timeout/error
- Clear cache on permission revocation

**Battery Optimization**:
- Pause tracking when app in background (no "Always" permission needed)
- Use `distanceFilter` to reduce unnecessary updates
- Set reasonable `timeInterval` to limit update frequency

**Error Messages for Users**:
- Permission denied: "Enable location access in Settings to see nearby flyers"
- GPS disabled: "Turn on Location Services in Settings to use this feature"
- Timeout: "Unable to determine location. Please try again."
- Insufficient accuracy: "Location accuracy is too low. Move to an open area."

## References
- geolocator API: https://pub.dev/documentation/geolocator/latest/
- iOS Location Accuracy: https://developer.apple.com/documentation/corelocation/cllocationaccuracy
- Flutter App Lifecycle: https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html
- Haversine Distance Formula: https://en.wikipedia.org/wiki/Haversine_formula (for m01-e05-t03)
