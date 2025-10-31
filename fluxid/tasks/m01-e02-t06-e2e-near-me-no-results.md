---
id: m01-e02-t06
title: E2E Near Me Filter Empty State
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Near Me Filter Empty State

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates Near Me filter empty state end-to-end with NO MOCKS. Tests user action: toggling Near Me filter when no flyers exist within proximity threshold and verifying appropriate empty state message. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating Near Me filter shows empty state when no nearby flyers exist.

### Steps

1. Create E2E test file for Near Me empty state
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_near_me_empty_state.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User sees empty state for Near Me
   - Launch app
   - Wait for feed to load
   - Set test location where no flyers exist within 5km (or use test data setup)
   - Tap "Near Me" filter to activate
   - Verify Near Me filter shows active state
   - Verify feed shows empty state UI
   - Assert empty state message mentions no nearby flyers
   - Verify message suggests trying different location or disabling filter

3. Add empty state UI verification
   - Verify empty state icon/illustration appears
   - Verify helpful message text is visible
   - Verify no flyer cards are shown
   - Assert suggestion to deactivate filter is present

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document empty state behavior in test comments

### Acceptance Criteria
- [ ] Near Me filter with no nearby flyers shows empty state [Verify: Empty state UI with appropriate message]
- [ ] Empty state provides helpful feedback [Verify: Message mentions no nearby flyers]
- [ ] Test validates empty state against real backend [Verify: Backend returns empty results set]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_near_me_empty_state.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for Near Me empty state. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates empty state with real data (no nearby flyers)
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t06

## Dependencies
- Requires: m01-e01 (Feed browsing functional with empty states)
- Requires: m01-e02-t04-e2e-near-me-filter (Near Me filter working)
- Requires: Backend API endpoints for location-based filtering
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Use test location with no flyers within 5km OR test data without nearby flyers
- **Empty state**: Follow epic success criteria for appropriate messaging
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
