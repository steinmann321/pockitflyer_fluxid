---
id: m02-e02-t05
epic: m02-e02
title: Create Profile Screen UI
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Screen UI

## Objective
Implement Flutter profile screen that displays user profile picture, name, and published flyers. Screen is accessible to all users (authenticated and anonymous) for viewing any profile.

## Acceptance Criteria
- [ ] ProfileScreen widget with user_id parameter
- [ ] Displays profile picture (or default avatar if none)
- [ ] Displays user name
- [ ] Displays list of published flyers (using existing FlyerCard widget)
- [ ] "Edit Profile" button visible only when viewing own profile
- [ ] Default avatar/placeholder for users without profile picture
- [ ] Empty state UI when user has no published flyers
- [ ] Pull-to-refresh for profile data
- [ ] Loading state while fetching profile
- [ ] Error state for failed profile fetch
- [ ] Navigation to flyer detail when tapping flyer card
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Profile screen renders with complete profile data
- Profile screen renders with no profile picture (shows default avatar)
- Profile screen renders with no published flyers (empty state)
- "Edit Profile" button visible when viewing own profile
- "Edit Profile" button hidden when viewing others' profiles
- "Edit Profile" button hidden for anonymous users
- Pull-to-refresh updates profile data
- Loading indicator shown during fetch
- Error message shown on fetch failure
- Navigation to flyer detail works
- Flyer cards use existing FlyerCard widget

## Files to Modify/Create
- `pockitflyer_app/lib/screens/profile_screen.dart`
- `pockitflyer_app/lib/services/profile_service.dart` (API client)
- `pockitflyer_app/lib/models/profile.dart`
- `pockitflyer_app/test/screens/profile_screen_test.dart`
- `pockitflyer_app/test/services/profile_service_test.dart`

## Dependencies
- m02-e02-t01 (Backend profile retrieval API)
- m01-e01-t06 (FlyerCard widget for displaying flyers)
- m02-e01-t06 (Authentication state management)

## Notes
- Reuse FlyerCard widget from M01 for consistent flyer display
- Profile picture should be circular/avatar style
- Consider lazy loading for long flyer lists (optional for MVP)
- Default avatar should be a placeholder icon asset
- Use existing navigation patterns from M01
- Profile screen route: /profile/:userId
