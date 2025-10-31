---
id: m04-e02-t04
epic: m04-e02
title: Create Profile Flyers List Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Flyers List Widget

## Objective
Build Flutter widget to display list of user's flyers on their profile page with status indicators and tap-to-edit navigation.

## Acceptance Criteria
- [ ] Widget displays list of user's flyers retrieved from backend API
- [ ] Each flyer card shows: thumbnail image, title, status badge, publication date, expiration date
- [ ] Status badges: "Active" (green), "Expired" (red), "Scheduled" (blue)
- [ ] Empty state displayed when user has no flyers ("You haven't created any flyers yet")
- [ ] Loading state while fetching flyers
- [ ] Error state for failed API calls with retry button
- [ ] Pagination support (load more on scroll)
- [ ] Pull-to-refresh functionality
- [ ] Tapping a flyer card navigates to edit screen
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget builds without errors
- Displays loading state initially
- Displays empty state when no flyers
- Displays list of flyers when data loaded
- Status badges correctly displayed (active, expired, scheduled)
- Flyer cards show correct data (title, dates, thumbnail)
- Pull-to-refresh triggers data reload
- Pagination loads more flyers when scrolled to bottom
- Tap on flyer card triggers navigation to edit screen
- Error state displays with retry button
- Retry button triggers new API call

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/profile_flyers_list.dart` (ProfileFlyersList widget)
- `pockitflyer_app/lib/widgets/profile_flyer_card.dart` (ProfileFlyerCard widget)
- `pockitflyer_app/lib/models/user_flyer.dart` (UserFlyer model for list items)
- `pockitflyer_app/test/widgets/profile_flyers_list_test.dart`
- `pockitflyer_app/test/widgets/profile_flyer_card_test.dart`

## Dependencies
- M04-E02-T01 (Backend user flyers list API)
- M02-E02 (User profile screen infrastructure)

## Notes
- Use ListView.builder for efficient rendering of large lists
- Implement ScrollController for pagination detection
- Status badge colors should match app theme
- Consider using cached_network_image for thumbnails
- Empty state should be encouraging with call-to-action to create first flyer
- Error messages should be user-friendly, not technical
- Loading state can use shimmer effect for better UX
