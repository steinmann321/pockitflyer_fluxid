---
id: m01-e02-t22
title: E2E Pull-To-Refresh Maintains Filters
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Pull-To-Refresh Maintains Filters

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates filters persist during pull-to-refresh end-to-end with NO MOCKS. Tests user action: applying filters, performing pull-to-refresh gesture, and verifying filters remain active after refresh. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating filters remain active after pull-to-refresh gesture.

### Steps

1. Create E2E test file for pull-to-refresh with filters
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_pull_refresh_maintains_filters.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: Filters persist after pull-to-refresh
   - Launch app
   - Wait for feed to load
   - Apply filter: Select "Nightlife" category
   - Verify feed shows filtered results (Nightlife only)
   - Perform pull-to-refresh gesture on feed
   - Wait for refresh to complete
   - Verify "Nightlife" category still selected
   - Verify feed still shows only Nightlife flyers
   - Assert filter state maintained after refresh

3. Add verification for filter integrity
   - Verify filter UI still shows active state
   - Verify refreshed feed respects filter
   - Assert new/updated flyers match active filter
   - Verify no unfiltered flyers appear

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document refresh behavior in test comments

### Acceptance Criteria
- [ ] Pull-to-refresh maintains active filters [Verify: Filter still active after refresh]
- [ ] Refreshed feed shows filtered results [Verify: Only filtered flyers appear]
- [ ] Test validates filter persistence against real backend [Verify: Backend receives same filter parameters after refresh]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_pull_refresh_maintains_filters.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for pull-to-refresh with filters. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates filter persistence through refresh with real data
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t16

## Dependencies
- Requires: m01-e01 (Feed browsing with pull-to-refresh functional)
- Requires: m01-e02-t01-e2e-select-single-category (category filter working)
- Requires: Frontend state management for filter persistence
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers for filtering
- **Pull-to-refresh**: Maestro supports swipe gestures for pull-to-refresh
- **Success criteria**: Per epic m01-e02 - "Filter state persists... pull-to-refresh maintains filters"
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
