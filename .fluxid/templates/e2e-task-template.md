---
id: mXX-eXX-tXX
title: E2E [User Flow Scenario]
epic: mXX-eXX
milestone: mXX
status: pending
---

# Task: E2E [User Flow Scenario]

## Context
Part of [Epic name] (mXX-eXX) in [Milestone name] (mXX).

Validates [specific user flow scenario] end-to-end with NO MOCKS. Tests user flow: [brief flow description: user does X → app responds Y → user continues with Z]. Uses real backend, real database, real services.

**Note**: This is one of multiple E2E tasks validating different scenarios within this epic's user flow. Each E2E task tests a specific path or edge case of the flow.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating [specific user flow scenario] through real system stack (no mocks).

### Steps

1. Create E2E test file for this flow scenario
   - Create file: `[project_e2e_directory]/mXX_eXX_tXX_[scenario_name].[ext]`
   - Follow project's E2E testing framework structure
   - Reference existing E2E tests in same directory for patterns
   - Use test utilities from project's E2E helpers (if available)

2. Implement the complete user flow test
   - Test name: '[User-centric flow description]'
   - Step 1: User [action] (e.g., launches app, taps button X)
   - Step 2: App [response] (e.g., navigates to page Y, displays data)
   - Step 3: User [next action] (e.g., scrolls, enters text, selects option)
   - Step N: Final [outcome/state]
   - Verify: [observable outcomes at each critical step]
   - Capture evidence: [screenshots, logs, or visual proof]

3. Add scenario variations (if applicable)
   - Test variant: '[Specific edge case or alternative path]'
   - Focus on this scenario's boundary conditions, not the entire epic
   - Keep each E2E task focused on ONE specific flow scenario

4. Validate using real stack
   - Run test against real backend (must be running)
   - Verify test uses real database (check data persistence)
   - Verify test uses real external services (no mocks)
   - Ensure test completes successfully
   - Review captured evidence

### Acceptance Criteria
- [ ] User flow scenario works end-to-end [Verify: All flow steps complete successfully]
- [ ] Test runs against real backend [Verify: Backend logs show API requests]
- [ ] Test validates real data [Verify: Data comes from actual database, not mocks]
- [ ] Flow reflects actual user experience [Verify: Interactions match production behavior]

### Files to Create/Modify
- `[e2e_test_directory]/mXX_eXX_tXX_[scenario_name].[ext]` - NEW: E2E test for this scenario
- `[e2e_helpers_file].[ext]` - MODIFY: Add scenario-specific helpers (if needed)

### Testing Requirements
**Note**: This task IS the E2E testing for this specific flow scenario. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services
- **Focus**: One scenario of the epic's user flow (not the entire epic)
- **No mocks**: All services must be real and running

### Definition of Done
- [ ] Test passes against real backend (backend must be running)
- [ ] Test validates data from real database (not mocked)
- [ ] Evidence captured (screenshots, logs, or visual proof in e2e output directory)
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Test follows project's E2E testing conventions
- [ ] Changes committed with reference to task ID (mXX-eXX-tXX)

## Dependencies
- Requires: Implementation tasks for this epic's horizontal layers (app state, database, business logic, UI)
- Requires: Backend API endpoints for this flow
- Requires: Frontend UI components for this flow
- Blocks: None (E2E tasks can run in parallel with other E2E tasks in same or different epics)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md (automated scripts ensure detached start and kill-before-start)
- **Test data**: Backend must have test data seeded for this flow scenario
- **Performance**: Allow realistic time for real backend/service responses
- **Evidence**: Save proof to project's E2E output directory (e.g., `maestro-reports/`, `integration_test/screenshots/`)
- **Isolation**: Test should work independently, not depend on other E2E tests running first
- **Cleanup**: Test should clean up its own state if it modifies data
- **Flow focus**: This E2E task validates ONE scenario of the epic's user flow, not the entire epic
- **Epic = Flow**: Each epic represents one user flow; multiple E2E tasks within the epic validate different scenarios/paths of that flow

## References
- Project's E2E testing documentation (e.g., `maestro/README.md`, `integration_test/README.md`)
- Existing E2E tests in same epic for patterns and conventions
- CONTRIBUTORS.md for exact backend/app startup commands
- Epic file (mXX-eXX-*.md) for understanding the complete user flow this scenario is part of

## Strategy Context
**New fluxid Architecture**:
- **Milestones** = Vertical slices (complete functionality, fully runnable, fully usable)
- **Epics** = User flows (all actions user can take: click → navigate → interact → complete)
- **Tasks** = Horizontal layers (technical implementation: state, database, logic, UI)
- **E2E Tasks** = Flow validation (embedded in epic, validates specific scenarios of the flow)

This E2E task is NOT part of a separate "E2E Milestone Validation" epic. It's embedded within the epic whose user flow it validates.
