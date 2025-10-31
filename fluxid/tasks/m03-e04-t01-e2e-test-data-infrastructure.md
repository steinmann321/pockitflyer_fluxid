---
id: m03-e04-t01
epic: m03-e04
title: E2E Test Data Infrastructure for M03 Engagement Features
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test Data Infrastructure for M03 Engagement Features

## Objective
Extend E2E test data seeding infrastructure to support M03 engagement workflows including favorites, follows, and filtered feeds with realistic relationship data and diverse scenarios.

## Acceptance Criteria
- [ ] Django management command: `python manage.py seed_m03_e2e_data` creates M03-specific test dataset
- [ ] 50+ favorite relationships across test users:
  - Distributed realistically: some users with 0 favorites, some with 1-5, some with 10+ favorites
  - Cover all categories: Events, Nightlife, Service flyers favorited
  - Mix of recent and older favorites (creation timestamps)
  - Some favorites for deleted/invalid flyers (edge case testing)
- [ ] 30+ follow relationships across test users:
  - Distributed realistically: some users with 0 follows, some with 1-3, some with 5+ follows
  - Mix of active and inactive creators (some followed creators have no recent flyers)
  - No self-follows (validation test data)
  - Some follows for deleted/inactive users (edge case testing)
- [ ] Test user categories for workflows:
  - "Anonymous user" simulation (no authentication)
  - "New authenticated user" (0 favorites, 0 follows)
  - "Active user" (5-10 favorites, 3-5 follows)
  - "Power user" (20+ favorites, 10+ follows)
  - "Creator-only user" (many flyers created, few favorites/follows)
- [ ] Flyer distribution for filtered feeds:
  - Ensure favorited flyers span multiple categories
  - Ensure followed creators have flyers in multiple categories
  - Ensure some overlap (flyer from followed creator that user also favorited)
  - Ensure some non-overlap (favorited flyer from non-followed creator)
- [ ] Database cleanup command: `python manage.py cleanup_m03_e2e_data`
- [ ] Idempotent seeding (can run multiple times without duplicates)
- [ ] Deterministic data (same seed produces same dataset for reproducible tests)
- [ ] All test data tagged with `is_e2e_test_data=True` flag
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Management command execution (seed_m03_e2e_data and cleanup_m03_e2e_data)
- Favorite relationship creation (user → flyer)
- Follow relationship creation (user → creator)
- Prevent self-follows (validation)
- User category distribution (new, active, power users)
- Flyer-creator-favorite-follow relationship integrity
- Idempotency (running seed twice doesn't duplicate relationships)
- Cleanup completeness (all M03 test data removed, M01/M02 test data preserved)
- Performance (seeding completes in <10 seconds)

## Files to Modify/Create
- `pockitflyer_backend/users/management/commands/seed_m03_e2e_data.py`
- `pockitflyer_backend/users/management/commands/cleanup_m03_e2e_data.py`
- `pockitflyer_backend/users/tests/test_m03_e2e_data_seeding.py`
- `pockitflyer_backend/users/fixtures/m03_engagement_scenarios.json` (favorite/follow templates)

## Dependencies
- m01-e05-t01 (M01 E2E test data infrastructure)
- m02-e04-t01 (M02 E2E test data infrastructure)
- m03-e01-t01 (Favorite model)
- m03-e02-t01 (Follow model)

## Notes
**User Categories**:
- Anonymous: No user object (test without authentication)
- New user: `test_user_new@pockitflyer.test` (created in M02, no favorites/follows)
- Active user: `test_user_active@pockitflyer.test` (5-10 favorites, 3-5 follows)
- Power user: `test_user_power@pockitflyer.test` (20+ favorites, 10+ follows)
- Creator user: `test_creator_prolific@pockitflyer.test` (20+ flyers created, 2 favorites, 1 follow)

**Relationship Distribution**:
- Favorites: 50 total relationships distributed across 10-15 users
- Follows: 30 total relationships distributed across 10-15 users
- Ensure some users have both favorites and follows
- Ensure some users have only favorites
- Ensure some users have only follows

**Edge Cases to Seed**:
1. Favorited flyer that gets deleted (set flyer.is_active=False)
2. Followed creator who deleted account (set user.is_active=False)
3. Favorited flyer with expired validity_end_date
4. Followed creator with no published flyers (all flyers.is_active=False)
5. User favorites flyer from creator they also follow (overlap scenario)

**Performance Considerations**:
- Bulk create operations for favorites and follows
- Use transactions for atomic seeding
- Pre-select users and flyers to avoid N+1 queries

**Cleanup Strategy**:
- `cleanup_m03_e2e_data` removes favorites, follows (M03 relationships)
- Does NOT remove users, profiles, flyers (handled by M01/M02 cleanup commands)
- Cascading delete not needed (favorites/follows are junction table records)

**Integration with M01/M02 Data**:
- Call `seed_m02_e2e_data` first to ensure users exist
- Select flyers from M01 test data for favorites
- Select users from M02 test data for follows
- Maintain referential integrity across milestone test data
