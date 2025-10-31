---
id: m01-e01-t11
title: Flyer Card Complete Info E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Flyer Card Complete Info E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that each flyer card displays all required information accurately. Tests user action: viewing single flyer card in feed. Uses real backend, real database, real data.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating flyer card displays complete information through real system stack.

### Steps

1. Create E2E test file for flyer card display
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t12_flyer_card_complete_info.yaml`
   - Follow Maestro flow structure conventions
   - Reference test utilities in `pockitflyer_app/maestro/utils/` (if any exist)

2. Implement flyer card validation test
   - Test: 'Flyer card displays all required fields'
   - User launches app
   - System displays feed with flyer cards
   - Verify: Creator name/info visible
   - Verify: Title visible
   - Verify: Description visible
   - Verify: Location visible
   - Verify: Distance visible
   - Verify: Validity period visible

3. Add content variation scenarios
   - Test: 'Card handles long title and description'
   - Test: 'Card handles short title and description'
   - Verify text truncation/display works correctly

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t12_flyer_card_complete_info`
   - Verify test passes with real backend data
   - Capture evidence in test report

### Acceptance Criteria
- [ ] All required flyer fields display correctly [Verify: All 7 fields visible on card]
- [ ] Test validates real database content [Verify: Data matches backend response]
- [ ] Long and short content display correctly [Verify: Text formatting proper]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t12_flyer_card_complete_info.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for flyer card display. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, real flyer data

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates data from real database (not mocked)
- [ ] Evidence captured in maestro-reports directory
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t12

## Dependencies
- Requires: Backend Flyer model with all fields
- Requires: Backend Feed API returning complete flyer data
- Requires: Frontend FlyerCard widget implementation
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Backend must have test flyer with all fields populated (long/short variants)
- **UI elements**: Flyer card must have testable identifiers for Maestro
- **Evidence**: Screenshots saved to maestro-reports showing all fields
- **Isolation**: Test should work with any valid flyer in feed

## References
- Maestro assertVisible command for field validation
- Maestro flows documentation: pockitflyer_app/maestro/flows/README.md
