---
id: m01-e02-t05
epic: m01-e02
title: Create Search Bar with Debouncing
status: pending
priority: high
tdd_phase: red
---

# Task: Create Search Bar with Debouncing

## Objective
Create an in-place search bar that updates the flyer feed in real-time as users type, with debouncing to reduce API calls (300ms delay after last keystroke).

## Acceptance Criteria
- [ ] Search bar integrated into feed screen header
- [ ] Feed updates as user types (debounced)
- [ ] Debounce delay: 300ms after last keystroke
- [ ] Search combines with category and Near Me filters using AND logic
- [ ] Clear button to reset search
- [ ] Loading indicator while search is in progress
- [ ] Empty state shown when no search results found
- [ ] Search state persists during app session
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Search bar renders correctly
- Typing triggers debounced search (not immediate)
- Debounce timing verified (300ms delay)
- Rapid typing doesn't cause excessive API calls
- Search combines with category filters correctly
- Search combines with Near Me filter correctly
- Clear button resets search and shows all flyers
- Empty search query shows all flyers
- Loading state displayed during search
- Search state persists during navigation

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/search_bar.dart` (new widget)
- `pockitflyer_app/test/widgets/search_bar_test.dart` (widget tests)
- `pockitflyer_app/lib/screens/feed_screen.dart` (integrate search)
- `pockitflyer_app/test/screens/feed_screen_test.dart` (update tests)

## Dependencies
- Task m01-e01-t08 (feed screen must exist)
- Task m01-e02-t06 (filter state management)
- Task m01-e02-t01 (backend API must support search)

## Notes
- Use Flutter TextField with TextEditingController
- Implement debouncing with Timer (cancel/restart on keystroke)
- Search bar positioned at top of feed screen (fixed header)
- Consider search icon, clear button, loading spinner in text field
- Search is case-insensitive (handled by backend)
- Empty string search should clear search filter, not maintain last search
- Debounce timing: 300ms is a balance between responsiveness and API efficiency
