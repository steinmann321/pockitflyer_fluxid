---
id: m03-e01-t01
epic: m03-e01
title: Create Favorite Database Model
status: pending
priority: high
tdd_phase: red
---

# Task: Create Favorite Database Model

## Objective
Create Django Favorite model representing a many-to-many relationship between users and flyers. The model enforces unique user-flyer pairs with proper database constraints and indexing for efficient queries.

## Acceptance Criteria
- [ ] Favorite model with fields: user (ForeignKey to User), flyer (ForeignKey to Flyer), created_at (DateTimeField auto_now_add)
- [ ] Unique constraint on (user, flyer) pair - prevents duplicate favorites
- [ ] Database indexes: composite index on (user_id, flyer_id), single index on user_id for user favorites queries
- [ ] Model validation enforces both user and flyer are required
- [ ] Proper on_delete behavior (CASCADE for both user and flyer)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Model field validation (required fields, data types)
- Unique constraint enforcement (duplicate favorite raises IntegrityError)
- User-flyer relationship integrity (foreign key constraints)
- Automatic timestamp behavior (created_at set on creation)
- Cascade deletion (deleting user deletes favorites, deleting flyer deletes favorites)
- Database index existence and performance

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (add Favorite model)
- `pockitflyer_backend/flyers/tests/test_models.py` (add Favorite tests)
- `pockitflyer_backend/flyers/migrations/000X_create_favorite_model.py` (auto-generated)

## Dependencies
- m01-e01-t01 (User model must exist)
- m01-e01-t02 (Flyer model must exist)

## Notes
- Favorite model is simple junction table with no additional state beyond the relationship
- created_at timestamp useful for "recently favorited" features
- No soft deletes - unfavorite is hard delete from database
- Consider performance: queries for "is this flyer favorited by this user" should use composite index
