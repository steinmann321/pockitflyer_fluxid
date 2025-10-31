---
id: m02-e02-t02
title: Frontend Image Upload with Multi-Select and Preview
epic: m02-e02
milestone: m02
status: pending
---

# Task: Frontend Image Upload with Multi-Select and Preview

## Context
Part of Flyer Creation & Publishing (m02-e02) in Milestone m02 (Authenticated User Experience).

Implements image upload functionality for the flyer creation form, allowing users to select 1-5 images from their device, preview them, reorder them, and remove unwanted images before publishing. This component integrates into the form structure created in t01.

## Implementation Guide for LLM Agent

### Objective
Create image picker component with multi-select (1-5 images), preview grid, reordering, and removal capabilities integrated into the flyer creation form.

### Steps

1. Add image picker dependency
   - Add `image_picker` package to `pubspec.yaml`
   - Version: latest stable (e.g., `image_picker: ^1.0.0`)
   - Run `flutter pub get`

2. Create image picker service/wrapper
   - File: `lib/services/image_picker_service.dart`
   - Method: `pickMultipleImages(int maxCount)` → returns List<File> or null
   - Handle iOS permissions (automatically handled by image_picker)
   - Handle max count limit (1-5 images)
   - Handle file type validation (JPEG, PNG, WebP)
   - Handle file size validation (5MB per image)
   - Return error messages for validation failures

3. Create image preview widget
   ```dart
   // ImagePreviewGrid widget structure
   Widget ImagePreviewGrid:
     Input:
       - List<File> selectedImages
       - Function onRemove(int index)
       - Function onReorder(int oldIndex, int newIndex)

     Display:
       - Grid layout (2 columns)
       - Each image shows:
         * Thumbnail preview (square, cover fit)
         * Remove button (X icon in top-right corner)
         * Image index badge (1, 2, 3, etc.)
       - Drag handles for reordering (long-press to drag)
       - Empty state: "No images selected"
   ```

4. Create image selection button widget
   ```dart
   // ImageSelectionButton widget
   Widget ImageSelectionButton:
     - Button text: "Add Images (1-5)"
     - Icon: camera or image icon
     - Shows count: "Add Images (2/5)" when images selected
     - Disabled when 5 images already selected
     - On tap: trigger image picker
   ```

5. Integrate image components into flyer creation form
   - Import image picker service and widgets into `FlyerCreationForm`
   - Add image state to form provider:
     * `List<File> selectedImages`
     * `String? imageError`
   - Place image selection button near top of form (after title field)
   - Place image preview grid below selection button
   - Update form validation to include image requirement (at least 1 image)

6. Implement image selection flow
   ```dart
   // Image selection handler
   onAddImagesPressed():
     1. Calculate remaining slots (5 - current count)
     2. Call imagePickerService.pickMultipleImages(remainingSlots)
     3. Validate each selected image:
        - File type (JPEG, PNG, WebP)
        - File size (≤5MB)
     4. If validation fails:
        - Set imageError message
        - Show snackbar/alert with error
        - Don't add invalid images
     5. If validation passes:
        - Add to selectedImages list
        - Clear imageError
        - Update UI (preview grid)
   ```

7. Implement image removal
   ```dart
   onRemoveImage(int index):
     - Remove image at index from selectedImages
     - Update UI
     - Re-enable selection button if was at max (5)
     - Update form validation state
   ```

8. Implement image reordering (optional enhancement)
   ```dart
   onReorderImages(int oldIndex, int newIndex):
     - Reorder images in selectedImages list
     - Update UI with new order
     - Preserve order for backend submission
   ```

9. Add loading and error states
   - Show loading spinner while image picker is open
   - Show error message below image section if validation fails
   - Clear error when new valid images added
   - Handle picker cancellation gracefully

10. Create image upload widget tests
    - Test: Selection button shows correct count (0/5, 2/5, 5/5)
    - Test: Selection button disabled at max images
    - Test: Image preview grid displays selected images
    - Test: Remove button removes correct image
    - Test: Reorder updates image order
    - Test: Validation rejects >5MB images
    - Test: Validation rejects unsupported file types
    - Test: Validation requires at least 1 image
    - Test: Error messages display correctly

11. Create integration tests
    - Test: Select single image, verify preview
    - Test: Select multiple images (5), verify all previewed
    - Test: Remove image, verify count updated
    - Test: Attempt to select 6 images, verify only 5 added
    - Test: Select large file, verify error shown
    - Test: Form validation fails with 0 images
    - Test: Form validation passes with 1+ images

