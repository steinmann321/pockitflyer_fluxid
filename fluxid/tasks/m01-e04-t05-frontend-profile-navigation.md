---
id: m01-e04-t05
epic: m01-e04
title: Implement Navigation from Flyer Card to Profile
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Navigation from Flyer Card to Profile

## Objective
Add tap handlers to FlyerCard creator name and avatar that navigate to the creator's profile screen.

## Acceptance Criteria
- [ ] Tapping creator name navigates to ProfileScreen with creator's user_id
- [ ] Tapping creator avatar navigates to ProfileScreen with creator's user_id
- [ ] Navigation uses platform-appropriate animation (iOS: slide from right)
- [ ] Both tap targets have visual feedback (ripple/highlight effect)
- [ ] Navigation passes user_id to ProfileScreen
- [ ] Back button on ProfileScreen returns to previous screen (feed)
- [ ] Main feed scroll position is preserved when returning from profile
- [ ] Main feed filter state is preserved when returning from profile
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Navigation triggered by tapping creator name
- Navigation triggered by tapping creator avatar
- Correct user_id passed to ProfileScreen
- Main feed state preservation on return
- Widget tests with navigation mocking
- Integration tests for navigation flow

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/flyer_card.dart` (add tap handlers)
- `pockitflyer_app/lib/main.dart` (register ProfileScreen route if needed)
- `pockitflyer_app/test/widgets/flyer_card_test.dart` (extend)
- `pockitflyer_app/test/integration/profile_navigation_test.dart`

## Dependencies
- m01-e04-t03 (ProfileScreen widget)
- m01-e01-t06 (FlyerCard widget)

## Notes
- Use Navigator.push with MaterialPageRoute for navigation
- Creator name and avatar should have InkWell or GestureDetector for tap handling
- Visual feedback on tap improves UX (highlight color, scale animation)
- Scroll position preservation: use AutomaticKeepAliveClientMixin on HomeScreen
- Filter state should already be preserved via state management (Provider/Riverpod)
- Consider hero animation for profile picture transition (optional enhancement)
