---
id: m04-e01-t09
epic: m04-e01
title: Create Date Picker Widgets with Validation
status: pending
priority: high
tdd_phase: red
---

# Task: Create Date Picker Widgets with Validation

## Objective
Build Flutter date picker widgets for publication and expiration dates with validation logic.

## Acceptance Criteria
- [ ] Publication date picker: defaults to current date/time
- [ ] Expiration date picker: defaults to publication + 30 days
- [ ] Date pickers show formatted date (e.g., "Dec 31, 2025")
- [ ] Validation: expiration_date > publication_date
- [ ] Validation: publication_date >= today (or allow backdating?)
- [ ] Visual error display for invalid date ranges
- [ ] Disabled state: expiration disabled until publication selected
- [ ] Time selection included (date + time pickers)
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Default date values
- Date picker invocation and selection
- Date range validation (expiration > publication)
- Past date handling
- Same-day date handling
- Error message display
- Disabled state logic
- Time selection
- Widget tests

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/date_picker_field.dart` (reusable date picker)
- `pockitflyer_app/lib/screens/create_flyer_screen.dart` (integrate date pickers)
- `pockitflyer_app/test/widgets/date_picker_field_test.dart`

## Dependencies
- Flutter date/time picker widgets

## Notes
- Use showDatePicker and showTimePicker
- Format: "MMM dd, yyyy 'at' HH:mm" (e.g., "Dec 31, 2025 at 14:30")
- Publication date: can be future for scheduled posts
- Expiration date: must be after publication
- Consider preset expiration options: 1 day, 1 week, 1 month, custom
- Validation runs on date change and form submit
- Clear button to reset to defaults
