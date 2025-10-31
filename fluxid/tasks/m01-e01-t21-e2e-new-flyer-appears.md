---
id: m01-e01-t21
title: New Flyer Appears After Refresh E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: New Flyer Appears After Refresh E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that newly created flyers appear in feed after refresh. Tests user action: viewing new content after pull-to-refresh. Uses real backend, real database insertions.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating new flyers appear in feed through real system stack.

### Steps

1. Create E2E test file for new flyer validation
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t21_new_flyer_appears.yaml`
   - Follow Maestro flow structure conventions

2. Implement new flyer test
   - Test: 'Newly created flyer appears in feed after refresh'
   - User launches app
   - User sees initial feed state (note flyer count)
   - Create new flyer via backend API (use API client or direct DB insert)
   - User pulls to refresh
   - Verify: New flyer appears in feed
   - Verify: New flyer has all expected fields
   - Verify: Feed count increased by 1

3. Implement ranking verification
   - Test: 'New flyer appears at top (most recent)'
   - Create new flyer with current timestamp
   - User refreshes feed
   - Verify: New flyer appears at top of feed (smart ranking by recency)

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t21_new_flyer_appears`
   - Verify real database insertion
   - Capture evidence of new flyer appearing

### Acceptance Criteria
- [ ] New flyer appears after refresh [Verify: Newly created flyer visible in feed]
- [ ] New flyer ranked correctly [Verify: Appears at top due to recency]
- [ ] Test uses real backend database [Verify: Backend logs show INSERT and SELECT]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t21_new_flyer_appears.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for new flyer appearing. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real database insertions

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates real database insertions (not mocked)
- [ ] Evidence captured showing new flyer in feed
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t21

## Dependencies
- Requires: Backend Flyer creation API (or direct DB access for testing)
- Requires: Backend Feed API with proper ranking
- Requires: Frontend pull-to-refresh implementation
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Test must create new flyer during execution
- **Database**: May need API endpoint or test utility to create flyers
- **Cleanup**: Should delete test flyer after test completes
- **Ranking**: Verify smart ranking algorithm places new flyer appropriately
- **Evidence**: Screenshots showing before/after refresh with new flyer

## References
- Backend Flyer creation API documentation
- Backend smart ranking algorithm (recency + proximity)
- Pull-to-refresh implementation
