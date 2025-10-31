---
id: m04-e04-t16
title: E2E Test - M01 M04 Feed Integration Works Correctly
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - M01 M04 Feed Integration Works Correctly

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates seamless integration between M01 anonymous browsing and M04 flyer creation: created/edited/deleted flyers update feed correctly, ranking works, all M01 features work with M04 data end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating M01-M04 feed integration through real system stack.

### Steps

1. Create Maestro E2E test file for M01-M04 integration
   - Create file `pockitflyer_app/maestro/flows/m04-e04/m01_m04_feed_integration.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed M01 test data (100+ existing flyers) and M04 authenticated user
   - Launch iOS app → authenticate

2. Implement created flyers in feed test
   - Test: 'M04 created flyers appear in M01 feed correctly'
   - Create new flyer via M04 workflow
   - Navigate to feed (M01 browse screen)
   - Assert: New flyer appears in feed with existing flyers
   - Assert: New flyer card format matches M01 card format
   - Assert: All M01 fields displayed: creator, image, distance, category, dates
   - Tap flyer → M01 detail screen opens with all fields

3. Implement feed ranking test
   - Test: 'M04 flyers ranked correctly in feed (distance-based)'
   - Create flyer at specific location (e.g., Bahnhofstrasse, Zurich)
   - Set test user location (e.g., Paradeplatz, Zurich ~500m away)
   - Navigate to feed
   - Assert: Flyer appears in appropriate position based on distance
   - Verify: Feed sorted by distance from user location (M01 ranking)
   - Assert: Closer flyers appear before distant flyers

4. Implement M01 filters work with M04 flyers test
   - Test: 'M01 category and distance filters work with M04 flyers'
   - Create flyer with category "Events"
   - Navigate to feed → apply "Events" category filter (M01 feature)
   - Assert: Created flyer appears in filtered results
   - Create flyer with category "Nightlife"
   - Apply "Near Me" filter (M01 feature) → radius 1km
   - Assert: Only nearby flyers displayed (including M04 flyers within radius)

5. Implement deleted flyers removal test
   - Test: 'M04 deleted flyers removed from M01 feed immediately'
   - Note existing flyer in feed (from M04 creation)
   - Delete flyer via M04 workflow
   - Navigate to feed → pull-to-refresh
   - Assert: Deleted flyer NOT visible in feed
   - Verify: Feed displays remaining flyers correctly

6. Add cleanup
   - Cleanup: Delete created test flyers
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] M04 created flyers appear in M01 feed with correct format [Maestro: create → feed → verify card format]
- [ ] M01 ranking works with M04 flyers [Maestro: verify distance-based sort order]
- [ ] M01 filters work with M04 flyers [Maestro: apply filter → verify M04 flyers included/excluded]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/m01_m04_feed_integration.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for M01-M04 integration. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, feed API

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] M04 created flyers display correctly in M01 feed
- [ ] Feed ranking (distance-based) works with M04 flyers
- [ ] M01 category and distance filters work with M04 flyers
- [ ] Deleted M04 flyers removed from feed
- [ ] No regressions in M01 functionality
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m01-e01 (Feed browsing implementation)
- Requires: m01-e02 (Filter and search implementation)
- Requires: m04-e01 (Flyer creation implementation)
- Requires: m04-e03 (Flyer deletion implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Mix of M01 seeded flyers (100+) and M04 created flyers
- **Feed API**: Single endpoint returns all flyers (M01 + M04 data)
- **Ranking algorithm**: Distance-based (haversine formula)
- **Filter logic**: Category and distance filters apply to all flyers
- **Performance**: Feed with 100+ flyers should load within 2 seconds
- **Card format**: M04 flyers use same FlyerCard widget as M01
- **No separation**: Users cannot distinguish M01 vs M04 flyers (seamless integration)
