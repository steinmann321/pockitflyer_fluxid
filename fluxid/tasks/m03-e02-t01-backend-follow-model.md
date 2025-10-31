---
id: m03-e02-t01
epic: m03-e02
title: Create Follow Database Model
status: pending
priority: high
tdd_phase: red
---

# Task: Create Follow Database Model

## Objective
Create Django Follow model representing a many-to-many relationship between users (follower-followed). The model enforces unique follower-followed pairs, prevents self-follows, and includes proper database constraints and indexing for efficient queries.

## Acceptance Criteria
- [ ] Follow model with fields: follower (ForeignKey to User), followed (ForeignKey to User, related_name='followers'), created_at (DateTimeField auto_now_add)
- [ ] Unique constraint on (follower, followed) pair - prevents duplicate follows
- [ ] Model validation prevents self-follows (follower != followed)
- [ ] Database indexes: composite index on (follower_id, followed_id), single index on follower_id for user's following list
- [ ] Proper on_delete behavior (CASCADE for both follower and followed)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Model field validation (required fields, data types)
- Unique constraint enforcement (duplicate follow raises IntegrityError)
- Self-follow prevention (follower == followed raises ValidationError)
- User-user relationship integrity (foreign key constraints)
- Automatic timestamp behavior (created_at set on creation)
- Cascade deletion (deleting user deletes related follows)
- Database index existence and performance

## Files to Modify/Create
- `pockitflyer_backend/users/models.py` (add Follow model)
- `pockitflyer_backend/users/tests/test_models.py` (add Follow tests)
- `pockitflyer_backend/users/migrations/000X_create_follow_model.py` (auto-generated)

## Dependencies
- m01-e01-t01 (User model must exist)

## Notes
- Follow model is a junction table representing follower-followed relationship
- created_at timestamp useful for "recently followed" features
- No soft deletes - unfollow is hard delete from database
- Self-follow validation enforced at model level using clean() method
- Consider performance: queries for "is user A following user B" should use composite index
