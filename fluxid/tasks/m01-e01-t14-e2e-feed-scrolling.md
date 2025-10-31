---
id: m01-e01-t14
title: Feed Scrolling E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Feed Scrolling E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that users can scroll through feed to see more flyers. Tests user action: scrolling feed. Uses real backend, real pagination.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating feed scrolling loads more flyers through real system stack.

### Steps

1. Create E2E test file for feed scrolling
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t15_feed_scrolling.yaml`
   - Follow Maestro flow structure conventions
   - Use Maestro scroll commands

2. Implement basic scrolling test
   - Test: 'User scrolls feed sees more flyers'
   - User launches app
   - User sees initial flyers (screen 1)
   - User scrolls down (scroll command)
   - Verify: New flyer cards become visible
   - Verify: Previously visible cards scroll off screen

3. Implement pagination test
   - Test: 'Scrolling triggers pagination from backend'
   - User scrolls to bottom of current page
   - System requests next page from backend
   - Verify: Additional flyers load
   - Verify: Smooth scrolling experience (no visible loading gaps)

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t15_feed_scrolling`
   - Verify backend receives pagination requests
   - Capture evidence of scrolling behavior

### Acceptance Criteria
- [ ] Scrolling reveals more flyers [Verify: New cards visible after scroll]
- [ ] Backend pagination triggered by scroll [Verify: Backend logs show paginated requests]
- [ ] Smooth scrolling without gaps [Verify: Visual continuity]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t15_feed_scrolling.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for feed scrolling. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real pagination

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates real pagination (not mocked)
- [ ] Evidence captured showing scroll behavior
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t15

## Dependencies
- Requires: Backend Feed API with pagination support
- Requires: Frontend feed widget with scroll handling
- Requires: Test database with 10+ flyers for scrolling
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Backend must have 10+ test flyers to enable scrolling
- **Maestro scroll**: Use `scroll` command with direction/distance
- **Performance**: Allow time for pagination requests
- **Evidence**: Screenshots before and after scroll showing different flyers

## References
- Maestro scroll command documentation
- Backend pagination implementation for expected behavior
