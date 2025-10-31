---
id: m01-e01-t19
title: Feed Empty State E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Feed Empty State E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates feed empty state when no flyers are available. Tests user action: viewing feed with no content. Uses real backend, real empty database state.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating empty feed state displays appropriate message through real system stack.

### Steps

1. Create E2E test file for empty feed state
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t19_feed_empty_state.yaml`
   - Follow Maestro flow structure conventions

2. Implement empty state test
   - Test: 'Empty feed shows appropriate message'
   - Clear all flyers from backend database (or use fresh DB)
   - User launches app
   - System queries backend, receives empty result
   - Verify: Empty state message visible (e.g., "No flyers nearby")
   - Verify: No flyer cards visible
   - Verify: No loading indicator stuck on screen

3. Implement empty state UI validation
   - Verify: Empty state has helpful text
   - Verify: Empty state has appropriate icon/illustration (if designed)
   - Verify: UI looks intentional, not broken

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t19_feed_empty_state`
   - Verify backend returns empty array
   - Capture evidence of empty state UI

### Acceptance Criteria
- [ ] Empty feed shows appropriate message [Verify: Empty state text visible]
- [ ] No flyer cards visible [Verify: Feed container empty]
- [ ] Test uses real empty backend response [Verify: Backend logs show query returning 0 results]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t19_feed_empty_state.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for empty feed state. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real empty database

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates real empty database state (not mocked)
- [ ] Evidence captured showing empty state UI
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t19

## Dependencies
- Requires: Backend Feed API implementation
- Requires: Frontend empty state UI implementation
- Requires: Ability to clear test database or use fresh database
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Database must be empty or all flyers removed
- **Database setup**: Test may need to clear database before running
- **Evidence**: Screenshot showing empty state message
- **Cleanup**: Restore test data after test if needed

## References
- Frontend empty state UI design
- Backend Feed API empty response format
