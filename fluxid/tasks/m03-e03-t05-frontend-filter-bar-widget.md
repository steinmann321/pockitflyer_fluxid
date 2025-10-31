---
id: m03-e03-t05
epic: m03-e03
title: Create Filter Bar Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Filter Bar Widget

## Objective
Create FilterBar widget that displays horizontal button group of filter options (All, Favorites, Following). Widget manages mutually exclusive selection, handles authentication state, and provides callback for filter changes.

## Acceptance Criteria
- [ ] FilterBar widget accepts parameters: selected_filter, is_authenticated, on_filter_changed callback
- [ ] Widget displays three filter buttons: "All", "Favorites", "Following"
- [ ] Only one button active at a time (mutually exclusive selection)
- [ ] "Favorites" and "Following" buttons disabled when is_authenticated is false
- [ ] "All" button always enabled
- [ ] Tapping filter button calls on_filter_changed with new filter value
- [ ] Widget has horizontal scrolling if buttons exceed screen width
- [ ] Proper spacing between buttons (8-12pt)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders three filter buttons
- Only selected filter shows active state
- Tapping inactive button calls on_filter_changed with correct value
- Tapping active button does not call on_filter_changed
- Authenticated state: all buttons enabled
- Anonymous state: Favorites and Following buttons disabled
- All button always enabled regardless of authentication
- Widget scrolls horizontally if needed
- Proper button spacing maintained

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/filter_bar.dart` (create FilterBar widget)
- `pockitflyer_app/test/widgets/filter_bar_test.dart` (create widget tests)

## Dependencies
- m03-e03-t04 (FilterButton widget)

## Notes
- Use Row with MainAxisAlignment.start for button layout
- Wrap in SingleChildScrollView for horizontal scrolling
- Filter values enum: FilterType { all, favorites, following }
- Pass is_authenticated from auth state management
- Widget should be stateless - state managed by parent feed screen
- Consider adding padding/margin for visual breathing room
