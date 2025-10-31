---
id: m01-e05-t01
title: iOS Location Permissions Request and State Handling
epic: m01-e05
milestone: m01
status: pending
---

# Task: iOS Location Permissions Request and State Handling

## Context
Part of Location Services and Navigation (m01-e05) in Milestone 01 (m01).

Implements iOS location permission request flow with proper state handling for all permission states (not determined, granted, denied, restricted, changed in settings). This task sets up the foundation for all location-based features by managing user authorization.

## Implementation Guide for LLM Agent

### Objective
Create iOS location permission service that requests "When In Use" authorization, tracks permission state changes, and provides clean API for other services to check/request permissions.

### Steps
1. Add location permission dependencies to pubspec.yaml
   - Add `geolocator: ^13.0.1` (handles iOS permissions)
   - Add `permission_handler: ^11.3.1` (for detailed permission state)
   - Run `flutter pub get`

2. Configure iOS Info.plist for location permissions
   - File: `pockitflyer_app/ios/Runner/Info.plist`
   - Add `NSLocationWhenInUseUsageDescription` key with rationale
   - Value: "PokitFlyer needs your location to show nearby flyers and calculate distances to local businesses."
   - Add `NSLocationUsageDescription` key (fallback for older iOS)
   - Same value as above

3. Create location permission service
   - File: `pockitflyer_app/lib/services/location_permission_service.dart`
   - Class: `LocationPermissionService`
   - Methods:
     - `Future<LocationPermissionStatus> checkPermissionStatus()` - returns current state
     - `Future<LocationPermissionStatus> requestPermission()` - requests "When In Use" permission
     - `Stream<LocationPermissionStatus> get permissionStatusStream` - notifies on changes
   - Use `permission_handler` package for iOS permission checks
   - Use `geolocator` package for location service checks

4. Define permission status enum
   - File: `pockitflyer_app/lib/models/location_permission_status.dart`
   - Enum: `LocationPermissionStatus`
   - Values: `notDetermined`, `granted`, `denied`, `restricted`, `deniedForever`
   - Map from `permission_handler.PermissionStatus` to custom enum
   - Include helper methods:
     - `bool get isAuthorized` - returns true for `granted`
     - `bool get canRequest` - returns true for `notDetermined` or `denied` (not `deniedForever`)
     - `String get userMessage` - user-friendly message for each state

5. Implement permission state change detection
   - Use `AppLifecycleState` to detect when app returns from settings
   - Re-check permission status on app resume
   - Emit new status to `permissionStatusStream`
   - Handle iOS-specific permission state transitions

6. Create comprehensive test suite
   - File: `pockitflyer_app/test/services/location_permission_service_test.dart`
   - Mock `permission_handler` and `geolocator` packages
   - Unit tests:
     - Test: `checkPermissionStatus` returns correct status for each iOS state
     - Test: `requestPermission` returns granted when user approves
     - Test: `requestPermission` returns denied when user denies
     - Test: `requestPermission` returns deniedForever when user denies with "Don't Ask Again"
     - Test: Permission stream emits changes when app resumes from settings
     - Test: `canRequest` returns false for `deniedForever`, true for `notDetermined`
   - Widget tests for permission rationale dialog (if implemented)

7. Create permission request helper widget (optional but recommended)
   - File: `pockitflyer_app/lib/widgets/location_permission_prompt.dart`
   - Shows rationale before requesting permission
   - Provides "Open Settings" button for `deniedForever` state
   - Uses iOS-native alert style

### Acceptance Criteria
- [ ] App can check current location permission status [Test: call checkPermissionStatus for all iOS states]
- [ ] App can request "When In Use" location permission [Test: trigger request, verify iOS dialog appears]
- [ ] Permission status correctly reflects all iOS states [Test: notDetermined, granted, denied, restricted, deniedForever]
- [ ] Permission changes in Settings are detected [Test: deny in Settings, resume app, verify status updates]
- [ ] Service provides stream of permission state changes [Test: listen to stream, change permission, verify emission]
- [ ] Info.plist contains required location permission keys [Test: read Info.plist, verify keys exist]
- [ ] User-friendly messages provided for each permission state [Test: verify userMessage for each status]
- [ ] Tests pass with ≥85% coverage [Test: run flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/pubspec.yaml` - ADD: geolocator, permission_handler dependencies
- `pockitflyer_app/ios/Runner/Info.plist` - ADD: NSLocationWhenInUseUsageDescription, NSLocationUsageDescription
- `pockitflyer_app/lib/models/location_permission_status.dart` - NEW: permission status enum
- `pockitflyer_app/lib/services/location_permission_service.dart` - NEW: permission service
- `pockitflyer_app/lib/widgets/location_permission_prompt.dart` - NEW (optional): permission prompt widget
- `pockitflyer_app/test/services/location_permission_service_test.dart` - NEW: service tests
- `pockitflyer_app/test/widgets/location_permission_prompt_test.dart` - NEW (optional): widget tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - LocationPermissionService methods with mocked platform packages
  - LocationPermissionStatus enum helpers (isAuthorized, canRequest, userMessage)
  - Permission state mapping from platform to custom enum
  - App lifecycle permission re-check logic

- **Widget tests**:
  - LocationPermissionPrompt rendering for each permission state
  - "Open Settings" button interaction
  - Permission request flow trigger

- **Integration tests**:
  - Full permission request workflow (mock platform response)
  - Permission change detection on app resume
  - Stream emissions on state changes

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (TDD markers, minimal docs)
- [ ] No console errors or warnings
- [ ] Info.plist configured correctly
- [ ] Permission states handle all iOS edge cases
- [ ] Changes committed with reference to task ID (m01-e05-t01)
- [ ] Ready for location tracking service (m01-e05-t02) to use

## Dependencies
- None (foundational task)
- Blocks: m01-e05-t02 (location tracking requires permission)

## Technical Notes
**iOS Permission States**:
- `notDetermined`: User hasn't been asked yet (can request)
- `granted`: User approved "When In Use" access
- `denied`: User denied permission (can re-request)
- `restricted`: Parental controls or enterprise policy (cannot request)
- `deniedForever`: User denied and selected "Don't Ask Again" (can only open Settings)

**Permission Request Strategy**:
- Request permission when user first interacts with location feature (not on app launch)
- Provide clear rationale before requesting (iOS best practice)
- For `deniedForever`, provide "Open Settings" button using `AppSettings.openAppSettings()`

**App Lifecycle Handling**:
- iOS does NOT provide automatic notification when permission changes in Settings
- Must check permission status when app returns to foreground
- Use `WidgetsBindingObserver.didChangeAppLifecycleState` to detect app resume

**Testing with Mocks**:
- Use `mockito` or manual mocks for `permission_handler` and `geolocator`
- Cannot test actual iOS permission dialogs in unit tests (requires E2E)
- Focus on logic: correct status mapping, state transitions, stream emissions

**Package Choice Rationale**:
- `geolocator`: Standard Flutter location package, handles iOS permissions
- `permission_handler`: More detailed permission state info, settings integration

## References
- iOS Location Permission Guide: https://developer.apple.com/documentation/corelocation/requesting_authorization_to_use_location_services
- geolocator package: https://pub.dev/packages/geolocator
- permission_handler package: https://pub.dev/packages/permission_handler
- Flutter App Lifecycle: https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html
