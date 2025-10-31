---
id: m04-e04-t01
title: E2E Test Data Infrastructure for M04
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test Data Infrastructure for M04

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Creates comprehensive test data seeding infrastructure for M04 flyer creation, editing, expiration, and deletion workflows with NO MOCKS. Extends M01 test data with M04-specific scenarios (authenticated users, creator profiles, various flyer states).

## Implementation Guide for LLM Agent

### Objective
Create E2E test data infrastructure supporting all M04 workflows (create, edit, delete, expire) using real backend and database.

### Steps

1. Extend E2E data seeding for M04 scenarios
   - Modify `pockitflyer_backend/users/management/commands/seed_e2e_data.py`
   - Add authenticated test users with tokens (5+ users)
   - Add user-owned flyers (users with 0, 1, 5, 20 flyers)
   - Add flyers in various states (active, expired, near-expiration)
   - Add flyers with edit history metadata
   - Ensure test users have profile pictures (for creator context)
   - Pre-compute JWT tokens for authenticated E2E flows

2. Create M04-specific test fixtures
   - Create `pockitflyer_backend/users/fixtures/e2e_m04_users.json` with authenticated user data
   - Create `pockitflyer_backend/users/fixtures/e2e_m04_flyers.json` with owned flyers
   - Include flyers across all categories (Events, Nightlife, Service)
   - Include various image counts (1-5 images per flyer)
   - Include expiration scenarios (expired, expires today, expires in 7 days)

3. Add M04 test utilities
   - Create `pockitflyer_backend/users/tests/utils/e2e_m04_helpers.py`
   - Add function: `get_test_user_token(username)` - retrieves JWT for Maestro tests
   - Add function: `create_test_flyer(user, **kwargs)` - creates flyer during test
   - Add function: `update_flyer_state(flyer_id, **kwargs)` - modifies flyer mid-test
   - Add function: `cleanup_m04_test_data()` - removes M04-specific test data

4. Update cleanup command
   - Modify `pockitflyer_backend/users/management/commands/cleanup_e2e_data.py`
   - Ensure M04 test data (authenticated users, owned flyers) cleaned up
   - Preserve M01-M03 test data if needed

5. Create verification tests
   - Create `pockitflyer_backend/users/tests/test_e2e_m04_data_seeding.py`
   - Test: Django command `seed_e2e_data` creates M04 test users
   - Test: 5+ authenticated users created with valid JWT tokens
   - Test: Users have owned flyers in various states
   - Test: Cleanup removes all M04 test data
   - Mark tests `@pytest.mark.tdd_green` after passing

### Acceptance Criteria
- [ ] `python manage.py seed_e2e_data` creates 5+ authenticated test users with JWT tokens
- [ ] Test users have owned flyers (distributed 0-20 flyers per user)
- [ ] Flyers in various states: active, expired, near-expiration (expires within 24 hours)
- [ ] Helper function `get_test_user_token(username)` returns valid JWT for Maestro tests
- [ ] `python manage.py cleanup_e2e_data` removes all M04 test data

### Files to Create/Modify
- `pockitflyer_backend/users/management/commands/seed_e2e_data.py` - MODIFY: Add M04 scenarios
- `pockitflyer_backend/users/fixtures/e2e_m04_users.json` - NEW: Authenticated user fixtures
- `pockitflyer_backend/users/fixtures/e2e_m04_flyers.json` - NEW: User-owned flyer fixtures
- `pockitflyer_backend/users/tests/utils/e2e_m04_helpers.py` - NEW: M04 test utilities
- `pockitflyer_backend/users/management/commands/cleanup_e2e_data.py` - MODIFY: M04 cleanup
- `pockitflyer_backend/users/tests/test_e2e_m04_data_seeding.py` - NEW: Seeding verification tests

### Testing Requirements
**Note**: This task IS the E2E testing infrastructure. Tests run against real backend without mocks.

- **Unit tests**: Verify management commands and helper functions
- **E2E validation**: Subsequent M04-E04 tasks depend on this infrastructure

### Definition of Done
- [ ] Management command creates M04 test data successfully
- [ ] Test users have valid JWT tokens for authentication
- [ ] Helper functions work with real backend and database
- [ ] Cleanup command removes all M04 test data
- [ ] All tests pass with `@pytest.mark.tdd_green`
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m01-e05-t01 (E2E test data infrastructure baseline)
- Requires: m02-e01 (JWT authentication implementation)
- Requires: m04-e01, m04-e02, m04-e03 (flyer creation, editing, deletion models)
- Blocks: All other m04-e04 E2E test tasks

## Technical Notes
- **JWT Tokens**: Pre-generate valid tokens for test users (avoid auth flow in every test)
- **User States**: Create users with different flyer counts (0, 1, 5, 20) for profile scenarios
- **Flyer States**: Include active (valid_to > now), expired (valid_to < now), near-expiration (valid_to within 24h)
- **Deterministic Data**: Use consistent seed for reproducible test data
- **Performance**: Seeding should complete in <30 seconds
- **Isolation**: M04 test data tagged separately from M01-M03 data
