---
id: m01-e02-t06
epic: m01-e02
title: Implement Filter State Management
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Filter State Management

## Objective
Create a state management solution for filter state (categories, Near Me, search) that coordinates between filter widgets and the feed, ensuring consistent state across navigation and pull-to-refresh.

## Acceptance Criteria
- [ ] Filter state provider holds: selected categories, Near Me toggle, search query
- [ ] State provider triggers API call when any filter changes
- [ ] Filter state persists during app session (navigation away and back)
- [ ] Pull-to-refresh maintains active filters
- [ ] State changes are reactive (UI updates automatically)
- [ ] API calls include all active filter parameters
- [ ] State is session-only (does not persist across app restarts)
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Provider initializes with empty/default filter state
- Updating category selection triggers feed refresh
- Updating Near Me toggle triggers feed refresh
- Updating search query triggers feed refresh
- Multiple filter changes combine correctly in API call
- State persists during navigation
- Pull-to-refresh maintains filters
- State resets on app restart (session-only)
- API client receives correct filter parameters

## Files to Modify/Create
- `pockitflyer_app/lib/providers/filter_provider.dart` (new provider)
- `pockitflyer_app/test/providers/filter_provider_test.dart` (provider tests)
- `pockitflyer_app/lib/services/api_client.dart` (update to accept filter params)
- `pockitflyer_app/test/services/api_client_test.dart` (update tests)

## Dependencies
- Task m01-e01-t07 (API client must exist)
- Task m01-e01-t08 (feed screen integration point)

## Notes
- Use Flutter provider pattern (ChangeNotifier or Riverpod)
- Filter state structure: `{ categories: Set<String>, nearMe: bool, latitude: double?, longitude: double?, radius: double, search: String }`
- State provider should batch rapid changes (combine with search debouncing)
- Consider exposing computed property `hasActiveFilters` for UI indicators
- API client should build query string from filter state
- Session persistence: keep state in memory only, no SharedPreferences
