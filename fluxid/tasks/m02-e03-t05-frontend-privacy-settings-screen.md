---
id: m02-e03-t05
epic: m02-e03
title: Create Privacy Settings Screen UI
status: pending
priority: high
tdd_phase: red
---

# Task: Create Privacy Settings Screen UI

## Objective
Build Flutter privacy settings screen with email contact permission toggle and clear explanatory text. Screen is accessible from user profile page and provides simple, uncluttered UI following iOS design patterns.

## Acceptance Criteria
- [ ] Privacy settings screen with app bar and back button
- [ ] Email contact permission toggle (on/off switch)
- [ ] Clear explanatory text: "Allow other users to contact me via email"
- [ ] Toggle reflects current privacy settings state
- [ ] Toggle updates optimistically on interaction
- [ ] Error message displayed if update fails
- [ ] Loading indicator during initial load
- [ ] Screen follows iOS design guidelines (Cupertino widgets)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Screen renders with loading state initially
- Screen renders toggle with correct state after load
- Toggle can be switched on and off
- Toggle triggers state update via provider
- Error message appears on update failure
- Error message dismisses after timeout or user interaction
- Back navigation works correctly
- Screen rebuilds when provider state changes
- Accessibility: toggle has semantic labels

## Files to Modify/Create
- `pockitflyer_app/lib/screens/privacy_settings_screen.dart`
- `pockitflyer_app/lib/widgets/privacy_setting_toggle.dart` (optional component)
- `pockitflyer_app/test/screens/privacy_settings_screen_test.dart`
- `pockitflyer_app/test/widgets/privacy_setting_toggle_test.dart` (if separate widget)

## Dependencies
- m02-e03-t04 (Privacy settings state management)

## Notes
- Use CupertinoSwitch for iOS-native feel
- Explanatory text should be concise and clear
- Keep UI minimal - single toggle for MVP
- Consider adding section for future privacy options (profile visibility, etc.)
- Error messages should be non-intrusive (bottom sheet or snackbar)
- No confirmation dialog needed for toggle changes
