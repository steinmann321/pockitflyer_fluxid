---
id: m01-e01-t02
epic: m01-e01
title: Create Flyer Database Model
status: pending
priority: high
tdd_phase: red
---

# Task: Create Flyer Database Model

## Objective
Create Django Flyer model with all fields required for flyer card display and smart ranking.

## Acceptance Criteria
- [ ] Flyer model with fields: title, description, creator (FK to User), location_address, latitude, longitude
- [ ] Image support: up to 5 images via separate FlyerImage model (1-to-many)
- [ ] Validity fields: valid_from, valid_until (datetime fields)
- [ ] Timestamps: created_at, updated_at
- [ ] Computed field: is_valid (checks current datetime against validity period)
- [ ] Proper indexing on: creator, latitude/longitude (for proximity queries), valid_from/valid_until, created_at
- [ ] Database constraints: title max 200 chars, description max 2000 chars, address max 500 chars
- [ ] Coordinate validation (lat: -90 to 90, lng: -180 to 180)
- [ ] At least one image required (validated at model layer)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Model field validation and constraints
- Foreign key relationships
- Coordinate validation
- Validity period logic (is_valid computed property)
- Image count validation (min 1, max 5)
- Database indexes exist
- Timestamp auto-update behavior

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (Flyer, FlyerImage models)
- `pockitflyer_backend/flyers/tests/test_models.py`
- `pockitflyer_backend/flyers/migrations/000X_create_flyer_models.py` (auto-generated)

## Dependencies
- m01-e01-t01 (User model must exist)

## Notes
- Coordinates are stored directly in Flyer model for efficient proximity queries
- Backend geocodes address to coordinates on flyer creation
- FlyerImage model: flyer (FK), image (ImageField), order (IntegerField), created_at
