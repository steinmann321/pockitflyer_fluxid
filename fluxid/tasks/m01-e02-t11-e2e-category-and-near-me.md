---
id: m01-e02-t11
title: E2E Category Plus Near Me Combination
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Category Plus Near Me Combination

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates combined category and Near Me filters end-to-end with NO MOCKS. Tests user action: selecting category filter AND enabling Near Me filter, verifying feed shows flyers matching selected category within proximity threshold. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating category and Near Me filters work together with AND logic.

### Steps

1. Create E2E test file for combined filters
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_category_and_near_me.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User combines category and Near Me
   - Launch app
   - Wait for feed to load
   - Tap category filter (e.g., "Events")
   - Verify feed shows only Events flyers
   - Tap "Near Me" filter toggle
   - Verify both filters show active state
   - Verify feed shows only Events flyers within 5km
   - Assert visible flyers match BOTH filters (Events AND nearby)
   - Verify no distant Events flyers appear
   - Verify no nearby non-Events flyers appear

3. Add combination logic verification
   - Scroll through filtered feed
   - Verify each flyer is Events category
   - Verify each flyer shows distance ≤ 5km
   - Assert AND logic: (category = Events) AND (distance ≤ 5km)

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document combination logic in test comments

### Acceptance Criteria
- [ ] Category + Near Me shows flyers matching BOTH filters [Verify: Results are Events AND within 5km]
- [ ] Both filters show active state [Verify: Visual indicators for both]
- [ ] Test validates filter combination against real backend [Verify: Backend applies compound query]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_category_and_near_me.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for combined filters. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates filter combination with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t11

## Dependencies
- Requires: m01-e02-t01-e2e-select-single-category (category filter working)
- Requires: m01-e02-t04-e2e-near-me-filter (Near Me filter working)
- Requires: Backend API endpoints supporting combined filters
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have Events flyers at various distances
- **Combination logic**: Near Me uses AND with category filters (per epic notes)
- **Database indexes**: Compound indexes needed: (category, location) per epic
- **Performance**: Expect <500ms combined filter response
- **Evidence**: Maestro saves reports to `maestro-reports/`
