---
id: m01-e02-t14
title: E2E Search Partial Word Match
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Search Partial Word Match

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates search partial word matching end-to-end with NO MOCKS. Tests user action: entering partial search term and verifying feed shows flyers with partial matches in title or description. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating search matches partial words correctly.

### Steps

1. Create E2E test file for partial word matching
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_search_partial_match.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User enters partial search term
   - Launch app
   - Wait for feed to load
   - Tap on search bar
   - Input partial text: "piz" (to match "pizza", "pizzeria", etc.)
   - Verify feed updates to show matching flyers
   - Assert visible flyers contain words starting with "piz"
   - Verify full word matches like "pizza" appear in results
   - Verify partial matches are case-insensitive

3. Add verification for partial match behavior
   - Try multiple partial queries (different word starts)
   - Verify each returns appropriate matches
   - Assert backend supports partial word matching (LIKE or full-text search)
   - Verify no exact-match-only behavior

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document partial match behavior in test comments

### Acceptance Criteria
- [ ] Partial search terms match words in title/description [Verify: "piz" matches "pizza"]
- [ ] Partial matching is case-insensitive [Verify: "PIZ" also matches "pizza"]
- [ ] Test validates partial matching against real backend [Verify: Backend uses LIKE or full-text search]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_search_partial_match.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for partial word matching. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates partial matching with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t08

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t07-e2e-search-realtime-update (basic search working)
- Requires: Backend API endpoints with partial search support
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers with searchable content
- **Search method**: Backend must use LIKE queries or full-text search (per epic notes)
- **Partial match**: Matches word prefixes, not arbitrary substrings
- **Performance**: Expect <500ms search response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
