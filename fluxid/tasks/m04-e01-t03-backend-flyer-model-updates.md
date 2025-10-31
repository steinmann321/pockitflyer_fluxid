---
id: m04-e01-t03
epic: m04-e01
title: Update Flyer Model for Creation Fields
status: pending
priority: high
tdd_phase: red
---

# Task: Update Flyer Model for Creation Fields

## Objective
Extend Flyer model with caption, info_field_1, info_field_2, and character limit validations needed for M04 creation flow.

## Acceptance Criteria
- [ ] Add caption field (CharField, max 500 chars, optional)
- [ ] Add info_field_1 field (TextField, max 1000 chars, optional)
- [ ] Add info_field_2 field (TextField, max 1000 chars, optional)
- [ ] Update title max length validation to 200 chars
- [ ] Update description field to use caption (rename/migrate if needed)
- [ ] Model-level validation enforces character limits
- [ ] Database migration handles existing flyers gracefully
- [ ] Indexing considerations for new searchable fields
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- New field validations (character limits, optional/required)
- Existing flyer data migration (if renaming fields)
- Model save with various field combinations
- Character limit enforcement at model layer
- Database constraints match model constraints

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (Flyer model updates)
- `pockitflyer_backend/flyers/tests/test_models.py` (updated tests)
- `pockitflyer_backend/flyers/migrations/000X_add_creation_fields.py` (auto-generated)

## Dependencies
- m01-e01-t02 (Flyer model must exist)

## Notes
- Ensure backward compatibility with M01 feed display
- Consider full-text search indexing on caption and info fields
- Character limits match frontend UI constraints
- Optional fields allow progressive disclosure in creation UI
