---
id: m02-e03-t06
epic: m02-e03
title: Add Privacy Settings Navigation from Profile
status: pending
priority: medium
tdd_phase: red
---

# Task: Add Privacy Settings Navigation from Profile

## Objective
Add navigation button/menu item on user profile screen to access privacy settings. Button should only be visible on the authenticated user's own profile (not on other users' profiles).

## Acceptance Criteria
- [ ] Settings button/icon on profile app bar (when viewing own profile)
- [ ] Button navigates to privacy settings screen
- [ ] Button NOT visible when viewing another user's profile
- [ ] Button visible after login/registration
- [ ] Navigation animation smooth and follows iOS patterns
- [ ] Back navigation from settings returns to profile
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Settings button visible on own profile
- Settings button NOT visible on other users' profiles
- Button tap navigates to privacy settings screen
- Back navigation returns to profile screen
- Button appearance updates when auth state changes
- Navigation maintains correct route stack

## Files to Modify/Create
- `pockitflyer_app/lib/screens/profile_screen.dart` (add settings button)
- `pockitflyer_app/lib/navigation/app_routes.dart` (add privacy settings route)
- `pockitflyer_app/test/screens/profile_screen_test.dart` (update tests)
- `pockitflyer_app/test/navigation/app_routes_test.dart` (test new route)

## Dependencies
- m02-e03-t05 (Privacy settings screen)
- m02-e02-t03 (Profile screen exists)

## Notes
- Use gear/cog icon for settings button (common iOS pattern)
- Settings button should be in app bar trailing position
- Consider using CupertinoIcons.settings for icon
- Profile screen should determine "own profile" by comparing auth user ID with profile user ID
- Navigation should use named routes for maintainability
