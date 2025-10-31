---
id: m01-e01-t20
title: Feed Performance E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Feed Performance E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates feed loads within 2 seconds on standard network. Tests user action: launching app and seeing feed. Uses real backend, real network conditions.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating feed performance meets 2-second load time requirement through real system stack.

### Steps

1. Create E2E test file for performance validation
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t20_feed_performance.yaml`
   - Follow Maestro flow structure conventions
   - Implement timing measurement in test

2. Implement load time test
   - Test: 'Feed loads within 2 seconds'
   - Record start time
   - User launches app
   - Wait for feed to display
   - Record end time
   - Verify: Load time ≤ 2000ms
   - Verify: All flyer cards rendered

3. Implement network condition test
   - Test: 'Feed meets performance on WiFi'
   - Ensure WiFi network connection
   - Measure load time
   - Verify: Meets 2-second requirement

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t20_feed_performance`
   - Capture timing evidence
   - Verify backend response time acceptable

### Acceptance Criteria
- [ ] Feed loads in ≤2 seconds [Verify: Timed measurement from launch to visible]
- [ ] Test measures real network performance [Verify: Real backend requests, no mocks]
- [ ] Performance consistent across runs [Verify: Multiple test runs within limit]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t20_feed_performance.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for feed performance. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real network

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test measures real network performance (not mocked)
- [ ] Evidence captured showing load time measurement
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t20

## Dependencies
- Requires: Backend Feed API with performance optimizations
- Requires: Backend database indexes on queried fields
- Requires: Frontend feed widget with efficient rendering
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Database should have realistic data volume (10-20 flyers)
- **Network**: Run on standard WiFi connection
- **Timing**: Measure from launchApp to first flyer card visible
- **Maestro timing**: Check if Maestro supports timing assertions
- **Evidence**: Test report showing measured load time
- **Tolerance**: Consider small variance in load times

## References
- Epic success criteria: "Feed loads within 2 seconds on standard network"
- Backend performance optimization implementation
- Database indexing strategy
