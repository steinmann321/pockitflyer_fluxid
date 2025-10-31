---
id: m01-e07-t04
title: Location and Navigation Features E2E Validation
epic: m01-e07
milestone: m01
status: pending
---

# Task: Location and Navigation Features E2E Validation

## Context
Part of E2E Milestone Validation (m01-e07) in Milestone 01 (m01).

Validates iOS location permissions, GPS acquisition, distance calculations, and Apple Maps navigation end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create an E2E test validating location and navigation using real device/simulator services and backend data.

### Steps

1. Create E2E test file
   - Path: `pockitflyer_app/integration_test/location_navigation_test.dart`
   - Import: `integration_test`, `flutter_test`, app entry, `geolocator`, `test_config.dart`, `helpers/test_helpers.dart`
   - Setup binding and test group per project conventions

2. Implement scenarios
   - Test: 'iOS location permission request and grant/deny handling'
   - Test: 'Real GPS location acquisition on device/simulator'
   - Test: 'Distances display using geocoded data'
   - Test: 'Open in Apple Maps with correct destination'

3. Utilities and cleanup
   - Use helpers; ensure tests cleanly handle permission state resets

### Acceptance Criteria
- [ ] Permission flow handled gracefully [Verify: UI state reflects permission]
- [ ] GPS coordinates acquired [Verify: valid lat/lon]
- [ ] Distances accurate within tolerance [Verify: realistic values]
- [ ] Apple Maps opens with correct destination [Verify: coordinates]

### Files to Create/Modify
- `pockitflyer_app/integration_test/location_navigation_test.dart` – NEW
- `pockitflyer_app/integration_test/helpers/test_helpers.dart` – MODIFY (add location helpers)

### Testing Requirements
- Real device/simulator; backend running; no mocks.

### Definition of Done
- [ ] All location/navigation tests pass
- [ ] Evidence captured (screenshots/logs)
- [ ] Changes committed with reference to m01-e07-t04

## Dependencies
- Requires: m01-e07-t01 (E2E environment setup)

## Technical Notes
- Simulator may require Network Link Conditioner for throttling scenarios

## References
- Integration test docs under `pockitflyer_app/integration_test/`

