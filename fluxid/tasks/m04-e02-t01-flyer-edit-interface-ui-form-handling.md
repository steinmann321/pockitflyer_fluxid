---
id: m04-e02-t01
title: Flyer Edit Interface UI and Form Handling
epic: m04-e02
milestone: m04
status: pending
---

# Task: Flyer Edit Interface UI and Form Handling

## Context
Part of Flyer Editing (m04-e02) in Milestone 4 (Creator Profile & Content Management).

This task creates the complete frontend editing interface that allows users to modify all aspects of their published flyers. Users navigate from their profile's flyer list to this edit screen, which pre-populates with existing flyer data and allows modification of images, text content, categories, location, and dates. This is a pure UI/form handling task with validation and state management - backend integration happens in m04-e02-t02.

## Implementation Guide for LLM Agent

### Objective
Create a complete flyer edit screen with form validation, image upload preview, and navigation integration that allows users to modify all flyer fields.

### Steps

1. Create flyer edit screen component
   - Create `pockitflyer_app/lib/screens/flyer_edit_screen.dart`
   - Accept flyer ID as navigation parameter
   - Define state variables for all editable fields:
     - `List<File> selectedImages` (1-5 images)
     - `String title`
     - `String description`
     - `String infoText`
     - `List<String> selectedCategories`
     - `String address`
     - `DateTime publicationDate`
     - `DateTime expirationDate`
     - `bool isLoading`
     - `String? errorMessage`

2. Implement data loading on screen initialization
   - On screen mount, fetch flyer data by ID from backend API
   - Pre-populate all form fields with existing values
   - Load existing images for display
   - Handle loading state and error scenarios (flyer not found, network error)
   - Verify user owns the flyer (display error if not authorized)

3. Build UI layout with editable fields
   - **Header**: App bar with "Edit Flyer" title and back button
   - **Image Section**:
     - Display current images with ability to remove individual images
     - "Add Image" button (disabled when 5 images reached)
     - Image picker integration (camera + gallery)
     - Image preview grid with reorder capability
     - Display validation error if <1 or >5 images
   - **Text Fields**:
     - Title text field (max 100 characters, required)
     - Description text area (max 500 characters, required)
     - Info text area (max 500 characters, optional)
     - Character counters for all text fields
   - **Category Selection**:
     - Multi-select chips or dropdown for categories
     - Display selected categories with remove option
     - Fetch category list from backend or use predefined list
   - **Address Field**:
     - Text field for address input (required)
     - Validation feedback for address format
   - **Date Pickers**:
     - Publication date picker (required)
     - Expiration date picker (required, must be after publication date)
     - Display validation error if dates invalid
   - **Action Buttons**:
     - "Save Changes" button (primary, disabled during validation errors)
     - "Cancel" button (secondary, navigates back)

4. Implement form validation logic
   - **Image Validation**:
     - At least 1 image required
     - Maximum 5 images allowed
     - Image file size limit (e.g., 5MB per image)
     - Image format validation (JPEG, PNG)
   - **Text Validation**:
     - Title: required, 1-100 characters
     - Description: required, 1-500 characters
     - Info text: optional, max 500 characters
   - **Category Validation**:
     - At least one category selected
   - **Address Validation**:
     - Required field
     - Basic format validation (non-empty, reasonable length)
   - **Date Validation**:
     - Both dates required
     - Expiration date must be after publication date
     - Dates must be valid DateTime objects
   - Display inline error messages for each field
   - Disable "Save" button when validation fails

5. Implement save functionality
   - On "Save Changes" tap:
     - Run full form validation
     - If invalid, display error messages and prevent save
     - If valid, set `isLoading = true`
     - Prepare data payload with all field values
     - Call backend update endpoint (API call logic prepared, actual integration in m04-e02-t02)
     - Handle success: show success message, navigate back to profile
     - Handle errors: display error message (validation errors, network errors, authorization errors)
     - Set `isLoading = false`

6. Implement image handling
   - **Add Image**:
     - Open image picker (camera or gallery)
     - Validate selected image (size, format)
     - Add to `selectedImages` list if <5 images
     - Update preview grid
   - **Remove Image**:
     - Remove from `selectedImages` list
     - Update preview grid
     - Re-enable "Add Image" button if <5 images
   - **Reorder Images** (optional enhancement):
     - Allow drag-and-drop or move up/down buttons
     - Update `selectedImages` list order

7. Implement navigation integration
   - Add navigation route for flyer edit screen
   - Update profile screen's flyer list to include "Edit" button for each flyer
   - Pass flyer ID as navigation parameter
   - Handle back navigation (prompt if unsaved changes exist)

8. Add loading and error UI states
   - Loading spinner during initial data fetch
   - Loading overlay during save operation
   - Error banner for fetch/save errors
   - Empty state if flyer not found
   - Authorization error state if user doesn't own flyer

