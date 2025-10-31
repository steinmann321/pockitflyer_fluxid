---
id: m03-e03-t09
epic: m03-e03
title: Empty State UI for Filtered Feeds
status: pending
priority: medium
tdd_phase: red
---

# Task: Empty State UI for Filtered Feeds

## Objective
Create EmptyFeedState widget displaying helpful messaging and action prompts when filtered feeds (favorites, following) return no results. Widget adapts message based on which filter is active.

## Acceptance Criteria
- [ ] EmptyFeedState widget accepts parameter: filter_type
- [ ] Widget displays icon, title, and description based on filter type
- [ ] Favorites filter empty state: "No favorites yet" + "Tap the heart icon on flyers you love"
- [ ] Following filter empty state: "You're not following anyone yet" + "Follow creators to see their flyers here"
- [ ] Widget includes optional CTA button (e.g., "Explore All Flyers")
- [ ] Widget centered vertically and horizontally in available space
- [ ] Widget follows app design system (colors, typography, spacing)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders correct message for favorites filter
- Widget renders correct message for following filter
- Widget displays icon, title, and description
- CTA button renders when provided
- CTA button tap calls callback
- Widget is centered in available space
- Widget follows design system styling

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/empty_feed_state.dart` (create widget)
- `pockitflyer_app/test/widgets/empty_feed_state_test.dart` (create tests)

## Dependencies
- m03-e03-t08 (Feed screen integration context)

## Notes
- Use Column with Center and Expanded for layout
- Icon suggestions: Icons.favorite_border for favorites, Icons.people_outline for following
- Title typography: headline6 or similar
- Description typography: bodyText2 with gray color
- CTA button optional: if provided, renders as primary button below description
- Consider adding illustration or animation for visual polish (optional)
