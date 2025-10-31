---
id: m03-e01-t04
epic: m03-e01
title: Create Favorite Button Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Favorite Button Widget

## Objective
Create reusable FavoriteButton widget with heart icon that displays correct state (favorited/not favorited/disabled) and handles tap interactions. Widget uses optimistic updates for instant feedback.

## Acceptance Criteria
- [ ] FavoriteButton widget accepts parameters: flyer_id, is_favorited, on_tap callback
- [ ] Widget displays filled heart icon when is_favorited is true
- [ ] Widget displays empty heart icon when is_favorited is false
- [ ] Widget displays disabled/grayed out heart when user is not authenticated
- [ ] Tap area is minimum 44x44pt for comfortable interaction
- [ ] Widget shows smooth animation on state change (fill/unfill transition)
- [ ] Widget provides haptic feedback on tap (light impact)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders filled heart when is_favorited is true
- Widget renders empty heart when is_favorited is false
- Widget renders disabled heart when user is anonymous
- Tapping widget calls on_tap callback with correct parameters
- Tapping disabled widget does not call on_tap callback
- Widget animation plays on state change
- Widget has minimum 44x44pt tap area
- Haptic feedback triggers on valid tap

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/favorite_button.dart` (create FavoriteButton widget)
- `pockitflyer_app/test/widgets/favorite_button_test.dart` (create widget tests)

## Dependencies
- None (standalone widget)

## Notes
- Use Icons.favorite (filled) and Icons.favorite_border (empty) for heart states
- Use IconButton or GestureDetector with Icon child
- Consider using AnimatedSwitcher for smooth icon transitions
- Disabled state: lower opacity, gray color, no interaction
- Haptic feedback: HapticFeedback.lightImpact()
- Widget should be stateless - state managed by parent
