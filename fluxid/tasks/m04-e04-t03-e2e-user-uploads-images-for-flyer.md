---
id: m04-e04-t03
title: E2E Test - User Uploads Images for New Flyer
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Uploads Images for New Flyer

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates user image upload workflow (1-5 images) with real image storage service end-to-end with NO MOCKS. Tests image picker integration, upload progress, and storage persistence.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating image upload workflow through real system stack.

### Steps

1. Create Maestro E2E test file for image upload
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_uploads_flyer_images.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user (use M04 test fixtures)
   - Launch iOS app → authenticate → navigate to creation screen

2. Implement single image upload test
   - Test: 'User uploads single image for flyer'
   - Tap "Add Image" button → iOS image picker opens
   - Select test image from simulator photos (pre-seeded test images)
   - Assert: Upload progress indicator appears
   - Assert: Image thumbnail displays in creation form
   - Assert: Backend receives image file (check backend logs)
   - Assert: Image stored in backend media directory

3. Implement multiple image upload test
   - Test: 'User uploads multiple images (up to 5)'
   - Tap "Add Image" button 5 times → select 5 different test images
   - Assert: All 5 thumbnails display in creation form
   - Assert: Images appear in correct order (upload sequence)
   - Assert: 5 image files stored in backend media directory

4. Implement validation test
   - Test: 'Upload enforces 5 image maximum'
   - Upload 5 images successfully
   - Tap "Add Image" button again → button disabled or shows limit message
   - Assert: Only 5 images in form

5. Add cleanup
   - Cleanup: Remove uploaded test images from backend storage
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User uploads single image, thumbnail displays [Maestro: tapOn "Add Image" → assertVisible image thumbnail]
- [ ] User uploads 5 images, all display in order [Maestro: 5 uploads → assertVisible 5 thumbnails]
- [ ] Backend stores images in media directory [Verify: backend logs show file paths]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_uploads_flyer_images.yaml` - NEW: E2E test
- `pockitflyer_app/maestro/utils/seed_simulator_images.sh` - NEW: Script to add test images to simulator

### Testing Requirements
**Note**: This task IS the E2E testing for image upload. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, real file storage

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Single image upload works end-to-end
- [ ] Multiple image upload (5 images) works end-to-end
- [ ] Images stored in backend media directory
- [ ] Backend logs show image upload requests
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t02 (Authenticated user Flyern access)
- Requires: m04-e01-t05 (Image upload widget implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test images**: Pre-seed iOS simulator with test images (3-5 images, various sizes)
- **Image storage**: Backend stores images in `media/flyers/` directory
- **File size**: Test with realistic image sizes (500KB-2MB)
- **Performance**: Single image upload should complete in <5 seconds
- **Maestro image picker**: Use Maestro's iOS native interaction commands for image picker
- **Cleanup**: Delete test images from backend media directory after test
