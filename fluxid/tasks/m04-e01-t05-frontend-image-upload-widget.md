---
id: m04-e01-t05
epic: m04-e01
title: Create Image Upload Widget
status: pending
priority: high
tdd_phase: red
---

# Task: Create Image Upload Widget

## Objective
Build Flutter widget for uploading, previewing, and reordering 1-5 images with validation and progress feedback.

## Acceptance Criteria
- [ ] Image picker integration (camera and gallery options)
- [ ] Display up to 5 image slots with "Add Image" placeholders
- [ ] Image preview thumbnails with delete button
- [ ] Drag-and-drop reordering of uploaded images
- [ ] Validation: minimum 1 image, maximum 5 images
- [ ] File size validation: max 10MB per image
- [ ] Format validation: JPEG, PNG, HEIC only
- [ ] Progress indicator for large file uploads (>1MB)
- [ ] Error messages for validation failures
- [ ] Disabled state during upload
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Image picker invocation (camera, gallery)
- Image addition (1-5 images)
- Image deletion
- Reordering functionality
- Validation: 0 images, 6+ images, invalid formats, oversized files
- Progress indicator display for large files
- Error message display
- Disabled state during upload
- Widget tests and golden tests

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/image_upload_widget.dart`
- `pockitflyer_app/lib/services/image_picker_service.dart`
- `pockitflyer_app/test/widgets/image_upload_widget_test.dart`
- `pockitflyer_app/test/services/image_picker_service_test.dart`
- `pockitflyer_app/test/golden/image_upload_widget/`

## Dependencies
- Flutter `image_picker` package
- Flutter `reorderable_list` or similar package

## Notes
- Use `image_picker` package for camera/gallery access
- Compress images client-side before upload (reduce bandwidth)
- Display image order numbers (1, 2, 3...)
- First image is primary/cover image
- Consider aspect ratio cropping options
- Thumbnail size: 100x100px for UI
- Store original files for upload
