---
id: m02-e04-t01
epic: m02-e04
title: E2E Test Data Infrastructure for M02 Authentication
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test Data Infrastructure for M02 Authentication

## Objective
Extend E2E test data seeding infrastructure to support M02 authentication and profile management workflows including realistic user accounts, authentication tokens, profile data, and privacy settings.

## Acceptance Criteria
- [ ] Django management command: `python manage.py seed_m02_e2e_data` creates M02-specific test dataset
- [ ] 30+ test user accounts with authentication credentials:
  - Email addresses: Realistic format (test1@example.com through test30@example.com)
  - Passwords: Hashed with Django's password hashers (plaintext for test docs: "TestPass123!")
  - Mix of active and inactive accounts
  - Mix of email_verified: True/False states
- [ ] 30+ user profiles (auto-created with user accounts):
  - Profile pictures: 70% have uploaded pictures (realistic test images)
  - Display names: Mix of full names, usernames, nicknames
  - Bios: 60% have bios (various lengths: short, medium, long)
  - Profile creation dates: Mix of old (6+ months) and new (recent)
- [ ] Privacy settings for all users:
  - Email permissions: Mix of True/False (70% opted in)
  - Profile visibility: All public (for M02, private profiles come later)
  - Settings creation dates match profile creation dates
- [ ] JWT token test utilities:
  - Function to generate valid tokens for any test user
  - Function to generate expired tokens (for token expiration tests)
  - Function to generate invalid tokens (for security tests)
- [ ] Link test users to M01 flyers:
  - Distribute M01 test flyers among M02 test users as creators
  - Ensure creator profile pictures visible on flyer cards
  - Some users with 0 flyers, some with 1-5, some with 10+ (realistic distribution)
- [ ] Database cleanup command: `python manage.py cleanup_m02_e2e_data`
- [ ] Idempotent seeding (can run multiple times without duplicates)
- [ ] Deterministic data (same seed produces same dataset for reproducible tests)
- [ ] All test data tagged with `is_e2e_test_data=True` flag
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Management command execution (seed_m02_e2e_data and cleanup_m02_e2e_data)
- User account creation with hashed passwords
- Profile auto-creation on user creation
- Privacy settings auto-creation on user creation
- JWT token generation utilities (valid, expired, invalid)
- Profile picture storage and retrieval
- Link users to flyers (creator relationships)
- Idempotency (running seed twice doesn't duplicate users/profiles)
- Cleanup completeness (all M02 test data removed, M01 test data preserved)
- Performance (seeding completes in <15 seconds)

## Files to Modify/Create
- `pockitflyer_backend/users/management/commands/seed_m02_e2e_data.py`
- `pockitflyer_backend/users/management/commands/cleanup_m02_e2e_data.py`
- `pockitflyer_backend/users/tests/test_m02_e2e_data_seeding.py`
- `pockitflyer_backend/users/fixtures/m02_test_users.json` (email, name, bio templates)
- `pockitflyer_backend/users/fixtures/m02_test_profile_pictures/` (test images directory)
- `pockitflyer_backend/users/utils/e2e_token_helpers.py` (JWT token utilities for E2E tests)

## Dependencies
- m01-e05-t01 (M01 E2E test data infrastructure must exist)
- m02-e01-t02 (JWT authentication must be implemented)
- m02-e02-t01 (Profile model and auto-creation must exist)
- m02-e03-t01 (Privacy settings model must exist)

## Notes
**Test User Email Format**:
- `test_user_001@pockitflyer.test` through `test_user_030@pockitflyer.test`
- Use `.test` TLD to avoid accidental real email sends
- All emails deterministic and sortable

**Password Strategy**:
- Same password for all test accounts: "TestPass123!"
- Document in E2E test README for manual testing
- Use Django's `make_password()` for hashing in seed script

**Profile Picture Strategy**:
- Store 20-30 realistic test images in `fixtures/m02_test_profile_pictures/`
- Images should be diverse (different genders, ages, styles)
- Use free/public domain images (e.g., UI Faces, RandomUser.me)
- Images sized appropriately (200x200px, <100KB each)

**JWT Token Utilities**:
```python
# pockitflyer_backend/users/utils/e2e_token_helpers.py
def generate_valid_token(user):
    """Generate valid JWT token for user (for E2E auth setup)"""

def generate_expired_token(user):
    """Generate expired JWT token (for token expiration tests)"""

def generate_invalid_token():
    """Generate malformed JWT token (for security tests)"""
```

**Creator-Flyer Linking**:
- Update M01 flyers to have creators from M02 test users
- Ensure variety: some users with many flyers, some with few, some with none
- Update `seed_e2e_data` to call `seed_m02_e2e_data` automatically (dependency chain)

**Cleanup Strategy**:
- `cleanup_m02_e2e_data` removes users, profiles, privacy settings
- Does NOT remove flyers (handled by `cleanup_e2e_data`)
- Cascading delete handles profile pictures (Django FileField cleanup)

**Performance Considerations**:
- Bulk create operations for users, profiles, settings
- Pre-hash passwords before bulk create (faster than post-save signals)
- Use transactions for atomic seeding (all-or-nothing)

**Test Data Markers**:
- All users: `is_e2e_test_data=True` flag
- All profiles: linked to users with `is_e2e_test_data=True`
- Cleanup queries filter by this flag for safe deletion
