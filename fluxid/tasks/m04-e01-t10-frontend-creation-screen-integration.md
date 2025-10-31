---
id: m04-e01-t10
epic: m04-e01
title: Integrate Create Flyer Screen
status: pending
priority: high
tdd_phase: red
---

# Task: Integrate Create Flyer Screen

## Objective
Combine all creation widgets into cohesive CreateFlyerScreen with form validation, submission, and state management.

## Acceptance Criteria
- [ ] Screen layout: scrollable form with all input widgets
- [ ] Widget order: images, title, caption, info fields, categories, address, dates
- [ ] Form validation: all required fields checked before submit
- [ ] Submit button: "Publish Flyer" with loading state
- [ ] Optimistic UI update: navigate to feed immediately on submit
- [ ] Success: flyer appears in feed without refresh
- [ ] Error handling: display error message, allow retry
- [ ] Rollback on failure: remove optimistically added flyer from feed
- [ ] Draft saving: warn user about unsaved changes on back navigation
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Screen renders all widgets
- Form validation (required fields, character limits, date validation)
- Submit button states (enabled, disabled, loading)
- Successful submission flow
- Error handling and retry
- Optimistic update and rollback
- Navigation behavior
- Unsaved changes warning
- Integration tests

## Files to Modify/Create
- `pockitflyer_app/lib/screens/create_flyer_screen.dart`
- `pockitflyer_app/lib/providers/flyer_creation_provider.dart` (state management)
- `pockitflyer_app/test/screens/create_flyer_screen_test.dart`
- `pockitflyer_app/test/integration/create_flyer_flow_test.dart`

## Dependencies
- m04-e01-t05 (image upload widget)
- m04-e01-t06 (text input fields)
- m04-e01-t07 (category selection)
- m04-e01-t08 (address input)
- m04-e01-t09 (date pickers)
- m04-e01-t01 (backend API)

## Notes
- Use Flutter Form widget for validation
- State management: Riverpod or Provider
- Optimistic update: add flyer to local feed state immediately
- Rollback: remove from feed if API returns error
- Progress indicator for image uploads (multipart/form-data)
- Disable submit during upload/processing
- Success feedback: brief "Flyer published!" message
- Error feedback: detailed error message with retry button
