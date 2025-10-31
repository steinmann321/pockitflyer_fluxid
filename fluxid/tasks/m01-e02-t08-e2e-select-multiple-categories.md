---
id: m01-e02-t08
title: E2E Multiple Category Filter Selection
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Multiple Category Filter Selection

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates multiple category filter selection with OR logic end-to-end with NO MOCKS. Tests user action: selecting multiple categories and verifying feed shows flyers matching ANY selected category. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating multiple category filter selection uses OR logic correctly.

### Steps

1. Create E2E test file for multiple category selection
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_multiple_categories_or_logic.yaml`
   - Set appId to match app bundle identifier
   - Follow Maestro flow structure from existing flows

2. Implement test: User selects multiple categories
   - Launch app
   - Wait for feed to load
   - Tap on first category filter (e.g., "Events")
   - Tap on second category filter (e.g., "Nightlife")
   - Verify both filters show selected state
   - Verify feed updates to show flyers from EITHER category
   - Assert feed contains mix of Events AND Nightlife flyers
   - Verify no Service flyers appear in results

3. Add OR logic verification
   - Scroll through feed
   - Assert each visible flyer shows either Events or Nightlife category
   - Verify feed count is sum of both categories (not intersection)
   - Verify no flyers from unselected categories appear

4. Mark test passing
   - Add test to Maestro test suite
   - Ensure test runs successfully
   - Document OR logic behavior in test comments

### Acceptance Criteria
- [ ] Selecting multiple categories shows flyers from ANY selected category [Verify: Feed contains both Events AND Nightlife flyers]
- [ ] Feed excludes flyers from unselected categories [Verify: No Service flyers when only Events+Nightlife selected]
- [ ] Test validates OR logic against real data [Verify: Backend returns union of categories]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_multiple_categories_or_logic.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for multiple category filter OR logic. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates OR logic with real database queries
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t02

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: m01-e02-t01-e2e-select-single-category (single category working)
- Requires: Backend API endpoints for category filtering with OR logic
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers in multiple categories
- **OR Logic**: Category filters use OR (union), not AND (intersection)
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
