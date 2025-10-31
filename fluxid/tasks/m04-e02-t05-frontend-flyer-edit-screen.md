---
id: m04-e02-t05
epic: m04-e02
title: Create Flyer Edit Screen
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyer Edit Screen

## Objective
Build Flutter screen for editing existing flyers with all creation fields pre-populated and full edit capabilities.

## Acceptance Criteria
- [ ] Screen loads flyer data from API and pre-populates all fields
- [ ] All creation fields editable: images, title, caption, info_field_1, info_field_2, category_tags, location_address, dates
- [ ] Image editing: add, remove, reorder (maintaining 1-5 limit)
- [ ] Character limit enforcement on text fields (same as creation)
- [ ] Category tag multi-select modification
- [ ] Location address field with validation
- [ ] Date pickers for publication and expiration dates with validation
- [ ] Save button triggers API update call
- [ ] Loading state during save operation
- [ ] Success feedback with navigation back to profile
- [ ] Error feedback with specific validation messages
- [ ] Unsaved changes warning on back navigation
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Screen builds with flyer ID parameter
- Loading state displayed while fetching flyer data
- All fields pre-populated with existing flyer data
- Text fields editable and enforce character limits
- Image gallery shows existing images
- Add image button works (up to 5 total)
- Remove image button works (but prevents removing all)
- Image reordering works
- Category tags can be modified
- Location address field accepts input
- Date pickers allow date changes
- Date validation: expiration > publication
- Save button disabled during save operation
- Save success navigates back to profile
- Save error shows validation messages
- Back button shows unsaved changes warning
- Cancel warning dialog allows save or discard

## Files to Modify/Create
- `pockitflyer_app/lib/screens/flyer_edit_screen.dart` (FlyerEditScreen)
- `pockitflyer_app/lib/state/flyer_edit_state.dart` (edit state management)
- `pockitflyer_app/test/screens/flyer_edit_screen_test.dart`
- `pockitflyer_app/test/state/flyer_edit_state_test.dart`

## Dependencies
- M04-E02-T03 (Backend flyer detail API with edit context)
- M04-E02-T02 (Backend flyer update API)
- M04-E01 (Flyer creation screen widgets can be reused)

## Notes
- Reuse as many creation screen widgets as possible (image picker, category selector, etc.)
- Track dirty state to detect unsaved changes
- Consider using Form widget with GlobalKey for validation
- Image reordering can use ReorderableListView
- Date validation should happen on both client and server
- Geocoding happens server-side on save, not during address input
- Provide clear feedback for long-running operations (image uploads, geocoding)
- Cancel button should confirm if changes were made
