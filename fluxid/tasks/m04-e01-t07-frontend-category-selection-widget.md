---
id: m04-e01-t07
epic: m04-e01
title: Create Category Tag Selection Widget
status: pending
priority: medium
tdd_phase: red
---

# Task: Create Category Tag Selection Widget

## Objective
Build Flutter widget for multi-select category tag selection from predefined options.

## Acceptance Criteria
- [ ] Display all available categories as selectable chips/tags
- [ ] Multi-select: users can select multiple categories
- [ ] Visual distinction between selected and unselected tags
- [ ] At least one category required validation
- [ ] Categories fetched from backend API
- [ ] Loading state while fetching categories
- [ ] Error state if categories fail to load
- [ ] Tag ordering matches backend display_order
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Category fetching from API
- Multi-select behavior
- Visual state changes (selected/unselected)
- Required validation (at least one category)
- Loading and error states
- Tag ordering
- Widget tests and golden tests

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/category_selection_widget.dart`
- `pockitflyer_app/lib/models/category.dart`
- `pockitflyer_app/lib/services/api_client.dart` (add getCategories method)
- `pockitflyer_app/test/widgets/category_selection_widget_test.dart`

## Dependencies
- m04-e01-t02 (Category model and API)
- Frontend API client infrastructure

## Notes
- Use FilterChip or ChoiceChip widgets
- Selected state: filled color, checkmark icon
- Unselected state: outline only
- Categories: Events, Nightlife, Service, Food & Drink, Retail, Community, Other
- Consider horizontal scrollable list if many categories
- Cache categories to avoid repeated API calls
