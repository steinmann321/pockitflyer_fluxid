---
id: m01-e07-t02
title: Anonymous Browsing User Journey E2E Validation
epic: m01-e07
milestone: m01
status: pending
---

# Task: Anonymous Browsing User Journey E2E Validation

## Context
Part of E2E Milestone Validation (m01-e07) in Milestone 01 (m01).

Validates the anonymous user browsing workflow end-to-end with NO MOCKS (launch → load feed → scroll → images → distances).

## Implementation Guide for LLM Agent

### Objective
Create an E2E test validating anonymous browsing using real backend, DB, geopy.

### Steps

1. Create E2E test file
   - Path: `pockitflyer_app/integration_test/anonymous_browsing_test.dart`
   - Import: `integration_test`, `flutter_test`, app entry `main.dart`, `test_config.dart`, `helpers/test_helpers.dart`
   - Setup binding and test group per project conventions

2. Implement scenario
   - Test: 'App launches and loads flyer feed from backend'
   - User scrolls through feed and views images
   - Verify distances shown when location enabled
   - Verify data matches backend response

3. Utilities and cleanup
   - Use helpers for backend readiness, widget finders, screenshots
   - Mark tests with TDD tags only after verifying passing

### Acceptance Criteria
- [ ] Feed loads from real backend [Verify: visible flyer cards]
- [ ] Scrolling works smoothly [Verify: more items visible after scroll]
- [ ] Images load from real URLs [Verify: placeholders replaced]
- [ ] Distances display when location enabled [Verify: realistic values]

### Files to Create/Modify
- `pockitflyer_app/integration_test/anonymous_browsing_test.dart` – NEW
- `pockitflyer_app/integration_test/helpers/test_helpers.dart` – MODIFY (add browsing helpers if needed)

### Testing Requirements
- Run against real backend; no mocks.

### Definition of Done
- [ ] Test passes end-to-end against backend
- [ ] Evidence captured (screenshots/logs)
- [ ] Changes committed with reference to m01-e07-t02

## Dependencies
- Requires: m01-e07-t01 (E2E environment setup)

## Technical Notes
- Ensure backend started via `scripts/start_e2e_backend.sh`

## References
- Existing integration tests in `pockitflyer_app/integration_test/`

