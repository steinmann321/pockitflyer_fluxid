---
id: m01-e02-t18
title: E2E Category Plus Search Combination
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Category Plus Search Combination

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates combined category filter and search end-to-end with NO MOCKS. Tests user action: selecting category filter AND entering search query, verifying feed shows flyers matching selected category with search term in title/description. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating category filter and search work together with AND logic.

### Steps

1. Create E2E test file for category + search
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_category_and_search.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User combines category and search
   - Launch app
   - Wait for feed to load
   - Tap category filter (e.g., "Events")
   - Verify feed shows only Events flyers
   - Tap search bar
   - Input search text: "concert" (or relevant term)
   - Verify feed shows only Events flyers with "concert" in title/description
   - Assert visible flyers match BOTH filters (Events AND contains "concert")
   - Verify no non-Events flyers appear
   - Verify no Events flyers without "concert" appear

3. Add combination logic verification
   - Scroll through filtered feed
   - Verify each flyer is Events category
   - Verify each flyer contains "concert" in visible text
   - Assert AND logic: (category = Events) AND (text contains "concert")

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document combination logic in test comments

### Acceptance Criteria
- [ ] Category + Search shows flyers matching BOTH filters [Verify: Results are Events AND contain search term]
- [ ] Both filters show active state [Verify: Category selected, search text visible]
- [ ] Test validates filter combination against real backend [Verify: Backend applies compound query]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_category_and_search.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for category + search combination. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates filter combination with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t12

## Dependencies
- Requires: m01-e02-t01-e2e-select-single-category (category filter working)
- Requires: m01-e02-t07-e2e-search-realtime-update (search working)
- Requires: Backend API endpoints supporting combined filters
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have Events flyers with searchable content
- **Combination logic**: Search uses AND with category filters (per epic notes)
- **Performance**: Expect <500ms combined filter response
- **Evidence**: Maestro saves reports to `maestro-reports/`
