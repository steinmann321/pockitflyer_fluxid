---
id: m01-e02-t04
epic: m01-e02
title: Create Near Me Toggle Filter
status: pending
priority: high
tdd_phase: red
---

# Task: Create Near Me Toggle Filter

## Objective
Create a Near Me toggle filter that shows only flyers within proximity threshold (5km) of user's current location, combining with other active filters.

## Acceptance Criteria
- [ ] Near Me toggle widget with clear on/off visual state
- [ ] Toggle requests location permission if not granted
- [ ] When enabled, filters flyers to proximity threshold (5km)
- [ ] Combines with category filters using AND logic
- [ ] Shows appropriate message when location permission denied
- [ ] Shows empty state when no nearby flyers found
- [ ] Feed updates immediately when toggle changes
- [ ] Toggle state persists during app session
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Toggle switches on/off correctly
- Location permission requested when needed
- Feed updates with Near Me filter active
- Near Me + category filter combination works
- Empty state shown when no nearby flyers
- Error state shown when location permission denied
- Toggle state persists during navigation
- Widget interaction triggers API call with correct parameters

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/near_me_filter.dart` (new widget)
- `pockitflyer_app/test/widgets/near_me_filter_test.dart` (widget tests)
- `pockitflyer_app/lib/screens/feed_screen.dart` (integrate filter)
- `pockitflyer_app/test/screens/feed_screen_test.dart` (update tests)

## Dependencies
- Task m01-e01-t05 (location service must exist)
- Task m01-e01-t08 (feed screen must exist)
- Task m01-e02-t06 (filter state management)
- Task m01-e02-t01 (backend API must support Near Me filtering)

## Notes
- Reuse existing location service from m01-e01-t05
- Proximity threshold: 5km (configurable in settings)
- Toggle widget positioned with category filters (filter bar)
- Handle location service errors gracefully (show message, disable toggle)
- Consider battery usage: don't poll location continuously, use last known
- Location permission flow should be non-blocking (user can dismiss)
