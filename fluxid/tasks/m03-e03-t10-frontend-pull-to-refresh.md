---
id: m03-e03-t10
epic: m03-e03
title: Pull-to-Refresh for Filtered Feeds
status: pending
priority: medium
tdd_phase: red
---

# Task: Pull-to-Refresh for Filtered Feeds

## Objective
Implement pull-to-refresh functionality for filtered feeds (favorites, following) that reloads feed data and updates relationship data (favorites, follows) to ensure UI reflects latest backend state.

## Acceptance Criteria
- [ ] Pull-to-refresh gesture works on all feed filters (all, favorites, following)
- [ ] Refresh indicator displays during reload operation
- [ ] Refresh reloads current filtered feed data from backend
- [ ] Refresh updates relationship state (favorites list, follows list)
- [ ] Refresh completes within 2 seconds on standard network
- [ ] Error handling: toast message on failure, feed shows previous data
- [ ] Refresh resets pagination to page 1
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Pull gesture triggers refresh
- Refresh indicator displays during reload
- Correct API endpoint called based on current filter
- Pagination resets to page 1 after refresh
- Relationship state updates after refresh
- Error handling shows toast and preserves previous data
- Refresh works for all filter types (all, favorites, following)
- Integration tests with mock HTTP responses

## Files to Modify/Create
- `pockitflyer_app/lib/screens/home_feed_screen.dart` (add pull-to-refresh)
- `pockitflyer_app/test/screens/home_feed_screen_test.dart` (update tests)

## Dependencies
- m03-e03-t08 (Filter bar integration)
- m01-e01-t08 (Existing feed screen structure)

## Notes
- Use RefreshIndicator widget wrapping feed list
- onRefresh callback: reload feed based on current filter
- Also refresh favorites and follows state to sync relationship changes
- Consider updating feed state management to support refresh action
- Refresh should clear current feed data and fetch fresh from page 1
- Show loading state while refreshing
