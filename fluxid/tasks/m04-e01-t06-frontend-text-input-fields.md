---
id: m04-e01-t06
epic: m04-e01
title: Create Text Input Fields with Character Limits
status: pending
priority: high
tdd_phase: red
---

# Task: Create Text Input Fields with Character Limits

## Objective
Build Flutter form widgets for title, caption, and two info fields with character limit validation and visible counters.

## Acceptance Criteria
- [ ] Title field: TextField, max 200 chars, required, single line
- [ ] Caption field: TextField, max 500 chars, optional, multiline (max 3 lines)
- [ ] Info Field 1: TextField, max 1000 chars, optional, multiline (max 5 lines)
- [ ] Info Field 2: TextField, max 1000 chars, optional, multiline (max 5 lines)
- [ ] Character counter displayed for all fields (e.g., "45/200")
- [ ] Counter color changes when approaching limit (e.g., yellow at 90%, red at 100%)
- [ ] Input prevented when at character limit
- [ ] Real-time validation with error messages
- [ ] Clear field button for quick reset
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Character limit enforcement for all fields
- Required field validation (title)
- Optional field validation (caption, info fields)
- Counter display and color changes
- Input prevention at limit
- Clear button functionality
- Multiline behavior
- Widget tests and golden tests

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/character_limited_text_field.dart` (reusable widget)
- `pockitflyer_app/lib/screens/create_flyer_screen.dart` (integrate fields)
- `pockitflyer_app/test/widgets/character_limited_text_field_test.dart`

## Dependencies
- Flutter form validation infrastructure

## Notes
- Reusable CharacterLimitedTextField widget for consistency
- Title: prominent styling, placeholder "What's your flyer about?"
- Caption: placeholder "Add a short description..."
- Info Field 1: placeholder "Additional information (optional)"
- Info Field 2: placeholder "More details (optional)"
- Use TextInputFormatter for character limit enforcement
- Counter format: "current/max"
- Consider helper text for field guidance
