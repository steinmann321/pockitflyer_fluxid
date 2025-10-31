---
id: m04-e04-t05
title: E2E Test - Published Flyer Appears in Main Feed
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Published Flyer Appears in Main Feed

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates M01-M04 integration: newly published flyer appears in main feed with correct data, images, creator info, and distance calculations end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating published flyer visibility in feed through real system stack.

### Steps

1. Create Maestro E2E test file for feed integration
   - Create file `pockitflyer_app/maestro/flows/m04-e04/published_flyer_in_feed.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user and existing feed flyers (use M04 test fixtures)
   - Launch iOS app → authenticate

2. Implement create-and-verify-in-feed test
   - Test: 'Published flyer appears in main feed with all data'
   - Navigate to creation screen (Flyern button)
   - Create new flyer:
     - Title: "New Test Flyer Created at [timestamp]"
     - Description: "Description for test flyer"
     - Category: "Events"
     - Address: "Bahnhofstrasse 1, 8001 Zurich"
     - Valid from: today, Valid to: +7 days
     - Upload 1 test image
   - Tap "Publish" → wait for success message
   - Navigate to feed (home/browse screen)
   - Scroll to find newly created flyer (should be near top, sorted by creation time)
   - Assert: Flyer card displays with correct title "New Test Flyer Created at [timestamp]"
   - Assert: Flyer card shows correct creator name (authenticated user's name)
   - Assert: Flyer card shows creator profile picture (if user has one)
   - Assert: Flyer card shows uploaded image
   - Assert: Flyer card shows distance from current location
   - Assert: Flyer card shows category tag "Events"
   - Tap on flyer card → detail screen opens
   - Assert: Detail screen shows all fields correctly (title, description, address, dates)

3. Add timestamp verification test
   - Test: 'Flyer timestamp accurate and visible'
   - Find created flyer in feed
   - Assert: "Created just now" or "Created 1m ago" timestamp visible
   - Verify: Backend database record has matching created_at timestamp

4. Add cleanup
   - Cleanup: Delete created test flyer from database
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Published flyer appears in main feed [Maestro: create flyer → navigate feed → assertVisible flyer title]
- [ ] Flyer displays all data correctly [Maestro: verify title, creator, image, distance, category]
- [ ] Tapping flyer opens detail screen with complete info [Maestro: tapOn flyer → assertVisible detail fields]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/published_flyer_in_feed.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for M01-M04 feed integration. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, feed API

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Created flyer appears in main feed immediately after publishing
- [ ] Flyer card displays all fields accurately (creator, image, distance, category)
- [ ] Detail screen shows complete flyer information
- [ ] Backend feed API returns newly created flyer
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t04 (User creates flyer workflow)
- Requires: m01-e01 (Feed browsing implementation)
- Requires: m04-e01 (Flyer creation implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Feed sorting**: New flyers should appear near top (sorted by creation time desc)
- **Creator info**: Flyer card shows authenticated user's profile data
- **Distance calculation**: Uses geocoded coordinates from creation + user's test location
- **Performance**: Flyer should appear in feed within 2 seconds of navigation
- **Timestamp**: Use unique timestamp in title to identify test flyer (avoid conflicts)
- **Scroll behavior**: May need to scroll feed to find flyer if many test flyers exist
- **Cleanup**: Delete test flyer after verification to avoid cluttering feed
