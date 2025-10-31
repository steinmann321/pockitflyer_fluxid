---
id: m01-e01-t16
title: Pull-to-Refresh E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Pull-to-Refresh E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that pull-to-refresh gesture updates feed with new/changed flyers. Tests user action: pull-to-refresh gesture. Uses real backend, real database updates.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating pull-to-refresh updates feed through real system stack.

### Steps

1. Create E2E test file for pull-to-refresh
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t16_pull_to_refresh.yaml`
   - Follow Maestro flow structure conventions
   - Use Maestro swipe/scroll commands for pull gesture

2. Implement basic pull-to-refresh test
   - Test: 'User pulls down refreshes feed'
   - User launches app
   - User sees initial feed state
   - User performs pull-down gesture (swipe down from top)
   - System requests fresh data from backend
   - Verify: Loading indicator shows during refresh
   - Verify: Feed updates after refresh completes

3. Implement new content detection test
   - Test: 'Refresh shows newly added flyer'
   - User sees initial feed
   - Add new flyer to backend database (via API or direct DB)
   - User pulls to refresh
   - Verify: New flyer appears in feed

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t16_pull_to_refresh`
   - Verify backend receives refresh request
   - Capture evidence of refresh behavior

### Acceptance Criteria
- [ ] Pull-to-refresh gesture triggers feed update [Verify: Loading indicator then updated feed]
- [ ] New backend content appears after refresh [Verify: Newly added flyer visible]
- [ ] Test uses real backend data [Verify: Backend logs show refresh API call]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t16_pull_to_refresh.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for pull-to-refresh. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real database updates

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates real database changes (not mocked)
- [ ] Evidence captured showing refresh behavior
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t16

## Dependencies
- Requires: Backend Feed API implementation
- Requires: Frontend pull-to-refresh widget implementation
- Requires: Backend test data management capability
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Test must add new flyer to backend during execution
- **Maestro gesture**: Use swipe down from top to trigger pull-to-refresh
- **Timing**: Allow time for refresh animation and backend request
- **Evidence**: Screenshots showing before/after refresh states

## References
- Maestro swipe command for pull gesture
- Pull-to-refresh widget implementation
- Backend Feed API for refresh behavior
