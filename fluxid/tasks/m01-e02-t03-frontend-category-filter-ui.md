---
id: m01-e02-t03
epic: m01-e02
title: Create Category Filter UI Component
status: pending
priority: high
tdd_phase: red
---

# Task: Create Category Filter UI Component

## Objective
Create a category filter UI component with multi-select capability (Events, Nightlife, Service) that updates the flyer feed immediately when selections change.

## Acceptance Criteria
- [ ] Category filter widget displays three options: Events, Nightlife, Service
- [ ] Multi-select capability with visual indication of selected categories
- [ ] Tapping a category toggles its selection on/off
- [ ] Feed updates immediately when category selection changes
- [ ] Selected categories persist during app session (navigation away and back)
- [ ] Visual design matches app style (minimal, clean)
- [ ] Accessibility labels for screen readers
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders all three category options
- Single category selection updates feed
- Multiple category selection updates feed
- Deselecting all categories shows all flyers
- Selection state persists during navigation
- Visual state correctly shows selected/unselected categories
- Accessibility labels present and correct
- Widget interaction triggers API call with correct parameters

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/category_filter.dart` (new widget)
- `pockitflyer_app/test/widgets/category_filter_test.dart` (widget tests)
- `pockitflyer_app/lib/screens/feed_screen.dart` (integrate filter)
- `pockitflyer_app/test/screens/feed_screen_test.dart` (update tests)

## Dependencies
- Task m01-e01-t08 (feed screen must exist)
- Task m01-e02-t06 (filter state management)
- Task m01-e02-t01 (backend API must support category filtering)

## Notes
- Use Flutter chip/toggle button UI pattern for category selection
- Categories are static: Events, Nightlife, Service (no dynamic loading needed)
- Filter widget positioned above feed list (sticky header or expandable section)
- Use state management to communicate selection to feed provider
- Consider horizontal layout with scrollable categories for future expansion
