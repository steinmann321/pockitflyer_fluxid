---
id: m01-e02-t15
title: E2E Filter State Persists During Session
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Filter State Persists During Session

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates filter state persistence during app session end-to-end with NO MOCKS. Tests user action: applying filters, navigating away from feed, returning to feed, and verifying filters remain active. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating filter state persists during navigation within app session.

### Steps

1. Create E2E test file for filter state persistence
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_filter_state_persistence.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: Filter state persists during navigation
   - Launch app
   - Wait for feed to load
   - Apply filters: Select "Events" category + enable Near Me
   - Verify feed shows filtered results
   - Navigate away from feed (e.g., tap into flyer detail view)
   - Navigate back to feed (e.g., back button)
   - Verify "Events" category still selected
   - Verify Near Me filter still active
   - Verify feed still shows filtered results
   - Assert filter state maintained across navigation

3. Add verification for multiple navigation cycles
   - Navigate away and back again
   - Verify filters remain active after second navigation
   - Verify feed continues showing correct filtered results
   - Assert state persistence is reliable

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document session persistence behavior in test comments

### Acceptance Criteria
- [ ] Filter state persists when navigating away and back [Verify: Filters remain active after navigation]
- [ ] Feed maintains filtered results after navigation [Verify: Same filters applied to feed]
- [ ] Test validates state persistence against real backend [Verify: Backend receives same filter parameters]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_filter_state_persistence.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for filter state persistence. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates state persistence with real navigation
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t15

## Dependencies
- Requires: m01-e01 (Feed browsing and navigation functional)
- Requires: m01-e02-t01-e2e-select-single-category (category filter working)
- Requires: m01-e02-t04-e2e-near-me-filter (Near Me filter working)
- Requires: Frontend state management for filter persistence
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers for filtering
- **Session scope**: Filter state is session-only, not across app restarts (per epic notes)
- **Navigation**: Test within same app session (no app restart)
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
