---
id: m01-e02-t20
title: E2E All Filters Combined
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E All Filters Combined

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates all three filter types combined end-to-end with NO MOCKS. Tests user action: selecting category filter AND enabling Near Me AND entering search query, verifying feed shows flyers matching ALL three filters. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating category, Near Me, and search work together with AND logic.

### Steps

1. Create E2E test file for all filters combined
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_all_filters_combined.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User combines all three filters
   - Launch app
   - Wait for feed to load
   - Tap category filter (e.g., "Events")
   - Tap "Near Me" filter toggle
   - Tap search bar
   - Input search text: "live" (or relevant term)
   - Verify all three filters show active state
   - Verify feed shows only flyers matching ALL filters
   - Assert visible flyers are: Events AND within 5km AND contain "live"
   - Verify feed excludes flyers missing any filter criteria

3. Add comprehensive verification
   - Scroll through filtered feed
   - Verify each flyer is Events category
   - Verify each flyer shows distance ≤ 5km
   - Verify each flyer contains "live" in visible text
   - Assert AND logic: (category = Events) AND (distance ≤ 5km) AND (text contains "live")
   - Verify feed count is most restrictive (fewer results than any single filter)

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document three-way combination logic in test comments

### Acceptance Criteria
- [ ] All three filters combined show flyers matching ALL criteria [Verify: Results match category AND distance AND search]
- [ ] All three filters show active state [Verify: Visual indicators for all three]
- [ ] Test validates complex filter combination against real backend [Verify: Backend applies compound query with all filters]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_all_filters_combined.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for all filters combined. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates three-way filter combination with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t14

## Dependencies
- Requires: m01-e02-t01-e2e-select-single-category (category filter working)
- Requires: m01-e02-t04-e2e-near-me-filter (Near Me filter working)
- Requires: m01-e02-t07-e2e-search-realtime-update (search working)
- Requires: Backend API endpoints supporting all combined filters
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have Events flyers nearby with searchable content
- **Combination logic**: All filters use AND (per epic notes)
- **Database indexes**: Compound indexes needed: (category, location, valid_until) per epic
- **Performance**: Expect <500ms combined filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
