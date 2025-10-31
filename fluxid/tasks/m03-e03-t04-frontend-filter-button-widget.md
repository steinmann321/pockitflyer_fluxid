---
id: m03-e03-t04
epic: m03-e03
title: Create Filter Button Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Filter Button Widget

## Objective
Create FilterButton widget for displaying feed filter options (All, Favorites, Following) in a horizontal button group. Widget supports active/inactive states, disabled state for anonymous users, and smooth visual transitions.

## Acceptance Criteria
- [ ] FilterButton widget accepts parameters: label, is_active, is_enabled, on_tap callback
- [ ] Widget displays label text with active/inactive styling
- [ ] Active button: filled background, white text
- [ ] Inactive button: transparent background, gray text, subtle border
- [ ] Disabled button: grayed out, no interaction
- [ ] Tap area minimum 44x44pt for comfortable interaction
- [ ] Smooth animation on state change (background color, text color transition)
- [ ] Widget provides haptic feedback on tap (light impact)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders active state correctly (filled background, white text)
- Widget renders inactive state correctly (transparent background, gray text)
- Widget renders disabled state correctly (grayed out, no tap response)
- Tapping active button does not call on_tap (already active)
- Tapping inactive enabled button calls on_tap callback
- Tapping disabled button does not call on_tap callback
- Widget has minimum 44x44pt tap area
- Haptic feedback triggers on valid tap
- Animation plays smoothly on state change

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/filter_button.dart` (create FilterButton widget)
- `pockitflyer_app/test/widgets/filter_button_test.dart` (create widget tests)

## Dependencies
- None (standalone widget)

## Notes
- Use AnimatedContainer for smooth background/border transitions
- Active state: primary color background, white text
- Inactive state: Colors.transparent background, gray text, 1px gray border
- Disabled state: opacity 0.3, no GestureDetector
- Haptic feedback: HapticFeedback.lightImpact()
- Widget should be stateless - state managed by parent
- Consider using Material Design chips or segmented buttons as inspiration
