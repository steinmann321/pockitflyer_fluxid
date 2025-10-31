---
id: m01-e02-t17
title: E2E Search With Special Characters
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Search With Special Characters

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates search handles special characters end-to-end with NO MOCKS. Tests user action: entering search query with special characters (punctuation, symbols) and verifying feed handles them gracefully without errors. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating search handles special characters without errors.

### Steps

1. Create E2E test file for special character search
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_search_special_chars.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User enters special characters in search
   - Launch app
   - Wait for feed to load
   - Tap search bar
   - Input search with special characters: "$50 sale!" or "café & bar"
   - Verify app does not crash
   - Verify search executes without errors
   - Verify feed updates (shows results or empty state)
   - Assert special characters handled gracefully

3. Add verification for various special characters
   - Test punctuation: "pizza, pasta & more!"
   - Test symbols: "$20 off" or "50% discount"
   - Test accents: "café" or "piñata"
   - Verify each search completes without errors
   - Assert results match or show empty state appropriately

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document special character handling in test comments

### Acceptance Criteria
- [ ] Search with special characters does not crash app [Verify: App remains stable]
- [ ] Special characters are handled gracefully [Verify: Search executes, shows results or empty state]
- [ ] Test validates special character handling against real backend [Verify: Backend processes special characters safely]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_search_special_chars.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for special character search. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates special character handling with real queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t17

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t07-e2e-search-realtime-update (basic search working)
- Requires: Backend API endpoints with proper input sanitization
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend should handle special characters safely (SQL injection prevention, etc.)
- **Special characters**: Test punctuation, symbols, accents per success criteria
- **Error handling**: App should not crash, backend should sanitize input
- **Performance**: Expect <500ms search response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
