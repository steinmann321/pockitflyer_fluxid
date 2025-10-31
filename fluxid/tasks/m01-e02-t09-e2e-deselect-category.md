---
id: m01-e02-t09
title: E2E Category Filter Deselection
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Category Filter Deselection

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates category filter deselection end-to-end with NO MOCKS. Tests user action: selecting a category filter, then deselecting it, and verifying feed returns to unfiltered state. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating category filter deselection restores unfiltered feed.

### Steps

1. Create E2E test file for category deselection
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_deselect_category_filter.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User deselects category filter
   - Launch app
   - Wait for feed to load
   - Record initial feed state (count of visible flyers)
   - Tap on category filter (e.g., "Events")
   - Verify feed shows filtered results (fewer items)
   - Tap same category filter again to deselect
   - Verify filter shows unselected state
   - Verify feed returns to showing all categories
   - Assert feed count matches initial unfiltered state

3. Add verification for state reset
   - Verify all category indicators visible in feed
   - Verify feed includes flyers from all categories
   - Verify no active filter badges/indicators remain

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document deselection behavior in test comments

### Acceptance Criteria
- [ ] Deselecting category filter restores unfiltered feed [Verify: Feed shows all categories after deselection]
- [ ] Filter UI shows unselected state [Verify: Visual indicator removed]
- [ ] Test validates state transition against real backend [Verify: Backend returns unfiltered results]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_deselect_category_filter.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for category filter deselection. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates filter state transition with real data
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t03

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t01-e2e-select-single-category (single category selection working)
- Requires: Backend API endpoints for category filtering
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers in multiple categories
- **State transition**: Filter on → filter off → unfiltered state
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
