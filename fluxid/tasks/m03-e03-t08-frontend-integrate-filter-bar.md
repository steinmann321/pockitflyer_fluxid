---
id: m03-e03-t08
epic: m03-e03
title: Integrate Filter Bar into Feed Screen
status: pending
priority: high
tdd_phase: red
---

# Task: Integrate Filter Bar into Feed Screen

## Objective
Integrate FilterBar widget into home feed screen, connect to filter state management, and trigger feed reload when filter changes. Filter bar positioned prominently above feed list with proper spacing and authentication handling.

## Acceptance Criteria
- [ ] FilterBar widget added to home feed screen above feed list
- [ ] Filter bar receives selected_filter from feed filter state
- [ ] Filter bar receives is_authenticated from auth state
- [ ] Tapping filter button updates feed filter state
- [ ] Feed list reloads with filtered data when filter changes
- [ ] Filter selection persists across screen navigation and app restart
- [ ] Loading indicator shows during filter change feed reload
- [ ] Empty state UI shows when filtered feed has no results
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Filter bar renders in home feed screen
- Filter bar shows correct selected filter
- Filter bar disabled buttons when user is anonymous
- Tapping filter button updates filter state
- Feed reloads when filter state changes
- Correct API endpoint called for each filter (all, favorites, following)
- Loading indicator appears during filter change
- Empty state UI appears when filter returns no results
- Filter selection persists after navigation away and back
- Widget tests for feed screen with filter bar

## Files to Modify/Create
- `pockitflyer_app/lib/screens/home_feed_screen.dart` (integrate filter bar)
- `pockitflyer_app/test/screens/home_feed_screen_test.dart` (update tests)

## Dependencies
- m03-e03-t05 (FilterBar widget)
- m03-e03-t06 (Feed filter state management)
- m03-e03-t07 (API client filter methods)
- m01-e01-t08 (Home feed screen structure)

## Notes
- Filter bar should be sticky/pinned at top of feed (does not scroll with content)
- Use Column layout: [FilterBar, Expanded(FeedList)]
- Feed reload: call API client method based on selected filter
- Empty state message examples: "No favorites yet", "You're not following anyone yet"
- Consider adding pull-to-refresh for filtered feeds
- Loading state: show shimmer or spinner over feed list
