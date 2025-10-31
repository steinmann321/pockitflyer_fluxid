---
id: m01-e07-t03
title: Filter and Search Workflows E2E Validation
epic: m01-e07
milestone: m01
status: pending
---

# Task: Filter and Search Workflows E2E Validation

## Context
Part of E2E Milestone Validation (m01-e07) in Milestone 01 (m01).

Validates category filtering, proximity filtering, and search end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create an E2E test validating filter/search using real backend query processing and geopy distances.

### Steps

1. Create E2E test file
   - Path: `pockitflyer_app/integration_test/filter_search_test.dart`
   - Import: `integration_test`, `flutter_test`, app entry, `test_config.dart`, `helpers/test_helpers.dart`
   - Setup binding and test group per project conventions

2. Implement scenarios
   - Test: 'Category filter applies via backend' (Events/Nightlife/Service)
   - Test: 'Proximity filter uses real geopy distances' (e.g., ≤5 km)
   - Test: 'Search updates results in real-time'

3. Utilities and cleanup
   - Use helpers; update helpers if needed for filter/search verification

### Acceptance Criteria
- [ ] Category filtering shows only matching flyers [Verify: badges]
- [ ] Proximity filtering respects distance thresholds [Verify: ≤ selected km]
- [ ] Search updates results from backend [Verify: query reflected]

### Files to Create/Modify
- `pockitflyer_app/integration_test/filter_search_test.dart` – NEW
- `pockitflyer_app/integration_test/helpers/test_helpers.dart` – MODIFY (add filter/search helpers)

### Testing Requirements
- Run against real backend and database; no mocks.

### Definition of Done
- [ ] All filter/search tests pass on real backend
- [ ] Evidence captured (screenshots/logs)
- [ ] Changes committed with reference to m01-e07-t03

## Dependencies
- Requires: m01-e07-t01 (E2E environment setup)

## Technical Notes
- Location must be enabled for proximity testing when applicable

## References
- Integration test patterns in `pockitflyer_app/integration_test/`

