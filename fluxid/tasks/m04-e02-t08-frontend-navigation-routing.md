---
id: m04-e02-t08
epic: m04-e02
title: Implement Edit Screen Navigation and Routing
status: pending
priority: medium
tdd_phase: red
---

# Task: Implement Edit Screen Navigation and Routing

## Objective
Set up proper navigation routing for flyer edit screen with flyer ID parameter passing and back navigation handling.

## Acceptance Criteria
- [ ] Route defined for flyer edit screen with flyer ID parameter
- [ ] Navigation from profile flyer card passes flyer ID
- [ ] Edit screen receives and uses flyer ID to load data
- [ ] Back button navigation returns to profile screen
- [ ] Unsaved changes warning on back navigation
- [ ] Save success navigation returns to profile
- [ ] Deep linking support for edit screen (e.g., from notifications)
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Route registration works
- Navigation with flyer ID parameter
- Flyer ID correctly passed to edit screen
- Back navigation returns to profile
- Unsaved changes warning appears when appropriate
- Unsaved changes warning doesn't appear after save
- Cancel warning dialog options work correctly
- Deep linking to edit screen works

## Files to Modify/Create
- `pockitflyer_app/lib/routes/app_routes.dart` (add edit route)
- `pockitflyer_app/lib/navigation/navigation_service.dart` (navigation helpers)
- `pockitflyer_app/test/navigation/navigation_test.dart`

## Dependencies
- M04-E02-T05 (Flyer edit screen)
- M04-E02-T04 (Profile flyers list widget)
- Existing routing infrastructure from previous milestones

## Notes
- Use named routes for better maintainability
- Consider using go_router or similar for complex routing needs
- Unsaved changes warning should be WillPopScope or PopScope
- Deep linking might need URL path pattern like /flyers/{id}/edit
- Navigation service should be testable and mockable
