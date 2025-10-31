---
id: m01-e07-t04
title: Location and Navigation Features E2E Validation
epic: m01-e07
milestone: m01
status: pending
---

# Task: Location and Navigation Features E2E Validation

## Context
Part of E2E Milestone Validation (No Mocks) (m01-e07) in Milestone 1: Anonymous Flyer Browsing (m01).

Validates location services and navigation features end-to-end: iOS location permission flow, distance calculations with real GPS coordinates, map navigation to Apple Maps with correct destinations, and creator profile navigation. All tests use real iOS location services and real geocoded addresses.

## Implementation Guide for LLM Agent

### Objective
Create comprehensive integration tests that validate location features work end-to-end: app requests location permission correctly, device provides real coordinates, distances are calculated accurately against backend geocoded locations, Apple Maps opens with correct destinations, and creator profile navigation works through the complete stack.

### Steps

1. **Create E2E location/navigation test file** in `pockitflyer_app/integration_test/location_navigation_test.dart`
   - Import setup from `setup.dart`
   - Use `setupE2ETests()` and `teardownE2ETests()`
   - Tag with `tags: ['e2e', 'tdd_red']` initially

2. **Test: Location permission request flow**
   - Launch app on iOS simulator/device with location permission not yet granted
   - Wait for location permission prompt (iOS system dialog)
   - Verify prompt appears with appropriate message
   - Grant "While Using App" permission
   - Verify app receives location permission granted
   - Verify feed updates to show distances
   - Take screenshot: `location_permission_granted.png`

3. **Test: Location permission denied handling**
   - Launch app and deny location permission
   - Verify distances are NOT shown on flyer cards
   - Verify proximity filter is disabled or hidden
   - Verify helpful message: "Enable location to see distances"
   - Verify no crashes or errors
   - Verify feed still loads and works (browsing without location)

4. **Test: Distance calculations with real GPS**
   - Launch app with location permission granted
   - Configure test location (e.g., 37.7749, -122.4194 - San Francisco)
   - Wait for feed to load with distances
   - Query backend API: `GET /api/flyers/?user_lat=37.7749&user_long=-122.4194`
   - For first 5 flyers, verify:
     - UI displays distance (e.g., "2.5 km away")
     - Distance matches backend calculation (within 0.1 km tolerance)
     - Distance is reasonable given test data locations
   - Verify distance format is correct (e.g., "X.X km away")

5. **Test: Distance updates when location changes**
   - Launch app with initial test location (Location A)
   - Record distances on first 3 flyers
   - Simulate location change (Location B, ~10km from A)
   - Wait for feed to refresh/update
   - Verify API call with new coordinates
   - Verify distances update to reflect new location
   - Verify distances changed by ~10km (some increase, some decrease)
   - Verify no crashes during location update

6. **Test: Map navigation opens Apple Maps with correct destination**
   - Launch app and wait for feed load
   - Find specific flyer with known location (from test data)
   - Tap "Navigate" or location button on flyer card
   - Verify Apple Maps app opens (check for app switch)
   - Verify destination coordinates match flyer's location (check Maps URL scheme)
   - Expected URL format: `maps.apple.com/?daddr=LAT,LONG` or `maps://?daddr=LAT,LONG`
   - Verify no errors during navigation

7. **Test: Map navigation with multiple flyers**
   - Launch app and navigate to 3 different flyers (sequentially)
   - For each flyer:
     - Tap location button
     - Verify Maps opens with correct destination
     - Return to app
   - Verify each destination is unique (coordinates differ)
   - Verify app returns correctly after each Maps launch

8. **Test: Creator profile navigation from flyer**
   - Launch app and wait for feed load
   - Find flyer from known creator (from test data)
   - Tap creator name or avatar on flyer card
   - Wait for creator profile to load
   - Verify API call: `GET /api/creators/{creator_id}/`
   - Verify profile displays:
     - Creator name (matches flyer)
     - Creator bio (from backend)
     - Creator avatar (loaded image)
   - Verify profile shows creator's flyers (list of FlyerCards)
   - Query API: `GET /api/flyers/?creator={creator_id}`
   - Verify profile flyer count matches API count
   - Take screenshot: `creator_profile.png`

9. **Test: Creator profile flyers are correct**
   - Navigate to creator profile (as above)
   - Query backend API for creator's flyers
   - Verify all flyers in profile match API response:
     - Same titles
     - Same categories
     - Same images
   - Verify flyers are sorted correctly (most recent first)
   - Tap flyer in creator profile to open detail
   - Verify detail view loads correctly

10. **Test: Back navigation from creator profile**
    - Navigate to creator profile from flyer in feed
    - Verify back button present
    - Tap back button
    - Verify return to feed (same scroll position)
    - Verify feed still shows all flyers (not filtered to creator)

11. **Test: Navigate to different creators**
    - Launch app and navigate to 3 different creator profiles (sequentially)
    - For each creator:
      - Tap creator on flyer
      - Verify correct profile loads (name matches)
      - Verify different flyers shown (not same list)
      - Go back to feed
    - Verify each profile is unique
    - Verify no data mixing between creators

12. **Test: Location unavailable fallback**
   - Configure simulator/device to disable GPS (airplane mode or location services off)
   - Launch app
   - Verify distances show "Location unavailable"
   - Verify proximity filter is disabled
   - Verify rest of app works (browsing, search, navigation to creators)
   - Verify no crashes

13. **Test: Distance calculations accuracy validation**
    - Query backend for flyer with known coordinates (from test data)
    - Calculate expected distance manually using Haversine formula
    - Compare UI distance, backend distance, manual calculation
    - Verify all three match within 0.5 km (acceptable tolerance)
    - Repeat for 5 flyers to ensure consistent accuracy

