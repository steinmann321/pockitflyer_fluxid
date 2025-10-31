---
id: m01-e04-t04
epic: m01-e04
title: Add Creator Flyers Feed to Profile Screen
status: pending
priority: high
tdd_phase: red
---

# Task: Add Creator Flyers Feed to Profile Screen

## Objective
Integrate creator's flyers feed into profile screen, displaying all flyers by the creator using existing FlyerCard widgets.

## Acceptance Criteria
- [ ] Profile screen displays scrollable list of creator's flyers below profile header
- [ ] Reuses existing FlyerCard widget for consistent display
- [ ] Pull-to-refresh support for creator flyers
- [ ] Infinite scroll pagination (loads next page at 80% threshold)
- [ ] Loading states: initial load, pagination, pull-to-refresh
- [ ] Empty state: "No flyers yet" message when creator has no flyers
- [ ] Error state with retry button
- [ ] Flyers list scrolls independently from profile header (combined scroll view)
- [ ] State management for creator flyers feed
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Creator flyers feed loads and displays correctly
- Flyer card consistency with main feed
- Pull-to-refresh behavior
- Infinite scroll pagination
- Empty state rendering
- Error state and retry
- Combined scroll behavior (header + feed)
- State management integration
- Widget tests with mocked API client

## Files to Modify/Create
- `pockitflyer_app/lib/screens/profile_screen.dart` (extend with flyers feed)
- `pockitflyer_app/lib/providers/creator_flyers_provider.dart`
- `pockitflyer_app/lib/services/user_api_client.dart` (add getCreatorFlyers method)
- `pockitflyer_app/test/screens/profile_screen_test.dart` (extend)
- `pockitflyer_app/test/providers/creator_flyers_provider_test.dart`

## Dependencies
- m01-e04-t02 (Creator flyers API endpoint)
- m01-e04-t03 (Profile screen widget)
- m01-e01-t06 (FlyerCard widget)

## Notes
- Use CustomScrollView with SliverAppBar for combined scroll behavior
- Profile header should collapse/expand on scroll (optional enhancement)
- Reuse FeedApiClient logic if possible, just add creator filter parameter
- Empty state message: "No flyers yet. Check back later!"
- Error state: "Couldn't load flyers. Check your connection and try again."
- Consider caching creator flyers during session (same as main feed)
