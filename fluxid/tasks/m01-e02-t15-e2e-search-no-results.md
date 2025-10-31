---
id: m01-e02-t15
title: E2E Search No Results Empty State
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Search No Results Empty State

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates search empty state end-to-end with NO MOCKS. Tests user action: entering search query with no matching flyers and verifying appropriate empty state message appears. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating search shows empty state when no matches found.

### Steps

1. Create E2E test file for search empty state
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_search_no_results.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User enters non-matching search
   - Launch app
   - Wait for feed to load
   - Tap on search bar
   - Input text: "xyzabc123nomatch" (guaranteed no matches)
   - Verify feed updates to show empty state
   - Assert empty state message mentions no search results
   - Verify message suggests trying different search terms
   - Verify no flyer cards are shown

3. Add empty state UI verification
   - Verify empty state icon/illustration appears
   - Verify helpful message text is visible
   - Assert suggestion to modify search query is present
   - Verify clear search button or similar action available

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document empty state behavior in test comments

### Acceptance Criteria
- [ ] Search with no matches shows empty state [Verify: Empty state UI with appropriate message]
- [ ] Empty state provides helpful feedback [Verify: Message mentions no results found]
- [ ] Test validates empty state against real backend [Verify: Backend returns empty results set]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_search_no_results.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for search empty state. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates empty state with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t09

## Dependencies
- Requires: m01-e01 (Feed browsing functional with empty states)
- Requires: m01-e02-t07-e2e-search-realtime-update (basic search working)
- Requires: Backend API endpoints for search functionality
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Use non-matching search term guaranteed not in database
- **Empty state**: Follow epic success criteria for appropriate messaging
- **Performance**: Expect <500ms search response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
