---
id: m02-e01-t09
epic: m02-e01
title: Update Header with Authentication State UI
status: pending
priority: high
tdd_phase: red
---

# Task: Update Header with Authentication State UI

## Objective
Modify app header to dynamically switch between login button (unauthenticated) and profile avatar (authenticated). Avatar taps navigate to user's profile page.

## Acceptance Criteria
- [ ] Header observes AuthenticationProvider state
- [ ] When unauthenticated: shows "Login" button
- [ ] When authenticated: shows circular profile avatar (picture if available, placeholder icon if not)
- [ ] Login button navigates to login screen
- [ ] Profile avatar navigates to user's own profile page
- [ ] Smooth UI transition when auth state changes
- [ ] Profile picture loaded from API if available
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Header shows login button when unauthenticated
- Header shows profile avatar when authenticated
- Login button tap navigates to login screen
- Profile avatar tap navigates to profile page
- State change updates UI (login → avatar)
- State change updates UI (logout → login button)
- Profile picture displays if available
- Placeholder icon displays if no profile picture

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/app_header.dart` (modify existing from M01)
- `pockitflyer_app/test/widgets/app_header_test.dart`

## Dependencies
- m02-e01-t06 (AuthenticationProvider)
- m01 (existing app header from feed implementation)

## Notes
- Profile avatar should be small circular image (~40px diameter)
- Use CircleAvatar widget with NetworkImage or placeholder Icon
- Placeholder icon: Person icon or first letter of user name
- Profile picture URL comes from API (added in M02-E02 profile management epic)
- For M02-E01, avatar can use placeholder - profile picture feature implemented in M02-E02
- Ensure header updates immediately after login/registration without manual refresh
