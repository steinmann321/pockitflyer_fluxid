---
id: m01-e02-t13
title: E2E Near Me Plus Search Combination
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Near Me Plus Search Combination

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates combined Near Me filter and search end-to-end with NO MOCKS. Tests user action: enabling Near Me filter AND entering search query, verifying feed shows nearby flyers with search term in title/description. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating Near Me filter and search work together with AND logic.

### Steps

1. Create E2E test file for Near Me + search
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_near_me_and_search.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User combines Near Me and search
   - Launch app
   - Wait for feed to load
   - Tap "Near Me" filter toggle
   - Verify feed shows only nearby flyers
   - Tap search bar
   - Input search text: "sale" (or relevant term)
   - Verify feed shows only nearby flyers with "sale" in title/description
   - Assert visible flyers match BOTH filters (distance ≤ 5km AND contains "sale")
   - Verify no distant flyers appear
   - Verify no nearby flyers without "sale" appear

3. Add combination logic verification
   - Scroll through filtered feed
   - Verify each flyer shows distance ≤ 5km
   - Verify each flyer contains "sale" in visible text
   - Assert AND logic: (distance ≤ 5km) AND (text contains "sale")

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document combination logic in test comments

### Acceptance Criteria
- [ ] Near Me + Search shows flyers matching BOTH filters [Verify: Results are nearby AND contain search term]
- [ ] Both filters show active state [Verify: Near Me active, search text visible]
- [ ] Test validates filter combination against real backend [Verify: Backend applies compound query]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_near_me_and_search.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for Near Me + search combination. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates filter combination with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t13

## Dependencies
- Requires: m01-e02-t04-e2e-near-me-filter (Near Me filter working)
- Requires: m01-e02-t07-e2e-search-realtime-update (search working)
- Requires: Backend API endpoints supporting combined filters
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have nearby flyers with searchable content
- **Combination logic**: Search uses AND with Near Me filter (per epic notes)
- **Performance**: Expect <500ms combined filter response
- **Evidence**: Maestro saves reports to `maestro-reports/`