### Acceptance Criteria
- [ ] Image selection button triggers image picker [Test: tap button, picker opens]
- [ ] Users can select 1-5 images in a single pick [Test: multi-select in picker]
- [ ] Selection button shows current count (e.g., "2/5") [Test: select images, verify count]
- [ ] Selection button disabled when 5 images selected [Test: select 5, verify disabled]
- [ ] Image preview grid displays all selected images [Test: select 3, verify 3 thumbnails]
- [ ] Each preview shows remove button [Test: verify X button on each thumbnail]
- [ ] Remove button deletes correct image [Test: remove 2nd image, verify correct image gone]
- [ ] Image reordering works via drag-and-drop [Test: drag 1st to 3rd position]
- [ ] File size validation rejects >5MB images [Test: select 6MB file, verify error]
- [ ] File type validation accepts JPEG, PNG, WebP [Test: select each type]
- [ ] File type validation rejects other types [Test: select GIF/PDF, verify error]
- [ ] Form validation requires at least 1 image [Test: submit with 0 images, verify error]
- [ ] Error messages display for validation failures [Test: trigger error, verify message]
- [ ] Widget tests pass with ≥90% coverage
- [ ] Integration tests pass for complete image flow

### Files to Create/Modify
- `pockitflyer_app/pubspec.yaml` - MODIFY: add image_picker dependency
- `pockitflyer_app/lib/services/image_picker_service.dart` - NEW: image picker wrapper
- `pockitflyer_app/lib/widgets/image_preview_grid.dart` - NEW: preview grid widget
- `pockitflyer_app/lib/widgets/image_selection_button.dart` - NEW: selection button widget
- `pockitflyer_app/lib/widgets/flyer_creation_form.dart` - MODIFY: integrate image components
- `pockitflyer_app/lib/providers/flyer_creation_provider.dart` - MODIFY: add image state
- `pockitflyer_app/test/widgets/image_preview_grid_test.dart` - NEW: widget tests
- `pockitflyer_app/test/services/image_picker_service_test.dart` - NEW: service tests
- `pockitflyer_app/test/integration/image_upload_flow_test.dart` - NEW: integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - ImagePickerService: max count limit, file size validation, file type validation
  - Form validation: image count requirement

- **Widget tests**:
  - ImagePreviewGrid: rendering, remove button, reordering
  - ImageSelectionButton: count display, enabled/disabled states
  - Error message display

- **Integration tests** (mock image_picker):
  - Complete image selection flow
  - Multi-image selection and preview
  - Image removal and count updates
  - Validation error scenarios
  - Form integration (images affect form validation state)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter and project conventions
- [ ] No console errors or warnings
- [ ] Image picker handles iOS permissions correctly
- [ ] Image previews are performant (no lag with 5 images)
- [ ] Changes committed with `m02-e02-t02` reference
- [ ] Ready for integration with t04 (backend image upload)

## Dependencies
- Requires: m02-e02-t01 (flyer creation form structure)
- Blocks: m02-e02-t04 (backend needs image files from frontend)

## Technical Notes

**iOS Permissions**:
- `image_picker` automatically requests photo library access
- Add to `Info.plist`:
  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need access to your photo library to upload flyer images</string>
  ```

**Image Picker Configuration**:
- Use `ImagePicker.pickMultiImage()` for multi-select
- Set `maxWidth` and `maxHeight` for automatic resizing (optional)
- Set `imageQuality` (0-100) to compress images client-side

**File Validation**:
- Size check: `file.lengthSync()` in bytes (5MB = 5 * 1024 * 1024)
- Type check: file extension or MIME type (image_picker provides MIME)
- Perform validation client-side to avoid unnecessary uploads

**Performance Considerations**:
- Use `Image.file()` with `cacheWidth`/`cacheHeight` for thumbnails
- Avoid loading full-resolution images in preview grid
- Consider image compression before upload (reduce bandwidth)

**UX Guidelines**:
- Show image count prominently (helps users understand limit)
- Preview should be immediate (no loading delay)
- Remove button should be easily tappable (adequate size)
- Reordering should feel natural (visual feedback during drag)
- Error messages should be specific ("Image too large: max 5MB")

**Reordering Implementation**:
- Use `ReorderableListView` or similar
- Update image order in state
- Preserve order for backend submission (images[0] = primary)

**State Management**:
- Store `List<File>` in form provider
- Don't store image bytes in state (too heavy)
- Keep file references, load thumbnails on-demand

## References
- image_picker package: https://pub.dev/packages/image_picker
- Flutter image handling: https://docs.flutter.dev/cookbook/images
- File size validation: https://api.flutter.dev/flutter/dart-io/File/lengthSync.html
- ReorderableListView: https://api.flutter.dev/flutter/material/ReorderableListView-class.html
