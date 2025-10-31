---
id: m01-e02-t07
title: E2E Single Category Filter Selection
epic: m01-e02
milestone: m01
status: pending
---

# Task: E2E Single Category Filter Selection

## Context
Part of Epic m01-e02 (User Filters and Searches Flyers) in Milestone 01 (Anonymous Discovery).

Validates single category filter selection end-to-end with NO MOCKS. Tests user action: selecting one category filter and seeing feed update with only flyers from that category. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating single category filter selection updates feed correctly.

### Steps

1. Create E2E test file for single category selection
   - Create file: `pockitflyer_app/maestro/flows/m01_e02_single_category_filter.yaml`
   - Set appId to match app bundle identifier
   - Follow structure from `maestro/flows/app_launch.yaml`
   - Reference Maestro command documentation in `maestro/README.md`

2. Implement test: User selects single category
   - Launch app
   - Wait for feed to load
   - Tap on category filter UI element (e.g., "Events" chip/button)
   - Verify category filter is visually selected/active
   - Verify feed updates to show only flyers with selected category
   - Verify feed items contain category indicator matching selection
   - Assert visible flyer cards show "Events" category

3. Add verification for filter state
   - Verify other category filters remain unselected
   - Verify feed count changes appropriately
   - Verify category appears in active filter indicator/badge

4. Mark test passing
   - Add test to Maestro test suite
   - Mark test with `@pytest.mark.tdd_green` equivalent (Maestro uses tags in YAML)
   - Ensure test runs successfully via `./maestro/run_tests.sh`

### Acceptance Criteria
- [ ] Selecting single category updates feed to show only flyers from that category [Verify: Feed shows only Events flyers when Events selected]
- [ ] Category filter UI shows selected state [Verify: Visual indicator shows active filter]
- [ ] Test runs against real backend [Verify: Backend logs show filter API requests]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e02_single_category_filter.yaml` - NEW: E2E test flow

### Testing Requirements
**Note**: This task IS the E2E testing for single category filter selection. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates data from real database (flyers filtered by category)
- [ ] Evidence captured (Maestro screenshots/reports)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e02-t01

## Dependencies
- Requires: m01-e01 (Feed browsing functional)
- Requires: Backend API endpoints for category filtering (m01-e02-t01 from implementation epic)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Start backend via scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyers with various categories
- **Performance**: Expect <500ms filter response per backend requirements
- **Evidence**: Maestro saves reports to `maestro-reports/`
- **Isolation**: Test should not depend on other E2E tests
- **Category values**: Events, Nightlife, Service (from epic scope)
