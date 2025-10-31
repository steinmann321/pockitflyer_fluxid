---
id: m01-e02-t18
title: E2E Search Debouncing Validation
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Search Debouncing Validation

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates search debouncing reduces API calls end-to-end with NO MOCKS. Tests user action: rapidly typing search query and verifying API calls are debounced (300ms delay) to avoid excessive requests. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating search debouncing reduces unnecessary API calls.

### Steps

1. Create E2E test file for search debouncing
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_search_debouncing.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: Rapid typing triggers debouncing
   - Launch app with backend logging enabled
   - Wait for feed to load
   - Tap search bar
   - Rapidly input text character by character: "p" "i" "z" "z" "a"
   - Wait for debounce delay to complete (>300ms)
   - Verify backend received limited API calls (not one per character)
   - Check backend logs show debounced behavior
   - Verify final search results appear for "pizza"

3. Add debounce timing verification
   - Monitor backend API call count during rapid typing
   - Verify API calls are throttled (not instantaneous per keystroke)
   - Assert debounce delay is approximately 300ms (per epic notes)
   - Verify only final/recent queries reach backend

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document debouncing behavior in test comments

### Acceptance Criteria
- [ ] Rapid typing does not trigger API call per keystroke [Verify: Backend receives limited requests]
- [ ] Debouncing reduces API calls to reasonable count [Verify: API call count < character count]
- [ ] Test validates debouncing against real backend [Verify: Backend logs show debounced requests]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_search_debouncing.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for search debouncing. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates debouncing with real API call monitoring
- [ ] Evidence captured (Maestro screenshots/reports + backend logs)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t18

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t07-e2e-search-realtime-update (basic search working)
- Requires: Frontend search debouncing implementation (300ms)
- Requires: Backend logging to verify API call count
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md with logging
- **Test data**: Backend must have test flyers for search
- **Debounce delay**: 300ms after last keystroke per epic notes
- **Verification method**: Monitor backend logs for API request count
- **Success criteria**: Per epic m01-e02 - "Search is debounced to avoid excessive API calls"
- **Performance**: Expect <500ms search response per backend requirements
- **Evidence**: Maestro saves reports + backend logs showing request count
