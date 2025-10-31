---
id: mXX-eXX-tXX
title: [User Action] E2E Validation
epic: mXX-eXX
milestone: mXX
status: pending
---

# Task: [User Action] E2E Validation

## Context
Part of E2E Milestone Validation (mXX-eXX) in Milestone XX (mXX).

Validates [specific user scenario] end-to-end with NO MOCKS. Tests user action: [single action/workflow]. Uses real backend, real database, real services.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating [specific scenario] through real system stack.

### Steps

1. Create E2E test file for [scenario]
   - Create file in [project's E2E test directory path]
   - Import [project's E2E testing framework]
   - Import application entry point
   - Import test utilities from [existing helpers path]
   - Setup E2E test environment (refer to setup task for configuration)
   - Create test structure following [project test conventions]

2. Implement [specific test case]
   - Test: '[User-centric test description]'
   - User [performs action]
   - System [responds]
   - Verify: [observable outcome]
   - Capture evidence: [visual/log proof]

3. Add edge cases (if applicable)
   - Test: '[Edge case description]'
   - Similar structure, focused on boundary conditions

4. Add utilities and cleanup
   - Create helper functions if needed (describe behavior)
   - Add setup steps (describe requirements)
   - Add cleanup steps (describe teardown)
   - Mark tests passing using [project's test marker conventions]

### Acceptance Criteria
- [ ] [Action] works end-to-end [Verify: Observable outcome]
- [ ] Test runs against real backend [Verify: Backend logs show requests]
- [ ] Test validates real data [Verify: Data from database]

### Files to Create/Modify
- `[e2e_test_directory]/[scenario_name].[ext]` - NEW: E2E test
- `[e2e_helpers_file].[ext]` - MODIFY: Add scenario helpers (if needed)

### Testing Requirements
**Note**: This task IS the E2E testing for [scenario]. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates data from real database (not mocked)
- [ ] Evidence captured (visual proof or logs)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: mXX-eXX-t01 (E2E environment setup)
- Requires: [Any specific implementation epics needed]
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Refer to E2E setup task for startup procedure
- **Test data**: Use test data from E2E setup task
- **Performance**: Allow time for real backend/service responses
- **Evidence**: Save proof to E2E output directory
- **Isolation**: Test should not depend on other E2E tests
- **Cleanup**: Test should clean up its own state (if stateful)

## References
- E2E environment setup task (t01) for configuration
- Project's E2E testing documentation
- Existing E2E tests for patterns and conventions
