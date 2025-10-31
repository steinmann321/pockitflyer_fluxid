---
id: m04-e02-t09
epic: m04-e02
title: Create Image Edit Widget with Reordering
status: pending
priority: medium
tdd_phase: red
---

# Task: Create Image Edit Widget with Reordering

## Objective
Build Flutter widget for editing flyer images with add, remove, and reorder capabilities while enforcing 1-5 image limit.

## Acceptance Criteria
- [ ] Widget displays existing images in current order
- [ ] Drag-and-drop reordering using ReorderableListView
- [ ] Add button to upload new images (disabled when at 5 images)
- [ ] Remove button on each image (disabled when at 1 image)
- [ ] Image picker integration for selecting new images
- [ ] Preview of newly selected images before save
- [ ] Clear visual indication of image order (numbers)
- [ ] Validation prevents removing last image
- [ ] Validation prevents adding 6th image
- [ ] Loading state during image upload
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget displays existing images
- Image order displayed correctly (1, 2, 3, etc.)
- Drag-and-drop reorder works
- Reorder updates order state correctly
- Add button opens image picker
- Add button disabled at 5 images
- Selected image appears in preview
- Remove button deletes image
- Remove button disabled at 1 image
- Attempting to remove last image shows error
- Attempting to add 6th image shows error
- New images marked for upload on save

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/image_edit_widget.dart` (ImageEditWidget)
- `pockitflyer_app/lib/widgets/image_item_card.dart` (individual image card with remove button)
- `pockitflyer_app/test/widgets/image_edit_widget_test.dart`

## Dependencies
- M04-E01 (Image picker integration from creation screen)
- Flutter packages: image_picker, reorderable

## Notes
- Consider using image_picker package for camera and gallery selection
- Reordering should be smooth with haptic feedback
- Show image thumbnails, not full resolution, for performance
- Mark images for upload vs existing images for API client
- Consider using cached_network_image for existing images
- Provide clear visual feedback for which images are new vs existing
- Consider compression/resizing before upload in future iteration
