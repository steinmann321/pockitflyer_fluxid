---
id: m04-e02-t07
epic: m04-e02
title: Integrate Flyers List into Profile Screen
status: pending
priority: medium
tdd_phase: red
---

# Task: Integrate Flyers List into Profile Screen

## Objective
Integrate the profile flyers list widget into the existing user profile screen.

## Acceptance Criteria
- [ ] Profile screen includes "My Flyers" section
- [ ] Section only visible for authenticated user viewing their own profile
- [ ] Flyers list widget integrated below profile information
- [ ] Smooth scrolling between profile info and flyers list
- [ ] Loading states don't block profile info display
- [ ] Navigation from flyer card to edit screen works correctly
- [ ] Profile refresh also refreshes flyers list
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Profile screen shows flyers list for own profile
- Profile screen hides flyers list when viewing others' profiles
- Profile info loads independently of flyers list
- Tapping flyer navigates to edit screen
- Pull-to-refresh refreshes both profile and flyers
- Scroll performance with long flyers list
- Loading states don't interfere with each other

## Files to Modify/Create
- `pockitflyer_app/lib/screens/profile_screen.dart` (extend existing)
- `pockitflyer_app/test/screens/profile_screen_test.dart`

## Dependencies
- M04-E02-T04 (Profile flyers list widget)
- M02-E02 (Existing user profile screen)

## Notes
- Use Column or ListView to combine profile info and flyers list
- Consider using SliverAppBar for collapsing header effect
- Flyers section should have clear visual separation from profile info
- Loading states should use skeleton screens for better UX
- Ensure authenticated user can distinguish between viewing their own profile vs others'
