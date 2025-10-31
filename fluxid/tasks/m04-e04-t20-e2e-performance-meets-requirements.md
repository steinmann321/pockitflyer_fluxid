---
id: m04-e04-t20
title: E2E Test - Performance Meets Requirements
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Performance Meets Requirements

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates performance requirements for M04 workflows: image upload <5s, feed update <2s, geocoding <3s, smooth UI transitions end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating performance benchmarks through real system stack.

### Steps

1. Create Maestro E2E test file for performance validation
   - Create file `pockitflyer_app/maestro/flows/m04-e04/performance_meets_requirements.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user and 100+ existing flyers (realistic load)
   - Launch iOS app → authenticate

2. Implement image upload performance test
   - Test: 'Image upload completes within 5 seconds'
   - Navigate to creation screen
   - Note start time
   - Tap "Add Image" → select test image (2MB realistic size)
   - Wait for image upload to complete
   - Note end time
   - Assert: Upload duration < 5 seconds
   - Verify: Backend logs show upload completion time

3. Implement feed update performance test
   - Test: 'Feed refresh with new flyer completes within 2 seconds'
   - Create new flyer
   - Navigate to main feed
   - Note start time
   - Pull-to-refresh feed
   - Wait for feed to load
   - Note end time
   - Assert: Feed refresh duration < 2 seconds
   - Assert: New flyer visible in feed

4. Implement geocoding performance test
   - Test: 'Geocoding completes within 3 seconds'
   - Navigate to creation screen
   - Fill all fields
   - Input address: "Bahnhofstrasse 1, 8001 Zurich"
   - Note start time
   - Tap "Publish" (triggers geocoding)
   - Wait for success message
   - Note end time
   - Assert: Total time (including geocoding) < 3 seconds
   - Verify: Backend logs show geopy response time

5. Implement flyer creation total time test
   - Test: 'Complete flyer creation workflow completes within 10 seconds'
   - Navigate to creation screen
   - Note start time
   - Upload 1 image → fill all fields → tap "Publish"
   - Wait for success message
   - Note end time
   - Assert: Total creation time < 10 seconds (reasonable user expectation)

6. Implement edit save performance test
   - Test: 'Flyer edit save completes within 2 seconds'
   - Navigate to profile → edit flyer
   - Edit title field
   - Note start time
   - Tap "Save Changes"
   - Wait for success message
   - Note end time
   - Assert: Save duration < 2 seconds

7. Implement large dataset performance test
   - Test: 'Feed loads quickly with 100+ flyers in database'
   - Ensure 100+ flyers in database (use M04 test data)
   - Navigate to main feed
   - Note start time
   - Wait for feed to load
   - Note end time
   - Assert: Feed load time < 2 seconds
   - Assert: Smooth scrolling (no lag)

8. Implement UI transition performance test
   - Test: 'UI transitions are smooth and instant'
   - Test rapid navigation: feed → detail → back → profile → feed
   - Assert: All transitions complete instantly (<200ms visual delay)
   - Assert: No frame drops or stuttering

9. Add cleanup
   - Cleanup: Delete created test flyers
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Image upload <5s [Maestro: measure upload time, assert <5000ms]
- [ ] Feed refresh <2s [Maestro: measure refresh time, assert <2000ms]
- [ ] Geocoding <3s [Maestro: measure creation time with geocoding, assert <3000ms]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/performance_meets_requirements.yaml` - NEW: E2E test
- `pockitflyer_backend/users/tests/utils/performance_benchmarks.py` - NEW: Helper for backend performance logging

### Testing Requirements
**Note**: This task IS the E2E testing for performance. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, services with realistic load

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Image upload completes within 5 seconds
- [ ] Feed refresh completes within 2 seconds
- [ ] Geocoding completes within 3 seconds
- [ ] All UI transitions smooth and instant
- [ ] Performance meets requirements with 100+ flyers
- [ ] Backend performance logs available for analysis
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure with 100+ flyers)
- Requires: m04-e01, m04-e02, m04-e03 (All M04 feature implementations)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Realistic data**: Test with 100+ flyers for realistic performance conditions
- **Image size**: Use 2MB test images (realistic user photos)
- **Network conditions**: Test on localhost (best case) or simulate realistic network
- **Measurement**: Use Maestro's timing capabilities or backend logs
- **Performance targets**:
  - Image upload: <5s
  - Feed refresh: <2s
  - Geocoding: <3s
  - UI transitions: <200ms
  - Total creation: <10s
- **Database indexing**: Ensure proper indexes (distance, category, created_at)
- **Caching**: Validate caching strategies (images, geocoding)
- **Optimization**: If performance fails, investigate bottlenecks (queries, N+1, etc.)
