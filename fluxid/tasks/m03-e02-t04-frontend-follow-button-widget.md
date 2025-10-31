---
id: m03-e02-t04
epic: m03-e02
title: Create Follow Button Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Follow Button Widget

## Objective
Create reusable Flutter FollowButton widget that displays follow/following state with proper styling, handles tap interactions, and provides callbacks for follow/unfollow actions. Widget is stateless and receives state via props.

## Acceptance Criteria
- [ ] FollowButton widget accepts: isFollowing (bool), isAuthenticated (bool), onFollowPressed (callback), onUnfollowPressed (callback)
- [ ] Button shows "Follow" text when not following (outlined style)
- [ ] Button shows "Following" text when following (filled style)
- [ ] Button is disabled when user is not authenticated (shows disabled state)
- [ ] Tapping disabled button triggers onAuthRequired callback
- [ ] Tapping enabled button triggers appropriate callback (onFollowPressed or onUnfollowPressed)
- [ ] Button has adequate tap target size (minimum 44x44 points)
- [ ] Smooth animations for state transitions
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders with isFollowing=false (shows "Follow", outlined style)
- Widget renders with isFollowing=true (shows "Following", filled style)
- Widget disabled when isAuthenticated=false
- Tapping button when not following calls onFollowPressed
- Tapping button when following calls onUnfollowPressed
- Tapping disabled button calls onAuthRequired
- Button has correct tap target size
- Button animations work smoothly

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/follow_button.dart` (create FollowButton widget)
- `pockitflyer_app/test/widgets/follow_button_test.dart` (create widget tests)

## Dependencies
- Flutter SDK and widget testing framework

## Notes
- Widget is stateless - parent manages state
- Use OutlinedButton for "Follow" state, ElevatedButton for "Following" state
- Disabled state should be visually clear (grayed out)
- Consider haptic feedback on tap
- Button should be compact enough for flyer cards but visible
- Use theme colors for consistency
