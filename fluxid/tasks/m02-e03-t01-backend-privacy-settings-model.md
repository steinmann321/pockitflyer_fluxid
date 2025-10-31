---
id: m02-e03-t01
epic: m02-e03
title: Create Privacy Settings Database Model
status: pending
priority: high
tdd_phase: red
---

# Task: Create Privacy Settings Database Model

## Objective
Create Django PrivacySettings model with email contact permission field. Model is automatically created with default values when a user registers. Privacy settings are separate from User and Profile models and linked via one-to-one relationship.

## Acceptance Criteria
- [ ] PrivacySettings model with fields: user (OneToOneField), allow_email_contact (BooleanField default=True)
- [ ] Timestamps: created_at, updated_at
- [ ] Proper indexing on user field
- [ ] Signal handler to automatically create default PrivacySettings when User is created
- [ ] Model validation for allow_email_contact (boolean only)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Model field validation (data types, defaults)
- One-to-one relationship with User
- Automatic privacy settings creation on user registration (signal test)
- Default value (allow_email_contact=True)
- Timestamp auto-update behavior
- Database constraint enforcement (unique user)

## Files to Modify/Create
- `pockitflyer_backend/users/models.py` (add PrivacySettings model)
- `pockitflyer_backend/users/signals.py` (create_privacy_settings signal handler)
- `pockitflyer_backend/users/apps.py` (register signal if not already)
- `pockitflyer_backend/users/tests/test_models.py` (add PrivacySettings tests)
- `pockitflyer_backend/users/tests/test_signals.py` (test automatic creation)
- `pockitflyer_backend/users/migrations/000X_create_privacy_settings_model.py` (auto-generated)

## Dependencies
- m02-e01-t01 (User model must exist)

## Notes
- PrivacySettings automatically created on user registration (no manual step)
- Default: allow_email_contact=True (opt-out model)
- Privacy settings are user-specific, not global
- Separate model from Profile for clean separation of concerns
- Consider adding index on allow_email_contact if querying on this field becomes common
