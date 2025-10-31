---
id: m01-e05
title: Location Services and Navigation
milestone: m01
status: pending
tasks:
  - m01-e05-t01
  - m01-e05-t02
  - m01-e05-t03
  - m01-e05-t04
---

# Epic: Location Services and Navigation

## Overview
Integrates device location services to enable proximity-based features and provides native map navigation for flyer locations. This epic handles all location-related functionality including permissions, distance calculations, and external map app integration.

## Scope
- iOS location permissions request and handling
- Device location tracking for proximity features
- Distance calculation from user location to flyer locations
- Distance formatting and display (meters/kilometers)
- Native map app integration (Apple Maps)
- Location error handling and fallback states
- Accuracy validation for distance calculations

## Success Criteria
- [ ] App requests location permission on appropriate trigger [Test: first launch, permission dialog, user choice handling]
- [ ] Location permission states are handled correctly [Test: granted, denied, restricted, not determined, changed in settings]
- [ ] Distance calculations are accurate within acceptable margin (<1% error) [Test: various coordinate pairs, short distances, long distances, same location]
- [ ] Distance displays in appropriate units (meters for <1km, kilometers for ≥1km) [Test: boundary conditions, very short distances, very long distances, formatting]
- [ ] "Near Me" proximity filter uses accurate user location [Test: location updates, movement during session, location unavailable]
- [ ] Location button on flyer card opens native map app [Test: iOS Maps launch, correct destination, address accuracy, error handling]
- [ ] Map app opens with correct destination coordinates [Test: various addresses, coordinate accuracy, international locations]
- [ ] UI handles location errors gracefully [Test: permission denied, location unavailable, GPS disabled, timeout]
- [ ] Location permission can be changed and app responds [Test: user changes permission in settings, app updates behavior]
- [ ] Performance impact of location tracking is minimal [Test: battery usage, background location, update frequency]

## Tasks
- iOS location permissions request and state handling (m01-e05-t01)
- Location tracking and coordinate retrieval (m01-e05-t02)
- Distance calculation utilities and formatting (m01-e05-t03)
- Native map app integration (Apple Maps URL scheme) (m01-e05-t04)

## Dependencies
- m01-e01 (Backend Flyer API) - flyers include geocoordinates from backend
- m01-e02 (Core Feed Display) - distance shown on flyer cards
- iOS platform location services
- Apple Maps (native map app)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
Location services are critical for the proximity-based value proposition of PokitFlyer. Users discover "local" flyers based on their physical location.

**Key Technical Decisions:**
- Request location permission when needed (not on launch)
- Use "When In Use" location permission (not "Always")
- Backend provides geocoordinates (no in-app geocoding)
- Distance calculation using Haversine formula
- Open Apple Maps using URL scheme (standard iOS pattern)

**Location Permission Strategy:**
- Request permission when user first interacts with location feature (proximity filter or viewing distances)
- Provide clear rationale in permission dialog
- Handle all permission states gracefully
- Allow app to function without location (no distances shown, proximity filter disabled)

**Distance Calculation:**
- Use Haversine formula for great-circle distance
- Calculate distance between user coordinates and flyer coordinates
- Format: meters for <1000m, kilometers with 1 decimal for ≥1km
- Update distances when user location changes significantly

**Map Integration:**
- Use Apple Maps URL scheme for iOS
- Pass flyer address or coordinates as destination
- Handle errors if Maps app unavailable (shouldn't happen on iOS)
- Provide visual feedback when launching external app

**Error Handling:**
- Location permission denied: hide distances, disable proximity filter
- Location unavailable: show flyers without distances
- GPS disabled: prompt user to enable in settings
- Timeout: retry with exponential backoff
