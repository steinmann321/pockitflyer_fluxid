---
id: m04-e01-t08
epic: m04-e01
title: Create Address Input Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Address Input Widget

## Objective
Build Flutter widget for address input with validation, sending address to backend for geocoding.

## Acceptance Criteria
- [ ] Address TextField with placeholder "Enter address..."
- [ ] Required field validation
- [ ] Format guidance helper text
- [ ] Current location button (optional: use device GPS)
- [ ] No client-side geocoding (backend handles all geocoding)
- [ ] Error display for backend geocoding failures
- [ ] Clear error messages: "Address not found" vs "Service unavailable"
- [ ] Disabled state during geocoding validation
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Required field validation
- Address input and display
- Current location button (if implemented)
- Backend geocoding error handling
- Error message display (not found vs service error)
- Disabled state during validation
- Widget tests

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/address_input_widget.dart`
- `pockitflyer_app/lib/services/location_service.dart` (optional: GPS integration)
- `pockitflyer_app/test/widgets/address_input_widget_test.dart`

## Dependencies
- m04-e01-t01 (backend geocoding service)
- Optional: Flutter `geolocator` package for current location

## Notes
- Backend geocodes on flyer submission, not during input
- Helper text: "Street, City, State/Province, Country"
- Validation occurs on form submit, not real-time
- Geocoding errors returned from backend API
- Current location: reverse geocode GPS coordinates to address
- Consider autocomplete in future iterations
