---
id: m01-e02-t07
title: E2E Search Real-Time Feed Update
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Search Real-Time Feed Update

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates real-time search feed updates end-to-end with NO MOCKS. Tests user action: typing search query in header search bar and verifying feed updates in real-time with matching flyers. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating search updates feed in real-time as user types.

### Steps

1. Create E2E test file for real-time search
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_search_realtime_update.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User types search query
   - Launch app
   - Wait for feed to load
   - Tap on search bar in header
   - Input text: "pizza" (or relevant test search term)
   - Verify feed updates to show matching flyers
   - Assert visible flyers contain "pizza" in title or description
   - Verify feed updates without requiring Enter/Submit
   - Verify non-matching flyers are excluded

3. Add real-time update verification
   - Type additional characters incrementally
   - Verify feed refines results with each keystroke
   - Assert debouncing occurs (300ms per epic notes)
   - Verify search is case-insensitive

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document real-time behavior in test comments

### Acceptance Criteria
- [ ] Search updates feed as user types without Submit button [Verify: Feed updates with partial query]
- [ ] Search matches title and description fields [Verify: Results show search term in either field]
- [ ] Test validates real-time search against real backend [Verify: Backend API receives search queries]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_search_realtime_update.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for real-time search. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates real-time search with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t07

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: Backend API endpoints for search functionality
- Requires: Search debouncing implementation (300ms)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers with searchable titles/descriptions
- **Debouncing**: 300ms after last keystroke per epic notes
- **Search scope**: Title and description fields per success criteria
- **Case sensitivity**: Case-insensitive per success criteria
- **Performance**: Expect <500ms search response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
