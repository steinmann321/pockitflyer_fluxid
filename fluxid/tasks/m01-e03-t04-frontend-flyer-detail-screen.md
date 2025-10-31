---
id: m01-e03-t04
epic: m01-e03
title: Build Flyer Detail Screen with Complete Information Display
status: pending
priority: high
tdd_phase: red
---

# Task: Build Flyer Detail Screen with Complete Information Display

## Objective
Create a full-screen detail view that displays complete flyer information including image carousel, title, description, category, dates, distance, and creator info with proper formatting and layout.

## Acceptance Criteria
- [ ] Screen displays image carousel at top (uses ImageCarousel widget)
- [ ] Title displayed prominently below images
- [ ] Category badge/chip shown
- [ ] Full description with proper text wrapping
- [ ] Distance formatted correctly (<1km shows meters, >=1km shows km)
- [ ] Valid until date formatted clearly ("Valid until [date]")
- [ ] Creator username displayed (avatar optional for M01)
- [ ] Tappable location section (handled in separate task)
- [ ] Scrollable if content exceeds screen height
- [ ] Loading state while fetching flyer details
- [ ] Error state for failed fetches or 404
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Screen renders with complete flyer data
- Image carousel integration works
- Text wrapping handles long descriptions
- Short descriptions don't create excessive whitespace
- Distance formatting (<1km meters, >=1km kilometers)
- Date formatting is user-friendly
- Missing optional fields handled gracefully
- Loading state displayed during API call
- Error state for network failures
- Error state for 404 (flyer not found/expired)
- Navigation from feed card to detail screen
- Screen rebuilds on data changes

## Files to Modify/Create
- `pockitflyer_app/lib/screens/flyer_detail_screen.dart`
- `pockitflyer_app/lib/services/api_client.dart` (add getFlyerDetail method)
- `pockitflyer_app/test/screens/flyer_detail_screen_test.dart`
- `pockitflyer_app/test/services/api_client_test.dart` (test detail endpoint)

## Dependencies
- Task m01-e03-t02 (backend detail API must exist)
- Task m01-e03-t03 (image carousel widget)
- Epic m01-e01 tasks (flyer card navigation)

## Notes
- Navigation: tap flyer card in feed → navigate to detail screen with flyer ID
- API client method: `Future<Flyer> getFlyerDetail(String flyerId, {double? lat, double? lng})`
- Use Material Design layout: AppBar, SingleChildScrollView, Column structure
- Distance passed via user location service (reuse from feed)
- Date formatting: use DateFormat from intl package
- Category: display with color coding (consistent with feed cards)
- Creator tap handled in Epic m01-e04 (out of scope here)
