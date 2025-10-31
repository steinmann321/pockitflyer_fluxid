---
id: m04-e04-t18
title: E2E Test - M03 M04 Profile Integration Works Correctly
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - M03 M04 Profile Integration Works Correctly

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates M03-M04 profile integration: created flyers appear on creator profile, profile flyer count updates, profile picture displays on flyer cards, "My Flyers" section works correctly end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating M03-M04 profile integration through real system stack.

### Steps

1. Create Maestro E2E test file for profile integration
   - Create file `pockitflyer_app/maestro/flows/m04-e04/m03_m04_profile_integration.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with profile picture and 5 existing flyers
   - Launch iOS app → authenticate

2. Implement profile flyer count test
   - Test: 'Profile flyer count updates with M04 creation/deletion'
   - Navigate to profile (M03 feature)
   - Assert: Profile shows "5 Flyers" count
   - Create new flyer via M04 workflow
   - Navigate to profile
   - Assert: Profile shows "6 Flyers" count (incremented)
   - Delete one flyer via M04 workflow
   - Navigate to profile
   - Assert: Profile shows "5 Flyers" count (decremented)

3. Implement "My Flyers" section test
   - Test: 'My Flyers section displays M04 created/edited flyers'
   - Navigate to profile → "My Flyers" section (M03 feature)
   - Assert: All 5 owned flyers displayed
   - Create new flyer with title "New Profile Test Flyer"
   - Navigate to profile → "My Flyers"
   - Assert: 6 flyers displayed (new flyer at top)
   - Assert: New flyer title visible "New Profile Test Flyer"

4. Implement profile picture on flyer cards test
   - Test: 'Creator profile picture displays on M04 flyer cards'
   - Ensure test user has profile picture (M03 feature)
   - Create new flyer via M04 workflow
   - Navigate to main feed
   - Find created flyer card
   - Assert: Flyer card displays creator profile picture (M03 data)
   - Tap profile picture → creator profile opens (M03 feature)

5. Implement edit from profile test
   - Test: 'Edit flyer from profile My Flyers section'
   - Navigate to profile → "My Flyers"
   - Tap flyer → edit screen opens (M04 feature)
   - Edit flyer title → save changes
   - Navigate back to profile → "My Flyers"
   - Assert: Edited flyer shows updated title in profile list

6. Implement profile updates after edits test
   - Test: 'Profile reflects M04 flyer edits (image, title)'
   - Navigate to profile → "My Flyers"
   - Note flyer thumbnail image
   - Edit flyer → change first image → save
   - Navigate to profile → "My Flyers"
   - Assert: Flyer thumbnail shows new image

7. Add cleanup
   - Cleanup: Delete created test flyers
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Profile flyer count updates with M04 creation/deletion [Maestro: create → profile → verify count +1]
- [ ] "My Flyers" displays M04 flyers correctly [Maestro: profile → assertVisible created flyer]
- [ ] Creator profile picture displays on M04 flyer cards [Maestro: feed → verify profile picture on card]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/m03_m04_profile_integration.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for M03-M04 profile integration. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, profile API

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Profile flyer count updates correctly
- [ ] "My Flyers" section displays M04 created/edited flyers
- [ ] Profile picture displays on M04 flyer cards
- [ ] Edit from profile works seamlessly
- [ ] Profile reflects M04 flyer edits
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m02-e02 (User profile implementation)
- Requires: m03-e04 (Authenticated engagement features)
- Requires: m04-e01, m04-e02, m04-e03 (All M04 feature implementations)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Seed user with profile picture and existing flyers
- **Profile API**: GET /api/users/me/ returns flyer count and profile data
- **My Flyers API**: GET /api/users/me/flyers/ returns owned flyers
- **Profile picture**: Displayed on flyer cards via creator relationship
- **Performance**: Profile should load with updated count within 2 seconds
- **Real-time updates**: Profile updates immediately after creation/deletion
- **Thumbnail updates**: Profile flyer thumbnails reflect image edits