9. Create comprehensive test suite
   - **Widget Tests** (UI components):
     - Test: screen renders with all form fields
     - Test: form pre-populated with flyer data on load
     - Test: image picker opens on "Add Image" tap
     - Test: images can be removed from preview
     - Test: date pickers open and update dates
     - Test: character counters update as user types
     - Test: validation errors displayed inline
     - Test: "Save" button disabled when validation fails
   - **Unit Tests** (validation logic):
     - Test: image count validation (0, 1, 5, 6 images)
     - Test: text field validation (empty, too long, valid)
     - Test: date validation (expiration before publication, valid dates)
     - Test: category validation (none selected, multiple selected)
   - **Integration Tests** (workflow):
     - Test: full edit workflow with valid data
     - Test: cancel navigation without saving
     - Test: unsaved changes prompt on back navigation
     - Test: error handling for failed data fetch
     - Test: error handling for failed save

### Acceptance Criteria
- [ ] Edit screen navigable from profile flyer list [Test: navigation passes flyer ID, screen renders]
- [ ] Form pre-populated with current flyer data [Test: all fields show existing values after load]
- [ ] All fields editable with proper input types [Test: text fields, date pickers, image picker, category selector]
- [ ] Image management works: add (1-5), remove, preview [Test: add images up to 5, remove images, count validation]
- [ ] Validation prevents invalid saves [Test: empty title, >500 char description, 0 images, 6 images, expiration before publication]
- [ ] Inline validation errors displayed [Test: error messages appear below invalid fields]
- [ ] "Save" button disabled during validation errors [Test: button state changes based on validation]
- [ ] Loading states shown during fetch/save [Test: spinner during load, overlay during save]
- [ ] Error scenarios handled gracefully [Test: network error, flyer not found, unauthorized access]
- [ ] Success navigation back to profile after save [Test: successful save redirects to profile]
- [ ] All tests pass with >85% coverage [Test: run widget, unit, integration tests]

### Files to Create/Modify
- `pockitflyer_app/lib/screens/flyer_edit_screen.dart` - NEW: Complete edit screen UI and logic
- `pockitflyer_app/lib/widgets/image_picker_grid.dart` - NEW: Reusable image picker widget with preview
- `pockitflyer_app/lib/widgets/category_selector.dart` - NEW: Category multi-select widget
- `pockitflyer_app/lib/services/flyer_validation_service.dart` - NEW: Form validation logic
- `pockitflyer_app/lib/models/flyer_edit_form.dart` - NEW: Form state model
- `pockitflyer_app/lib/main.dart` - MODIFY: Add route for flyer edit screen
- `pockitflyer_app/test/screens/flyer_edit_screen_test.dart` - NEW: Widget tests
- `pockitflyer_app/test/services/flyer_validation_service_test.dart` - NEW: Unit tests
- `pockitflyer_app/test/integration/flyer_edit_workflow_test.dart` - NEW: Integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - Validation service: all validation rules (image count, text length, date logic, category requirements)
  - Form state model: state transitions, data transformations
  - Edge cases: boundary values (0, 1, 5, 6 images; empty, max-length, over-length text)
- **Widget tests**:
  - Screen renders all form fields correctly
  - Form pre-population with flyer data
  - User interactions (text input, date picker, image picker, category selection)
  - Validation error display
  - Button state changes (enabled/disabled)
  - Loading and error states
- **Integration tests**:
  - Complete edit workflow with mocked API (load → edit → validate → save → navigate)
  - Error recovery workflows (network failure, validation failure)
  - Unsaved changes prompt
  - Authorization check (non-owner trying to edit)

**Testing pyramid balance**: 60% unit (validation logic), 30% widget (UI components), 10% integration (workflows)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter/Dart conventions
- [ ] No console errors or warnings
- [ ] Form validation comprehensive and user-friendly
- [ ] UI matches design requirements (responsive, accessible)
- [ ] Changes committed with reference to m04-e02-t01
- [ ] Ready for backend integration in m04-e02-t02

## Dependencies
- Requires: m04-e01 (profile view exists for navigation context)
- Requires: m02 (authentication system for user verification)
- Blocks: m04-e02-t02 (backend integration needs this UI to be complete)

## Technical Notes

**Flutter/Dart Specifics**:
- Use `StatefulWidget` for flyer edit screen (needs local state management)
- Consider using `Form` widget with `GlobalKey<FormState>` for unified validation
- Use `ImagePicker` package for image selection
- Use `showDatePicker` for date selection
- Implement `WillPopScope` for unsaved changes prompt

**State Management**:
- Local state is sufficient for form data (no need for global state)
- Consider using `ChangeNotifier` or `ValueNotifier` for complex form state
- Separate validation logic into service for testability

**Image Handling**:
- Store images as `File` objects during editing
- Display existing images via network URL, new images via file path
- Track which images are new vs. existing for backend update logic

**Validation Approach**:
- Real-time validation on field blur/change for better UX
- Full form validation on save attempt
- Clear, actionable error messages

**Navigation**:
- Use named routes for better maintainability
- Pass flyer ID via route arguments
- Handle navigation from profile screen's flyer list

**Error Handling**:
- Network errors: display retry option
- Validation errors: inline messages
- Authorization errors: clear message + navigate back
- Not found errors: display message + navigate back

**Accessibility**:
- Proper labels for form fields
- Error messages announced to screen readers
- Keyboard navigation support
- Sufficient touch target sizes

## References
- Flutter Form Validation: https://flutter.dev/docs/cookbook/forms/validation
- ImagePicker package: https://pub.dev/packages/image_picker
- Date Picker: https://api.flutter.dev/flutter/material/showDatePicker.html
- Project's existing form patterns (if any)
- Project's navigation structure
