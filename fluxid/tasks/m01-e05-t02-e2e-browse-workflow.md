---
id: m01-e05-t02
epic: m01-e05
title: E2E Test - Complete Browse Workflow (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Browse Workflow (No Mocks)

## Objective
Validate complete browse flyers feed workflow end-to-end using real Django backend, real SQLite database, real geopy geocoding, and real iOS app with no mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_browse_complete.yaml`
- [ ] Test steps:
  1. Start real Django backend (via helper script)
  2. Seed E2E test data (100+ flyers)
  3. Launch iOS app (fresh install state)
  4. Grant location permission
  5. Assert feed loading indicator appears
  6. Assert feed loads with flyer cards
  7. Verify all flyer card fields: creator name, image, title, description, distance, validity date
  8. Verify distance calculations accurate (compare to expected distances from test data)
  9. Scroll to trigger pagination
  10. Assert additional flyers load from backend
  11. Pull-to-refresh gesture
  12. Modify backend data (add new flyer via Django admin/script)
  13. Pull-to-refresh again
  14. Assert new flyer appears in feed
  15. Cleanup: stop backend, reset database
- [ ] Real service validations:
  - Backend API endpoint returns actual flyer JSON
  - Database query results match feed display
  - Geocoding coordinates accurate (verified against geopy directly)
  - Image URLs load and display correctly
- [ ] Performance under realistic conditions:
  - Feed loads in <2 seconds (100+ flyers in database)
  - Distance calculations complete in <500ms
  - Pagination smooth (no lag when scrolling)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete vertical slice: iOS app → REST API → Django → SQLite → geopy
- Location permission grant flow
- Feed loading with real backend data
- All flyer field accuracy (no mock data mismatches)
- Distance calculation accuracy (within 100m tolerance)
- Pagination with real database queries
- Pull-to-refresh with real database updates
- Image loading and display from backend storage
- Empty feed state (test with 0 flyers in database)
- Network error handling (stop backend mid-test, verify error UI)

## Files to Modify/Create
- `maestro/flows/m01-e05/browse_complete_workflow.yaml`
- `maestro/flows/m01-e05/browse_empty_state.yaml`
- `maestro/flows/m01-e05/browse_network_error.yaml`
- `scripts/start_backend_e2e.sh` (helper script for detached backend start)
- `scripts/stop_backend_e2e.sh` (helper script for clean shutdown)
- `pockitflyer_backend/scripts/add_flyer_during_test.py` (simulate data change)

## Dependencies
- m01-e05-t01 (E2E test data infrastructure)
- m01-e01-t01 through m01-e01-t08 (all browse epic implementation)
- m01-e01-t09 (basic E2E browse flow, which this extends)

## Notes
**Critical: NO MOCKS**
- Real Django server running on localhost
- Real SQLite database with test data
- Real geopy geocoding (addresses pre-geocoded in test data, but service available)
- Real iOS app making actual HTTP requests
- Real location services on iOS simulator

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode, kills any existing instances first
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app for E2E testing
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all E2E services

**Distance Verification**:
- Test data includes known flyer locations
- Pre-calculate expected distances using same geopy haversine formula
- Assert displayed distance matches expected within 100m tolerance

**Data Modification Test**:
- Pull-to-refresh test validates real backend updates appear in app
- Use Django management command to add flyer during test run
- Verify new flyer appears in feed after refresh

**Performance Validation**:
- 100+ flyers in database provides realistic load
- Measure time from launch to feed display (<2s)
- Measure query time for filtered/paginated results (<500ms)
- No test-specific performance optimizations (validates production performance)

**Error Scenarios**:
1. Empty database (0 flyers) - should show empty state UI
2. Backend unavailable - should show network error with retry button
3. Location permission denied - should show permission request UI
