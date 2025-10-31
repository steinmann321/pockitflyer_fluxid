---
id: m04-e01-t04
epic: m04-e01
title: Create Flyern Button and Navigation
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyern Button and Navigation

## Objective
Add "Flyern" button to app header that navigates to flyer creation screen with authentication check.

## Acceptance Criteria
- [ ] "Flyern" button visible in header for all users
- [ ] Tap on "Flyern" checks authentication state
- [ ] Authenticated users navigate to `/create-flyer` route
- [ ] Unauthenticated users navigate to `/login` with return_to parameter
- [ ] Button has distinctive styling (e.g., primary color, icon)
- [ ] Button disabled state while authentication check occurs
- [ ] Navigation preserves current screen in history
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Button renders in header
- Authenticated user navigation to creation screen
- Unauthenticated user redirect to login with return_to
- Button tap triggers authentication check
- Disabled state during authentication check
- Navigation history preservation
- Widget tests for button styling and placement

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/app_header.dart` (add Flyern button)
- `pockitflyer_app/lib/screens/create_flyer_screen.dart` (placeholder screen)
- `pockitflyer_app/lib/routes.dart` (add /create-flyer route)
- `pockitflyer_app/test/widgets/app_header_test.dart`
- `pockitflyer_app/test/screens/create_flyer_screen_test.dart`

## Dependencies
- M02-E01 (authentication state management)
- Frontend routing infrastructure

## Notes
- "Flyern" is the action verb for posting a flyer
- Consider icon: camera, add, or custom flyer icon
- Button placement: typically top-right in header
- Return_to parameter ensures smooth login flow
- Creation screen initially shows loading or empty state
