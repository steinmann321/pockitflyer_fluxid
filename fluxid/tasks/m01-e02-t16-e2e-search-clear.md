---
id: m01-e02-t16
title: E2E Search Clear Restores Feed
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Search Clear Restores Feed

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates search clearing end-to-end with NO MOCKS. Tests user action: entering search query, then clearing search input, and verifying feed restores to unfiltered state. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating clearing search restores full unfiltered feed.

### Steps

1. Create E2E test file for search clearing
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_search_clear_restore.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User clears search query
   - Launch app
   - Wait for feed to load
   - Record initial feed count (unfiltered state)
   - Tap on search bar
   - Input search text: "pizza"
   - Verify feed shows filtered results (fewer items)
   - Tap clear search button (X icon or similar)
   - Verify search input is empty
   - Verify feed restores to showing all flyers
   - Assert feed count matches initial unfiltered state

3. Add verification for state restoration
   - Verify search bar shows empty/placeholder state
   - Verify all flyers visible regardless of content
   - Assert no search filtering applied
   - Verify feed returns to original scroll position or top

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document clear behavior in test comments

### Acceptance Criteria
- [ ] Clearing search restores unfiltered feed [Verify: Feed shows all flyers after clear]
- [ ] Search input shows empty state [Verify: Placeholder text visible]
- [ ] Test validates state restoration against real backend [Verify: Backend returns unfiltered results]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_search_clear_restore.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for search clearing. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates state transition with real data
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t10

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t07-e2e-search-realtime-update (basic search working)
- Requires: Backend API endpoints for search functionality
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers with searchable content
- **State transition**: Search active → search cleared → unfiltered state
- **Performance**: Expect <500ms response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