14. **Verify all tests and mark green**
    - Run all tests: `flutter test integration_test/location_navigation_test.dart`
    - Verify all tests pass
    - Check screenshots for visual confirmation
    - Review location logs for actual GPS usage
    - Change tag to `tags: ['e2e', 'tdd_green']`

### Acceptance Criteria
- [ ] Location permission flow works correctly on iOS [Test: fresh install, prompt appears, grant permission, distances appear]
- [ ] Location permission denied handled gracefully [Test: deny permission, verify distances hidden, proximity filter disabled]
- [ ] Distance calculations match backend with <0.5km tolerance [Test: compare UI vs API vs Haversine calculation]
- [ ] Distances update when user location changes [Test: change location, verify distances update]
- [ ] Map navigation opens Apple Maps with correct destination [Test: tap location button, verify Maps URL/app launch]
- [ ] Multiple flyer locations navigate to different destinations [Test: navigate to 3 flyers, verify unique coordinates]
- [ ] Creator profile loads from backend with correct data [Test: tap creator, verify API call, verify profile matches backend]
- [ ] Creator profile shows creator's flyers correctly [Test: compare profile flyers against API response]
- [ ] Back navigation from creator profile returns to feed [Test: profile → back → feed, verify scroll position]
- [ ] Multiple creator profiles show unique data [Test: navigate to 3 creators, verify different names/flyers]
- [ ] Location unavailable fallback works [Test: disable GPS, verify "Location unavailable" message]
- [ ] No crashes during location permission, GPS updates, or navigation [Test: review logs for exceptions]

### Files to Create/Modify
- `pockitflyer_app/integration_test/location_navigation_test.dart` - NEW: E2E location and navigation tests

### Testing Requirements
**Note**: This task creates E2E integration tests. These tests ARE the tests.

- **E2E integration tests**: All tests in location_navigation_test.dart validate real iOS location services, real GPS, real Maps integration, real API calls
- **No unit tests needed**: This task is integration testing, not unit testing

### Definition of Done
- [ ] Code written and all tests pass
- [ ] Tests use real iOS location services (verified in simulator/device)
- [ ] Distance calculations verified accurate (<0.5km tolerance)
- [ ] Apple Maps integration verified (Maps app opens with correct destinations)
- [ ] Creator profile navigation verified end-to-end
- [ ] Screenshots captured for permission and profile flows
- [ ] No mocks used anywhere (code review confirms)
- [ ] Changes committed with reference to task ID (m01-e07-t04)
- [ ] All tests marked `tdd_green` after passing
- [ ] Ready for m01-e07-t05 (error handling and performance E2E tests)

## Dependencies
- m01-e07-t01 (E2E test environment setup) - must be complete
- m01-e05 (Location Services) - must be complete
- m01-e06 (Creator Profiles) - must be complete
- Real backend with geocoded locations
- iOS simulator or device with location services
- Flutter integration_test package

## Technical Notes

### iOS Location Permission Testing
iOS location permissions require actual device/simulator:
- Simulator: Debug → Location → Custom Location to set test coordinates
- Device: Use real GPS or mock location via Xcode
- Permission prompt is iOS system dialog, not testable via WidgetTester
- Use `geolocator` package or similar for permission handling

### Location Simulation in Integration Tests
Flutter integration tests can configure location:
```dart
// In test setup
await IntegrationTestWidgetsFlutterBinding.ensureInitialized();
// Set test location (requires platform channel or package support)
await Geolocator.setMockLocation(37.7749, -122.4194);
```

### Distance Calculation Validation
Haversine formula for manual verification:
```
a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlong/2)
c = 2 * atan2(√a, √(1−a))
distance = R * c  (R = Earth radius = 6371 km)
```
Use this to verify backend calculations are correct

### Apple Maps URL Schemes
iOS supports multiple URL schemes for Maps:
- Modern: `https://maps.apple.com/?daddr=LAT,LONG`
- Legacy: `maps://?daddr=LAT,LONG`
Verify implementation uses one of these formats
Can verify URL by intercepting `url_launcher` calls in tests

### Creator Profile API Structure
Expected API endpoints:
- `GET /api/creators/{id}/` - Creator detail
- `GET /api/flyers/?creator={id}` - Creator's flyers
Verify these endpoints exist and return correct data

### Test Data Requirements
Tests assume test data from m01-e07-t01 includes:
- Flyers with geocoded coordinates (from geopy)
- Multiple creators (3-5) with multiple flyers each
- Locations spread across 0-50km from test coordinates
- Valid addresses that geocoded successfully

### Handling Timing Issues
Location services may have delays:
- Location permission prompt may take 1-2s to appear
- GPS fix may take 2-5s on device
- Maps app launch may take 1-2s
Use appropriate timeouts and `pumpAndSettle()` calls

### Location Permission States
iOS location permissions have multiple states:
- Not Determined: Permission not yet requested
- Restricted: Parental controls or MDM
- Denied: User denied permission
- Authorized Always: Full access
- Authorized When In Use: Access only when app is active
Tests should handle "When In Use" as the primary use case

### Creator Profile Navigation Patterns
Common navigation patterns:
- Feed → Creator Profile → Flyer Detail → Back → Back → Feed
- Feed → Flyer Detail → Creator Profile → Back → Back → Feed
Verify all patterns work and maintain state correctly

## References
- Flutter Geolocator package: https://pub.dev/packages/geolocator
- Flutter URL Launcher: https://pub.dev/packages/url_launcher
- Apple Maps URL Scheme: https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
- Haversine Formula: https://en.wikipedia.org/wiki/Haversine_formula
- Project CLAUDE.md for TDD markers
- Epic m01-e07 for E2E testing requirements
- m01-e07-t01 for E2E infrastructure setup
