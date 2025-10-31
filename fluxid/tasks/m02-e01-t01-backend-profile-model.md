---
id: m02-e01-t01
epic: m02-e01
title: Create Profile Database Model
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Database Model

## Objective
Create Django Profile model with minimal fields (picture, name) that is automatically created when a user registers. Profile is separate from User model and linked via one-to-one relationship.

## Acceptance Criteria
- [ ] Profile model with fields: user (OneToOneField), profile_picture (optional ImageField), name (optional CharField max 100)
- [ ] Timestamps: created_at, updated_at
- [ ] Proper indexing on user field
- [ ] Signal handler to automatically create empty Profile when User is created
- [ ] Model validation for name length and picture format
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Model field validation (optional fields, data types, constraints)
- One-to-one relationship with User
- Automatic profile creation on user registration (signal test)
- Default values (null/empty for picture and name)
- Timestamp auto-update behavior

## Files to Modify/Create
- `pockitflyer_backend/users/models.py` (add Profile model)
- `pockitflyer_backend/users/signals.py` (create_profile signal handler)
- `pockitflyer_backend/users/apps.py` (register signal)
- `pockitflyer_backend/users/tests/test_models.py` (add Profile tests)
- `pockitflyer_backend/users/tests/test_signals.py` (test automatic creation)
- `pockitflyer_backend/users/migrations/000X_create_profile_model.py` (auto-generated)

## Dependencies
- m01-e01-t01 (User model must exist)

## Notes
- Profile is automatically created empty on user registration (no manual step needed)
- Profile picture and name are both optional (null=True, blank=True)
- Profile is public by default - no privacy fields on profile itself
- Image storage configured via Django MEDIA_ROOT/MEDIA_URL settings
