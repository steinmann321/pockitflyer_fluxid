---
id: m01-e01-t05
epic: m01-e01
title: Implement iOS Location Permission and Service
status: completed
priority: high
tdd_phase: green
---

# Task: Implement iOS Location Permission and Service

## Objective
Create Flutter service to request and manage iOS location permissions and retrieve device location.

## Acceptance Criteria
- [x] LocationService class with methods: `requestPermission()`, `getLocation()`, `getPermissionStatus()`
- [x] iOS Info.plist entries: NSLocationWhenInUseUsageDescription with user-friendly text
- [x] Permission states: granted, denied, notDetermined, disabled (location services off)
- [x] Graceful handling of all permission states
- [x] Fallback behavior when permission denied: use default location (0.0, 0.0) or show user message
- [x] Location accuracy: best for navigation (kCLLocationAccuracyBest)
- [x] Caching: location cached for 5 minutes to reduce battery drain
- [x] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Permission request flow for all states (granted, denied, notDetermined, disabled)
- Location retrieval success and failure scenarios
- Cache behavior (fresh vs. stale location)
- Error handling for location services disabled
- Mock CoreLocation framework (no actual GPS in tests)

## Files to Modify/Create
- `pockitflyer_app/lib/services/location_service.dart`
- `pockitflyer_app/ios/Runner/Info.plist` (add permission keys)
- `pockitflyer_app/test/services/location_service_test.dart`
- `pockitflyer_app/pubspec.yaml` (add geolocator or location package)

## Dependencies
- External: Flutter location package (geolocator or location)
- iOS: CoreLocation framework

## Notes
- Request permission on first feed load attempt
- Show permission rationale before requesting if best practice
- Location permission is when-in-use only (not always)
- Default location (0.0, 0.0) if permission denied - feed still works but shows global flyers
- Cache prevents excessive GPS usage during feed refresh
