---
id: m01-e01-t09
epic: m01-e01
title: E2E Test - Browse Flyers Feed Flow
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Browse Flyers Feed Flow

## Objective
Create end-to-end Maestro test flow for browsing local flyers feed including location permission and pull-to-refresh.

## Acceptance Criteria
- [ ] Maestro flow: `browse_local_feed.yaml`
- [ ] Test steps:
  1. Launch app (fresh install state)
  2. Assert location permission prompt appears
  3. Grant location permission
  4. Assert feed loading indicator appears
  5. Assert feed loads with flyer cards visible
  6. Assert first flyer card contains: creator name, image, title, description, distance, validity
  7. Scroll down to trigger pagination
  8. Assert more flyers load
  9. Pull-to-refresh gesture
  10. Assert feed refreshes (loading indicator, then new/updated content)
- [ ] Test data: Backend seeded with 30 test flyers at various distances
- [ ] Test assertions: visual elements, data accuracy, timing
- [ ] Test cleanup: reset app state and backend data after test
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete user flow from launch to browsing
- Location permission handling (granted scenario)
- Feed load performance (<2 seconds)
- Flyer card data display accuracy
- Infinite scroll pagination
- Pull-to-refresh functionality
- Empty state (separate test scenario)
- Error state with retry (separate test scenario)

## Files to Modify/Create
- `maestro/flows/m01-e01/browse_local_feed.yaml`
- `maestro/flows/m01-e01/browse_feed_empty_state.yaml`
- `maestro/flows/m01-e01/browse_feed_error_retry.yaml`
- `pockitflyer_backend/scripts/seed_test_data.py` (test data seeding)

## Dependencies
- m01-e01-t01 through m01-e01-t08 (all implementation tasks)
- Maestro E2E framework setup (from earlier baseline commit)

## Notes
- Run backend and app via helper scripts before running Maestro
- Use Maestro's location mocking to simulate specific GPS coordinates
- Test data includes flyers at 0.5km, 2km, 5km, 10km+ distances
- Verify distance calculations are accurate within 100m
- Test scenarios: normal flow, no permission (denied), no network, empty feed
