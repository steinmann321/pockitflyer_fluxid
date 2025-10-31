---
id: m03-e02-t06
epic: m03-e02
title: Integrate Follow Button into Flyer Cards and Profiles
status: pending
priority: high
tdd_phase: red
---

# Task: Integrate Follow Button into Flyer Cards and Profiles

## Objective
Add FollowButton widget to FlyerCard and CreatorProfileScreen, wiring up state management and callbacks. Button shows correct state, handles authentication flow, and updates optimistically.

## Acceptance Criteria
- [ ] FlyerCard displays FollowButton near creator name/avatar
- [ ] CreatorProfileScreen displays FollowButton in profile header
- [ ] FollowButton on own profile is hidden (cannot follow yourself)
- [ ] Button receives isFollowing state from FollowProvider
- [ ] Button receives isAuthenticated state from AuthProvider
- [ ] Tapping follow/unfollow triggers FollowProvider methods
- [ ] Tapping when not authenticated shows login/register sheet
- [ ] Button state updates optimistically on tap
- [ ] Error messages displayed on follow/unfollow failure
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- FlyerCard renders FollowButton with correct creator ID
- CreatorProfileScreen renders FollowButton in header
- FollowButton hidden on own profile
- Button shows correct isFollowing state from provider
- Tapping follow calls provider.followUser(userId)
- Tapping unfollow calls provider.unfollowUser(userId)
- Tapping when not authenticated shows auth sheet
- Error handling displays user-friendly messages

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/flyer_card.dart` (add FollowButton)
- `pockitflyer_app/lib/screens/creator_profile_screen.dart` (add FollowButton)
- `pockitflyer_app/test/widgets/flyer_card_test.dart` (update tests)
- `pockitflyer_app/test/screens/creator_profile_screen_test.dart` (update tests)

## Dependencies
- m03-e02-t04 (FollowButton widget must exist)
- m03-e02-t05 (FollowProvider must exist)
- m02-e01 (AuthProvider for authentication state)

## Notes
- FollowButton placement on FlyerCard should not interfere with other tap targets
- Use Consumer or watch() to listen to FollowProvider state
- Hide button on own profile by comparing creator.id with currentUser.id
- Authentication prompt should match existing login flow UX
- Consider loading state while API call is in flight
