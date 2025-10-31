---
id: m02-e02-t08
epic: m02-e02
title: Implement Header Avatar Navigation
status: pending
priority: medium
tdd_phase: red
---

# Task: Implement Header Avatar Navigation

## Objective
Update app header to display user's profile avatar when authenticated, and navigate to own profile when avatar tapped. When unauthenticated, show login button (existing behavior from M02-E01).

## Acceptance Criteria
- [ ] Header displays circular profile avatar when authenticated
- [ ] Header displays "Login" button when unauthenticated
- [ ] Tapping avatar navigates to own profile screen
- [ ] Avatar shows user's profile picture if available
- [ ] Avatar shows default avatar if user has no picture
- [ ] Avatar state updates when profile picture changes
- [ ] Smooth transition between login button and avatar on authentication
- [ ] Avatar has visual indicator it's tappable (e.g., subtle border)
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Header shows login button when unauthenticated
- Header shows avatar when authenticated
- Avatar displays user's profile picture correctly
- Avatar displays default avatar when user has no picture
- Tapping avatar navigates to profile screen with correct user ID
- Avatar updates when user changes profile picture
- Login button switches to avatar on authentication
- Avatar switches to login button on logout

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/app_header.dart` (update existing)
- `pockitflyer_app/lib/widgets/profile_avatar.dart` (new widget)
- `pockitflyer_app/test/widgets/app_header_test.dart` (update existing)
- `pockitflyer_app/test/widgets/profile_avatar_test.dart`

## Dependencies
- m02-e01-t09 (Header login button from authentication epic)
- m02-e02-t05 (Profile screen)
- m02-e01-t06 (Authentication state management)

## Notes
- Reuse existing app_header widget from M02-E01
- Avatar size: 40x40px for header (small, compact)
- Avatar should be circular (ClipOval or CircleAvatar widget)
- Default avatar should match profile screen default
- Consider caching avatar image to avoid repeated fetches
- Profile picture URL comes from authentication state
