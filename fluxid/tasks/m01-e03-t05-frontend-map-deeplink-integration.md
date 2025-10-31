---
id: m01-e03-t05
epic: m01-e03
title: Implement Map Deep Link Integration for iOS
status: pending
priority: medium
tdd_phase: red
---

# Task: Implement Map Deep Link Integration for iOS

## Objective
Enable users to tap flyer location information and seamlessly open the location in iOS Maps app with correct coordinates for navigation, using iOS URL schemes.

## Acceptance Criteria
- [ ] Location section in detail screen is tappable
- [ ] Tap opens iOS Maps with correct coordinates
- [ ] Maps shows pin at flyer location
- [ ] URL scheme uses format: `maps://?q={latitude},{longitude}`
- [ ] Graceful error handling if Maps can't be opened
- [ ] Visual indicator that location is tappable (icon, color, etc.)
- [ ] Coordinates passed accurately (no precision loss)
- [ ] Edge cases handled: invalid coordinates, permission issues
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Valid coordinates generate correct Maps URL
- url_launcher can launch Maps URL (mock/stub)
- Invalid coordinates handled gracefully
- Error handling when Maps unavailable (unlikely on iOS)
- Visual feedback on tap (button state/animation)
- Coordinates at boundaries (poles, date line)
- Null/missing coordinate handling

## Files to Modify/Create
- `pockitflyer_app/lib/screens/flyer_detail_screen.dart` (add location tap handler)
- `pockitflyer_app/lib/services/map_launcher_service.dart` (encapsulate deep link logic)
- `pockitflyer_app/test/screens/flyer_detail_screen_test.dart` (tap behavior)
- `pockitflyer_app/test/services/map_launcher_service_test.dart`
- `pockitflyer_app/pubspec.yaml` (add url_launcher dependency)

## Dependencies
- Task m01-e03-t04 (detail screen must exist)
- url_launcher Flutter package

## Notes
- Use `url_launcher` package for opening external URLs
- iOS Maps URL scheme: `maps://?q={lat},{lng}` (Apple Maps on iOS)
- Alternative format for labels: `maps://?q={label}&ll={lat},{lng}` (could use flyer title)
- Check `canLaunchUrl` before `launchUrl` for graceful error handling
- Visual design: location section could have map pin icon, underline, or distinct background
- Coordinate precision: use full precision from backend (no rounding)
- Consider adding haptic feedback on successful launch (minor UX enhancement)
