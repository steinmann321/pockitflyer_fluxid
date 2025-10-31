---
id: m04-e04-t04
title: E2E Test - User Fills Flyer Fields and Publishes
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Fills Flyer Fields and Publishes

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates complete flyer creation form workflow (title, description, category, address, dates) with real geocoding service and database persistence end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating flyer creation form submission through real system stack.

### Steps

1. Create Maestro E2E test file for form submission
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_creates_complete_flyer.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user (use M04 test fixtures)
   - Launch iOS app → authenticate → navigate to creation screen

2. Implement complete form submission test
   - Test: 'User creates flyer with all required fields'
   - Upload 1 image (reuse image upload from t03)
   - Tap "Title" field → input "Test Event Flyer"
   - Tap "Description" field → input "Join us for an amazing event"
   - Tap "Category" dropdown → select "Events"
   - Tap "Address" field → input "Bahnhofstrasse 1, 8001 Zurich"
   - Tap "Valid From" date picker → select today's date
   - Tap "Valid To" date picker → select date 7 days from now
   - Tap "Publish" button → loading indicator appears
   - Assert: Success message appears
   - Assert: App navigates back to feed or profile
   - Verify: Backend logs show POST /api/flyers/ request
   - Verify: Database contains new flyer record
   - Verify: Geocoding service called for address (backend logs show geopy request)
   - Verify: Flyer has latitude/longitude from geocoding

3. Add validation test
   - Test: 'Publish button disabled until required fields filled'
   - Navigate to creation screen
   - Assert: Publish button disabled initially
   - Fill only title field → Publish still disabled
   - Fill title + image → Publish still disabled
   - Fill all required fields → Publish button enabled

4. Add cleanup
   - Cleanup: Delete created test flyer from database
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User fills all required fields and publishes [Maestro: inputText → tapOn "Publish" → assertVisible "Success"]
- [ ] Backend creates flyer in database [Verify: database query shows new flyer record]
- [ ] Geocoding service converts address to coordinates [Verify: backend logs show geopy call, flyer has lat/lng]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_creates_complete_flyer.yaml` - NEW: E2E test
- `pockitflyer_backend/users/tests/utils/verify_flyer_creation.py` - NEW: Helper to verify database state

### Testing Requirements
**Note**: This task IS the E2E testing for flyer creation. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, geocoding service

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Complete flyer creation workflow works end-to-end
- [ ] Flyer persisted in database with all fields
- [ ] Geocoding service converts address to coordinates
- [ ] Backend logs show API request and geocoding call
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t02 (Authenticated user Flyern access)
- Requires: m04-e04-t03 (Image upload workflow)
- Requires: m04-e01 (Flyer creation form implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Geocoding**: Backend calls real geopy service during creation (NOT mocked)
- **Test address**: Use known Zurich address for consistent geocoding results
- **Expected coordinates**: Bahnhofstrasse 1, Zurich ≈ (47.3769, 8.5417)
- **Performance**: Flyer creation with geocoding should complete in <3 seconds
- **Date handling**: Use relative dates (today, today+7days) for deterministic tests
- **Validation**: All required fields must be filled before publish button enables
- **Cleanup**: Delete test flyer using Django ORM after test completes
