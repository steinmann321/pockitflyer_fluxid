---
id: m01-e01-t13
title: Image Carousel E2E Validation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Image Carousel E2E Validation

## Context
Part of E2E Milestone Validation (m01-e01) in Milestone 01 (m01).

Validates that flyer cards display image carousel correctly with multiple images. Tests user action: viewing and swiping flyer images. Uses real backend, real image storage.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating image carousel displays and swipes correctly through real system stack.

### Steps

1. Create E2E test file for image carousel
   - Create file `pockitflyer_app/maestro/flows/m01_e01_t13_image_carousel.yaml`
   - Follow Maestro flow structure conventions
   - Use Maestro swipe commands for carousel interaction

2. Implement single image test
   - Test: 'Flyer with one image displays correctly'
   - User launches app
   - Verify: Single image visible in flyer card
   - Verify: Image loaded from backend

3. Implement multiple images test
   - Test: 'Flyer with multiple images shows carousel'
   - User sees flyer with 3-5 images
   - User swipes left on image
   - Verify: Next image becomes visible
   - User swipes through all images
   - Verify: All images display correctly

4. Validate using test runner
   - Run test using `pockitflyer_app/maestro/run_tests.sh -f m01_e01_t13_image_carousel`
   - Verify images load from real backend storage
   - Capture screenshots showing carousel interaction

### Acceptance Criteria
- [ ] Single image flyers display image correctly [Verify: Image visible and loaded]
- [ ] Multi-image carousel swipes work [Verify: Swipe gesture changes image]
- [ ] Test uses real backend images [Verify: Images from backend storage service]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m01_e01_t13_image_carousel.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for image carousel. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real image storage

### Definition of Done
- [ ] Test passes against real backend
- [ ] Test validates images from real storage (not mocked)
- [ ] Evidence captured showing image carousel interaction
- [ ] No errors during test execution
- [ ] Test completes successfully
- [ ] Changes committed with reference to task ID m01-e01-t13

## Dependencies
- Requires: Backend image storage service implementation
- Requires: Frontend image carousel widget implementation
- Requires: Test flyers with 1 and 3-5 images in database
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use startup scripts from CONTRIBUTORS.md
- **Test data**: Backend must have flyers with varying image counts (1, 3, 5)
- **Image loading**: Allow time for real image downloads
- **Maestro swipe**: Use `swipe: {direction: LEFT}` command
- **Evidence**: Screenshots of different images in carousel

## References
- Maestro swipe command documentation
- Image carousel widget implementation for test identifiers
