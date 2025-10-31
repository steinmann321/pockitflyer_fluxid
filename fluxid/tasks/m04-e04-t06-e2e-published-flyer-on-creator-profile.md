---
id: m04-e04-t06
title: E2E Test - Published Flyer Appears on Creator Profile
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Published Flyer Appears on Creator Profile

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates M03-M04 integration: newly published flyer appears on creator's profile page with correct data end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating published flyer visibility on creator profile through real system stack.

### Steps

1. Create Maestro E2E test file for profile integration
   - Create file `pockitflyer_app/maestro/flows/m04-e04/published_flyer_on_profile.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user (use M04 test fixtures)
   - Launch iOS app → authenticate

2. Implement create-and-verify-on-profile test
   - Test: 'Published flyer appears on own profile page'
   - Navigate to creation screen (Flyern button)
   - Create new flyer:
     - Title: "Profile Test Flyer [timestamp]"
     - Description: "Test flyer for profile verification"
     - Category: "Service"
     - Address: "Paradeplatz, 8001 Zurich"
     - Valid from: today, Valid to: +30 days
     - Upload 1 test image
   - Tap "Publish" → wait for success message
   - Navigate to profile (tap user avatar in header)
   - Assert: Profile screen shows "My Flyers" section
   - Assert: Newly created flyer appears in "My Flyers" list
   - Assert: Flyer card shows correct title "Profile Test Flyer [timestamp]"
   - Assert: Flyer card shows correct image
   - Assert: Flyer card shows "Active" status indicator
   - Tap on flyer → detail/edit screen opens
   - Assert: Detail shows all flyer fields correctly

3. Add flyer count verification test
   - Test: 'Profile flyer count increments after creation'
   - Note initial flyer count on profile (e.g., "5 Flyers")
   - Create new flyer (as above)
   - Navigate to profile
   - Assert: Flyer count incremented by 1 (e.g., "6 Flyers")

4. Add cleanup
   - Cleanup: Delete created test flyer from database
   - Verify: Profile flyer count decrements after cleanup
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Published flyer appears in "My Flyers" on profile [Maestro: create → profile → assertVisible flyer title]
- [ ] Profile flyer count increments after creation [Maestro: verify count before/after]
- [ ] Tapping flyer opens detail/edit screen [Maestro: tapOn flyer → assertVisible edit fields]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/published_flyer_on_profile.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for M03-M04 profile integration. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, profile API

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Created flyer appears on creator's profile immediately after publishing
- [ ] Profile flyer count updates correctly
- [ ] Flyer card on profile displays status (active/expired)
- [ ] Backend profile API returns newly created flyer
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t04 (User creates flyer workflow)
- Requires: m02-e02 (User profile implementation)
- Requires: m04-e02 (View own flyers on profile)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Profile API**: Uses authenticated user's JWT to fetch owned flyers
- **Flyer ordering**: Profile flyers typically sorted by creation time desc
- **Status indicator**: Active flyers show "Active" badge, expired show "Expired"
- **Performance**: Profile should load with updated flyer count within 2 seconds
- **Timestamp**: Use unique timestamp in title to identify test flyer
- **Cleanup**: Verify profile updates after flyer deletion (count decrements)
- **Navigation**: Profile accessible via header avatar or navigation menu
