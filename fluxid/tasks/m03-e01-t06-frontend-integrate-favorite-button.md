---
id: m03-e01-t06
epic: m03-e01
title: Integrate Favorite Button into Flyer Cards
status: pending
priority: high
tdd_phase: red
---

# Task: Integrate Favorite Button into Flyer Cards

## Objective
Add FavoriteButton widget to all flyer card layouts (feed cards, detail view) connected to FavoriteState for functional favorite/unfavorite operations. Handle authentication state to show appropriate UI for anonymous vs authenticated users.

## Acceptance Criteria
- [ ] FavoriteButton appears on flyer cards in feed view (top-right corner)
- [ ] FavoriteButton appears on flyer detail view (header area)
- [ ] Button shows correct initial state from flyer.is_favorited API field
- [ ] Button connects to FavoriteState.toggleFavorite on tap
- [ ] Anonymous users see disabled button with authentication prompt on tap
- [ ] Authentication prompt shows login/register sheet modal
- [ ] Button state updates immediately on tap (optimistic update)
- [ ] Button state syncs with FavoriteState changes (Provider/ChangeNotifier)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- FavoriteButton renders on flyer card in feed
- FavoriteButton renders on flyer detail view
- Button displays correct initial state (is_favorited from API)
- Tapping button calls FavoriteState.toggleFavorite
- Anonymous user tap shows authentication prompt
- Authentication prompt navigates to login screen
- Button state updates on FavoriteState changes
- Button state persists across navigation (feed → detail → back)

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/flyer_card.dart` (add FavoriteButton)
- `pockitflyer_app/lib/screens/flyer_detail_screen.dart` (add FavoriteButton)
- `pockitflyer_app/lib/widgets/auth_prompt_sheet.dart` (create authentication prompt modal)
- `pockitflyer_app/test/widgets/flyer_card_test.dart` (test button integration)
- `pockitflyer_app/test/screens/flyer_detail_screen_test.dart` (test button integration)

## Dependencies
- m03-e01-t04 (FavoriteButton widget must exist)
- m03-e01-t05 (FavoriteState must exist)
- m01-e01-t06 (FlyerCard widget must exist)

## Notes
- Position button top-right corner of card with padding
- Use Consumer<FavoriteState> or Provider.of to access state
- Authentication prompt: showModalBottomSheet with login/register options
- Handle edge case: button tap while API call in progress (disable or ignore)
- Consider loading indicator during API call (subtle, non-blocking)
