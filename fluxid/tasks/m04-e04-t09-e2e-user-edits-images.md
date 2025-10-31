---
id: m04-e04-t09
title: E2E Test - User Adds Removes Reorders Images
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Adds Removes Reorders Images

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates image editing operations (add, remove, reorder) with storage persistence and display updates end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating image editing operations through real system stack.

### Steps

1. Create Maestro E2E test file for image editing
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_edits_flyer_images.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (3 images initially)
   - Launch iOS app → authenticate

2. Implement add image test
   - Test: 'User adds new image to existing flyer'
   - Navigate to profile → edit flyer (flyer has 3 images)
   - Assert: 3 image thumbnails displayed
   - Tap "Add Image" button → select new test image
   - Assert: 4 image thumbnails displayed (new image at end)
   - Tap "Save Changes" → wait for success
   - Verify: Backend storage contains 4 image files
   - Navigate to feed → tap flyer → detail screen
   - Assert: Image carousel shows 4 images

3. Implement remove image test
   - Test: 'User removes image from flyer'
   - Navigate to profile → edit flyer (flyer has 4 images from previous test)
   - Tap "Remove" button on second image thumbnail → image removed
   - Assert: 3 image thumbnails displayed
   - Tap "Save Changes" → wait for success
   - Verify: Removed image deleted from backend storage
   - Verify: Database shows 3 image references
   - Navigate to feed → tap flyer → detail screen
   - Assert: Image carousel shows 3 images (removed image not visible)

4. Implement reorder images test
   - Test: 'User reorders flyer images'
   - Navigate to profile → edit flyer (flyer has 3 images)
   - Long-press first image → drag to third position → drop
   - Assert: Image order updated in edit form
   - Tap "Save Changes" → wait for success
   - Verify: Database shows updated image order
   - Navigate to feed → tap flyer → detail screen
   - Assert: Image carousel displays images in new order
   - Verify: First image in carousel matches third original image

5. Add cleanup
   - Cleanup: Delete test flyer and associated images from storage
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User adds image, saved to storage [Maestro: add image → save → verify 4 images in detail]
- [ ] User removes image, deleted from storage [Maestro: remove → save → verify 3 images in detail]
- [ ] User reorders images, order persists [Maestro: drag-drop → save → verify new order in detail]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_edits_flyer_images.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for image editing. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, file storage

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Add image operation works and persists
- [ ] Remove image operation works and deletes from storage
- [ ] Reorder images operation works and persists order
- [ ] Backend storage reflects changes (files added/removed)
- [ ] Database image references updated correctly
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t07 (Navigation to edit screen)
- Requires: m04-e02-t09 (Image edit widget implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Seed flyer with 3 initial images for editing
- **Storage verification**: Check backend `media/flyers/` directory for files
- **Image order**: Stored as position field in database or JSON array
- **Performance**: Image operations should complete within 3 seconds each
- **File cleanup**: Ensure removed images deleted from storage (not just DB)
- **Maestro drag-drop**: Use Maestro's drag gesture commands for reordering
- **5 image limit**: Verify add operation respects maximum image limit
