---
id: m01-e07-t01
title: E2E Test Environment Setup (Real Backend, Database, geopy)
epic: m01-e07
milestone: m01
status: pending
---

# Task: E2E Test Environment Setup (Real Backend, Database, geopy)

## Context
Part of E2E Milestone Validation (m01-e07) in Milestone 01 (m01).

Validates environment setup end-to-end with NO MOCKS. Establishes real Django backend, real SQLite test database, real geopy service, and Flutter integration test configuration used by all m01 E2E tasks.

## Implementation Guide for LLM Agent

### Objective
Create a fully functional E2E test environment using the project’s actual stack and paths.

### Steps

1. Backend E2E config and setup
   - Create `pockitflyer_backend/e2e_test_config.py` (enable E2E mode, SQLite test DB, settings)
   - Create `pockitflyer_backend/management/commands/setup_e2e_env.py` (migrate, init config)
   - Create `pockitflyer_backend/fixtures/e2e_test_data.json` (30 flyers, 6 creators, images, edge cases)
   - Create `pockitflyer_backend/management/commands/seed_e2e_data.py` (load fixtures, geocode with geopy)

2. Startup and verification scripts
   - Create `scripts/start_e2e_backend.sh` (setup_e2e_env → seed_e2e_data → runserver 8000)
   - Create `scripts/verify_e2e_env.sh` (curl API, data counts, geopy check)

3. Flutter integration test config
   - Create `pockitflyer_app/integration_test/test_config.dart` (base URL, coordinates, timeouts)
   - Create `pockitflyer_app/integration_test/helpers/test_helpers.dart` (backend checks, helpers)
   - Create `pockitflyer_app/integration_test/test_driver.dart` (driver init, timeouts, reporting)

4. Verification test
   - Create `pockitflyer_app/integration_test/environment_verification_test.dart` (API reachable, data present, geocoded coordinates, image URLs respond)

### Acceptance Criteria
- [ ] Backend starts with E2E config [Verify: `scripts/start_e2e_backend.sh` runs]
- [ ] Test data seeded and geocoded [Verify: `seed_e2e_data.py` outputs counts]
- [ ] Flutter tests can reach API [Verify: environment verification test passes]

### Files to Create/Modify
- `pockitflyer_backend/e2e_test_config.py` – NEW
- `pockitflyer_backend/management/commands/setup_e2e_env.py` – NEW
- `pockitflyer_backend/fixtures/e2e_test_data.json` – NEW
- `pockitflyer_backend/management/commands/seed_e2e_data.py` – NEW
- `scripts/start_e2e_backend.sh` – NEW
- `scripts/verify_e2e_env.sh` – NEW
- `pockitflyer_app/integration_test/test_config.dart` – NEW
- `pockitflyer_app/integration_test/helpers/test_helpers.dart` – NEW
- `pockitflyer_app/integration_test/test_driver.dart` – NEW
- `pockitflyer_app/integration_test/environment_verification_test.dart` – NEW
- `pockitflyer_backend/docs/e2e_setup.md` – NEW

### Testing Requirements
- E2E environment only; all services real. No mocks.

### Definition of Done
- [ ] Scripts and config in place, run successfully
- [ ] Environment verification test passes
- [ ] Changes committed with reference to m01-e07-t01

## Dependencies
- Requires: m01-e01..m01-e06 implemented and running

## Technical Notes
- Backend must be running before Flutter integration tests
- Use San Francisco coordinates for default test location (37.7749, -122.4194)

## References
- Integration tests under `pockitflyer_app/integration_test/`

