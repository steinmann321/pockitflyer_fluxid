---
id: m01-e02-t11
title: E2E Near Me Filter Deactivation
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Near Me Filter Deactivation

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates Near Me filter deactivation end-to-end with NO MOCKS. Tests user action: toggling Near Me filter off and verifying feed returns to showing all flyers regardless of distance. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating Near Me filter deactivation restores distance-unrestricted feed.

### Steps

1. Create E2E test file for Near Me deactivation
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_near_me_filter_toggle_off.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User toggles Near Me filter off
   - Launch app
   - Wait for feed to load
   - Record initial feed count (all distances)
   - Tap "Near Me" filter to activate
   - Verify feed shows only nearby flyers (count reduces)
   - Tap "Near Me" filter again to deactivate
   - Verify Near Me filter shows inactive state
   - Verify feed returns to showing all flyers
   - Assert feed includes flyers beyond 5km

3. Add verification for distance restoration
   - Scroll through feed
   - Verify flyers at all distances appear
   - Verify feed count matches initial unfiltered state
   - Assert no proximity restriction applied

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document toggle behavior in test comments

### Acceptance Criteria
- [ ] Deactivating Near Me filter shows all flyers regardless of distance [Verify: Feed includes distant flyers]
- [ ] Filter UI shows inactive state [Verify: Visual indicator removed]
- [ ] Test validates state transition against real backend [Verify: Backend returns unfiltered by location]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_near_me_filter_toggle_off.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for Near Me filter deactivation. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates filter state transition with real data
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t05

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t04-e2e-near-me-filter (Near Me activation working)
- Requires: Backend API endpoints for location-based filtering
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers at various distances
- **State transition**: Near Me on → Near Me off → all distances visible
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
