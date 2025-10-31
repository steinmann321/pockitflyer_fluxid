---
id: m01-e01-t01
epic: m01-e01
title: Create User Database Model
status: pending
priority: high
tdd_phase: red
---

# Task: Create User Database Model

## Objective
Create Django User model with fields needed for flyer creator identity display and location-based features.

## Acceptance Criteria
- [ ] User model extends Django AbstractUser
- [ ] Required fields: username, email, profile_picture (optional), bio (optional)
- [ ] Location fields: latitude, longitude (decimal fields with high precision)
- [ ] Timestamps: created_at, updated_at
- [ ] Proper indexing on username and email
- [ ] Model validation ensures valid coordinate ranges (lat: -90 to 90, lng: -180 to 180)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Model field validation (required/optional fields, data types, constraints)
- Coordinate range validation
- Database constraints and indexes
- Default values

## Files to Modify/Create
- `pockitflyer_backend/users/models.py`
- `pockitflyer_backend/users/tests/test_models.py`
- `pockitflyer_backend/users/migrations/000X_create_user_model.py` (auto-generated)

## Dependencies
- None (foundational model)

## Notes
- User location is stored for distance calculations
- Location is updated when user explicitly sets it in profile (M02 epic)
- Profile picture is optional for M01 (anonymous browsing)
