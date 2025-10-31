---
id: m01-e02-t04
title: E2E Near Me Filter Toggle
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Near Me Filter Toggle

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates Near Me location filter end-to-end with NO MOCKS. Tests user action: toggling Near Me filter and verifying feed shows only flyers within proximity threshold (5km). Uses real backend, real database, real geocoding services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating Near Me filter shows flyers within proximity threshold.

### Steps

1. Create E2E test file for Near Me filter
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_near_me_filter.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User toggles Near Me filter
   - Launch app
   - Wait for feed to load with location permission granted
   - Record initial feed state (all flyers regardless of distance)
   - Tap on "Near Me" filter toggle/button
   - Verify Near Me filter shows active state
   - Verify feed updates to show only nearby flyers
   - Assert all visible flyers show distance ≤ 5km
   - Verify flyers beyond 5km are excluded from feed

3. Add proximity verification
   - Scroll through filtered feed
   - Verify each flyer displays distance indicator
   - Assert no flyer exceeds 5km proximity threshold
   - Verify feed count reduces appropriately

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document proximity threshold (5km) in test comments

### Acceptance Criteria
- [ ] Near Me filter shows only flyers within 5km [Verify: All visible flyers show distance ≤ 5km]
- [ ] Filter UI shows active state [Verify: Visual indicator shows Near Me active]
- [ ] Test validates proximity filtering against real data [Verify: Backend uses real geocoding]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_near_me_filter.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for Near Me filter. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, geocoding services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates proximity calculations with real geocoding
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t04

## Dependencies
- Requires: m01-e01 (Feed browsing functional with location services)
- Requires: Backend API endpoints for location-based filtering
- Requires: Location permission granted in test environment
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers at various distances from test location
- **Proximity threshold**: 5km radius (configurable per epic notes)
- **Location permission**: Test assumes location permission granted
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
