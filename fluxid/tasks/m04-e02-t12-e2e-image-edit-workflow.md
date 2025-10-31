---
id: m04-e02-t12
epic: m04-e02
title: E2E Test - Image Edit Operations
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Image Edit Operations

## Objective
Create Maestro end-to-end test specifically validating image editing operations: add, remove, reorder within 1-5 limit.

## Acceptance Criteria
- [ ] Test creates flyer with 3 images
- [ ] Test navigates to edit screen
- [ ] Test verifies 3 images displayed in correct order
- [ ] Test reorders images (drag image 3 to position 1)
- [ ] Test adds new image (brings total to 4)
- [ ] Test removes an image (brings total back to 3)
- [ ] Test verifies cannot add 6th image (add button disabled at 5)
- [ ] Test verifies cannot remove last image (remove disabled at 1)
- [ ] Test saves changes
- [ ] Test verifies new image order persisted
- [ ] Test verifies removed image deleted from storage
- [ ] Test tagged with `tdd_green` after passing

## Test Coverage Requirements
- Initial image display in correct order
- Drag-and-drop reordering works
- Add image opens picker and adds to gallery
- Add button disabled when 5 images present
- Remove image deletes from gallery
- Remove button disabled when 1 image present
- Attempting to remove last image shows error
- Save persists new image order
- Save uploads new images to backend
- Save deletes removed images from backend storage
- Changes reflected in flyer detail view

## Files to Modify/Create
- `maestro/flows/m04-e02-image-edit-workflow.yaml`
- `maestro/test-data/m04-e02-image-setup.sh`

## Dependencies
- M04-E02-T09 (Image edit widget)
- M04-E02-T02 (Backend update API with image handling)
- E2E test infrastructure from M01-E05

## Notes
- Maestro may have limitations with drag-and-drop - document workarounds
- Consider using test images from known URLs for consistency
- Verify storage cleanup by checking backend directly if possible
- Image operations are resource-intensive - allow sufficient timeouts
- Consider splitting into separate tests if too complex
