---
id: m04-e01-t02
title: Profile Edit Interface UI and Validation
epic: m04-e01
milestone: m04
status: pending
---

# Task: Profile Edit Interface UI and Validation

## Context
Part of Profile Management (m04-e01) in Milestone 4 (m04).

Creates the profile editing interface where users can update their display name, profile picture, and privacy settings. This screen is accessed from the "Edit Profile" button on the profile view page (m04-e01-t01). The interface includes client-side validation, image preview, and integration with the backend update endpoint (m04-e01-t03).

## Implementation Guide for LLM Agent

### Objective
Implement profile edit screen UI in Flutter with form validation, image upload, and state management for profile updates.

### Steps

1. Create profile edit data models
   - Create `pockitflyer_app/lib/models/profile_update_request.dart`
   - Define ProfileUpdateRequest class with freezed/json_serializable:
     ```dart
     @freezed
     class ProfileUpdateRequest with _$ProfileUpdateRequest {
       const factory ProfileUpdateRequest({
         String? displayName,
         String? profilePictureBase64, // Base64 encoded image
         bool? emailContactAllowed,
       }) = _ProfileUpdateRequest;

       factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) => _$ProfileUpdateRequestFromJson(json);
     }
     ```
   - Run build_runner to generate code: `flutter pub run build_runner build`

2. Extend profile API service with update method
   - Modify `pockitflyer_app/lib/services/profile_service.dart`
   - Add updateProfile method:
     ```dart
     Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
       final response = await _dio.patch(
         '/api/users/me/profile',
         data: request.toJson(),
       );
       return UserProfile.fromJson(response.data);
     }
     ```
   - Add error handling (400 validation errors, 401 unauthorized, 413 payload too large for images, network errors)

3. Create form validation utilities
   - Create `pockitflyer_app/lib/utils/profile_validators.dart`
   - Define validation functions:
     ```dart
     class ProfileValidators {
       static String? validateDisplayName(String? value) {
         if (value == null || value.trim().isEmpty) {
           return 'Display name is required';
         }
         if (value.trim().length < 2) {
           return 'Display name must be at least 2 characters';
         }
         if (value.trim().length > 50) {
           return 'Display name must be less than 50 characters';
         }
         // Check for special characters (allow letters, numbers, spaces, basic punctuation)
         final validPattern = RegExp(r'^[a-zA-Z0-9\s\-_.]+$');
         if (!validPattern.hasMatch(value)) {
           return 'Display name contains invalid characters';
         }
         return null;
       }

       static String? validateProfileImage(File? imageFile) {
         if (imageFile == null) return null; // Optional field

         final fileSizeBytes = imageFile.lengthSync();
         const maxSizeBytes = 5 * 1024 * 1024; // 5MB
         if (fileSizeBytes > maxSizeBytes) {
           return 'Image must be less than 5MB';
         }

         final extension = imageFile.path.split('.').last.toLowerCase();
         final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
         if (!allowedExtensions.contains(extension)) {
           return 'Image must be JPG, PNG, or WebP format';
         }

         return null;
       }
     }
     ```

4. Create image picker and encoding utilities
   - Create `pockitflyer_app/lib/utils/image_utils.dart`
   - Add image_picker dependency to pubspec.yaml: `image_picker: ^1.0.0`
   - Implement image utilities:
     ```dart
     class ImageUtils {
       static Future<File?> pickImageFromGallery() async {
         final picker = ImagePicker();
         final pickedFile = await picker.pickImage(
           source: ImageSource.gallery,
           maxWidth: 1024,
           maxHeight: 1024,
           imageQuality: 85,
         );
         return pickedFile != null ? File(pickedFile.path) : null;
       }

       static Future<String> encodeImageToBase64(File imageFile) async {
         final bytes = await imageFile.readAsBytes();
         return base64Encode(bytes);
       }
     }
     ```

5. Create profile edit provider
   - Create `pockitflyer_app/lib/providers/profile_edit_provider.dart`
   - Define ProfileEditNotifier with state management:
     ```dart
     @freezed
     class ProfileEditState with _$ProfileEditState {
       const factory ProfileEditState({
         required UserProfile originalProfile,
         required String displayName,
         File? newProfileImage,
         String? profileImagePreviewUrl,
         required bool emailContactAllowed,
         @Default(false) bool isSubmitting,
         String? errorMessage,
       }) = _ProfileEditState;
     }

     @riverpod
     class ProfileEditNotifier extends _$ProfileEditNotifier {
       @override
       ProfileEditState build(UserProfile profile) {
         return ProfileEditState(
           originalProfile: profile,
           displayName: profile.displayName,
           profileImagePreviewUrl: profile.profilePictureUrl,
           emailContactAllowed: profile.emailContactAllowed,
         );
       }

       void updateDisplayName(String name) {
         state = state.copyWith(displayName: name, errorMessage: null);
       }

       Future<void> pickImage() async {
         final imageFile = await ImageUtils.pickImageFromGallery();
         if (imageFile != null) {
           final validationError = ProfileValidators.validateProfileImage(imageFile);
           if (validationError != null) {
             state = state.copyWith(errorMessage: validationError);
             return;
           }
           state = state.copyWith(
             newProfileImage: imageFile,
             profileImagePreviewUrl: imageFile.path,
             errorMessage: null,
           );
         }
       }

       void toggleEmailContact(bool value) {
         state = state.copyWith(emailContactAllowed: value, errorMessage: null);
       }

       Future<bool> saveChanges() async {
         // Validate display name
         final nameError = ProfileValidators.validateDisplayName(state.displayName);
         if (nameError != null) {
           state = state.copyWith(errorMessage: nameError);
           return false;
         }

         state = state.copyWith(isSubmitting: true, errorMessage: null);

         try {
           final profileService = ref.read(profileServiceProvider);

           // Encode image if new one selected
           String? imageBase64;
           if (state.newProfileImage != null) {
             imageBase64 = await ImageUtils.encodeImageToBase64(state.newProfileImage!);
           }

           final request = ProfileUpdateRequest(
             displayName: state.displayName != state.originalProfile.displayName ? state.displayName : null,
             profilePictureBase64: imageBase64,
             emailContactAllowed: state.emailContactAllowed != state.originalProfile.emailContactAllowed ? state.emailContactAllowed : null,
           );

           final updatedProfile = await profileService.updateProfile(request);

           // Refresh profile in main provider
           ref.invalidate(profileNotifierProvider);

           state = state.copyWith(isSubmitting: false);
           return true;
         } catch (e) {
           String errorMessage = 'Failed to update profile';
           if (e is DioException) {
             if (e.response?.statusCode == 400) {
               errorMessage = e.response?.data['error'] ?? 'Invalid input';
             } else if (e.response?.statusCode == 413) {
               errorMessage = 'Image is too large';
             } else if (e.response?.statusCode == 401) {
               errorMessage = 'Unauthorized. Please log in again.';
             } else {
               errorMessage = 'Network error. Please try again.';
             }
           }
           state = state.copyWith(isSubmitting: false, errorMessage: errorMessage);
           return false;
         }
       }

       bool hasChanges() {
         return state.displayName != state.originalProfile.displayName ||
                state.newProfileImage != null ||
                state.emailContactAllowed != state.originalProfile.emailContactAllowed;
       }
     }
     ```

6. Create profile edit screen widget
   - Create `pockitflyer_app/lib/screens/profile_edit_screen.dart`
   - Implement ProfileEditScreen widget:
     - Accept UserProfile as parameter (from navigation)
     - Use Scaffold with AppBar (title: "Edit Profile", back button, save button in actions)
     - Initialize ProfileEditNotifier with current profile
     - Use Form widget with GlobalKey<FormState>
     - Sections:

       **Profile Picture Section:**
       - Display current/preview image (CircleAvatar 150x150)
       - "Change Picture" button (TextButton)
       - Tap handler calls profileEditNotifier.pickImage()
       - Show loading indicator during image encoding

       **Display Name Section:**
       - TextFormField for display name
       - Initial value from profile
       - Validator: ProfileValidators.validateDisplayName
       - onChanged: profileEditNotifier.updateDisplayName
       - Character counter (X/50)

       **Privacy Settings Section:**
       - SwitchListTile for email contact permission
       - Title: "Allow email contact"
       - Subtitle: "Let other users contact you via email"
       - Value: state.emailContactAllowed
       - onChanged: profileEditNotifier.toggleEmailContact

       **Error Display:**
       - Show state.errorMessage in red Card/SnackBar if not null

       **Save Button (AppBar actions):**
       - Enabled only if hasChanges() and not isSubmitting
       - Shows loading indicator when isSubmitting
       - onPressed: Call saveChanges(), navigate back on success

       **Unsaved Changes Dialog:**
       - Override back button (WillPopScope/PopScope)
       - If hasChanges(), show confirmation dialog
       - "Discard changes?" with Cancel/Discard buttons

7. Add navigation route
   - Modify `pockitflyer_app/lib/main.dart` (or router configuration file)
   - Add profile edit route to GoRouter:
     ```dart
     GoRoute(
       path: '/profile/edit',
       name: 'profile-edit',
       builder: (context, state) {
         final profile = state.extra as UserProfile; // Pass profile via extra
         return ProfileEditScreen(profile: profile);
       },
     ),
     ```

8. Update profile screen to navigate to edit
   - Modify `pockitflyer_app/lib/screens/profile_screen.dart`
   - Update "Edit Profile" button onPressed:
     ```dart
     ElevatedButton(
       onPressed: () {
         final profile = ref.read(profileNotifierProvider).value;
         if (profile != null) {
           context.push('/profile/edit', extra: profile);
         }
       },
       child: const Text('Edit Profile'),
     )
     ```

9. Create widget tests
   - Create `pockitflyer_app/test/screens/profile_edit_screen_test.dart`
   - Test ProfileEditScreen widget:
     - Renders all form fields correctly
     - Display name field shows current value
     - Character counter updates on input
     - Privacy toggle reflects current setting
     - Profile picture preview shows current image
     - "Change Picture" button triggers image picker
     - Image preview updates after selection
     - Display name validation errors shown
     - Save button disabled when no changes
     - Save button enabled when changes made
     - Loading indicator shows during save
     - Error message displays on save failure
     - Navigation back on successful save
     - Unsaved changes dialog shows when back pressed with changes
   - Mock ProfileEditNotifier and ImagePicker

10. Create unit tests for validation and utilities
    - Create `pockitflyer_app/test/utils/profile_validators_test.dart`
    - Test ProfileValidators.validateDisplayName:
      - Null/empty returns error
      - Less than 2 chars returns error
      - More than 50 chars returns error
      - Invalid characters return error
      - Valid names return null
    - Test ProfileValidators.validateProfileImage:
      - Null returns null (optional)
      - File > 5MB returns error
      - Invalid extension returns error
      - Valid images return null
    - Create `pockitflyer_app/test/utils/image_utils_test.dart`
    - Test ImageUtils.encodeImageToBase64 (mock File.readAsBytes)

11. Create integration tests
    - Create `pockitflyer_app/test/integration/profile_edit_flow_test.dart`
    - Test full edit flow:
      - Open edit screen with profile data
      - Modify display name
      - Toggle privacy setting
      - Simulate image selection
      - Tap save button
      - Verify API call with correct data
      - Verify navigation back on success
      - Verify error handling on failure
    - Mock ProfileService and ImagePicker

### Acceptance Criteria
- [ ] Profile edit screen displays current profile data [Test: display name, profile picture, privacy setting]
- [ ] Display name validation enforces length and character rules [Test: empty, too short, too long, invalid chars]
- [ ] Image picker allows selection from gallery [Test: tap "Change Picture", image picker opens]
- [ ] Image preview updates after selection [Test: selected image shown before save]
- [ ] Image validation enforces size and format rules [Test: >5MB, invalid format, valid image]
- [ ] Privacy toggle works correctly [Test: toggle on/off, state updates]
- [ ] Save button only enabled when changes made [Test: no changes = disabled, changes = enabled]
- [ ] Successful save updates profile and navigates back [Test: API call, profile refreshed, navigation]
- [ ] Validation errors displayed clearly [Test: display name errors, image errors]
- [ ] Backend errors handled with user-friendly messages [Test: 400, 401, 413, network error]
- [ ] Unsaved changes dialog prevents accidental data loss [Test: back button with changes shows dialog]
- [ ] Loading states shown during save [Test: loading indicator, disabled buttons]
- [ ] All widget tests pass with >85% coverage [Test: run `flutter test`]
- [ ] All unit and integration tests pass [Test: validators, utilities, full flow]

### Files to Create/Modify
- `pockitflyer_app/lib/models/profile_update_request.dart` - NEW: Update request model
- `pockitflyer_app/lib/services/profile_service.dart` - MODIFY: Add updateProfile method
- `pockitflyer_app/lib/utils/profile_validators.dart` - NEW: Validation functions
- `pockitflyer_app/lib/utils/image_utils.dart` - NEW: Image picker and encoding
- `pockitflyer_app/lib/providers/profile_edit_provider.dart` - NEW: Edit state provider
- `pockitflyer_app/lib/screens/profile_edit_screen.dart` - NEW: Edit screen widget
- `pockitflyer_app/lib/screens/profile_screen.dart` - MODIFY: Add navigation to edit screen
- `pockitflyer_app/lib/main.dart` - MODIFY: Add profile edit route
- `pockitflyer_app/pubspec.yaml` - MODIFY: Add image_picker dependency
- `pockitflyer_app/test/screens/profile_edit_screen_test.dart` - NEW: Widget tests
- `pockitflyer_app/test/utils/profile_validators_test.dart` - NEW: Validation tests
- `pockitflyer_app/test/utils/image_utils_test.dart` - NEW: Image utility tests
- `pockitflyer_app/test/integration/profile_edit_flow_test.dart` - NEW: Integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - ProfileValidators.validateDisplayName (all validation cases)
  - ProfileValidators.validateProfileImage (size, format validation)
  - ImageUtils.encodeImageToBase64 (encoding logic)
  - ProfileUpdateRequest.toJson serialization

- **Widget tests**:
  - ProfileEditScreen form rendering
  - Field validation and error display
  - Image picker integration
  - Save button state (enabled/disabled)
  - Loading states
  - Error message display
  - Unsaved changes dialog

- **Integration tests**:
  - Full profile edit flow (load → modify → save → navigate back)
  - Error handling flow (validation errors, API errors)
  - Image selection and preview flow
  - Unsaved changes prevention flow

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Flutter/Dart style guide)
- [ ] No console errors or warnings
- [ ] Documentation/comments added where needed (complex logic only)
- [ ] Changes committed with reference to task ID (m04-e01-t02)
- [ ] Ready for dependent tasks to use (m04-e01-t03 backend endpoint integration)

## Dependencies
- Requires: m04-e01-t01 (profile view screen for navigation source)
- Requires: m02-e01 (authentication for API authorization)
- Blocks: None (this task and m04-e01-t03 work together)

## Technical Notes
- **Image encoding**: Use base64 encoding for image upload (simpler than multipart/form-data for initial implementation)
- **Image size limits**: Validate client-side (5MB) AND server-side to prevent abuse
- **Image quality**: Resize/compress before upload (maxWidth: 1024, quality: 85) to reduce payload
- **Validation timing**: Validate on field blur and on save, not on every keystroke (better UX)
- **Privacy setting**: emailContactAllowed determines if creator's email is shown on flyers
- **Change detection**: Only send changed fields to backend (use null for unchanged fields)
- **State persistence**: Don't persist edit state - always start fresh from current profile
- **Error handling**: Distinguish between validation errors (client-side) and server errors
- **iOS permissions**: image_picker requires NSPhotoLibraryUsageDescription in Info.plist
- **Unsaved changes**: Use WillPopScope (or PopScope in Flutter 3.12+) to intercept back navigation

## References
- image_picker package: https://pub.dev/packages/image_picker
- Form validation in Flutter: https://docs.flutter.dev/cookbook/forms/validation
- Base64 encoding: https://api.dart.dev/stable/dart-convert/base64-constant.html
- Riverpod state management: https://riverpod.dev/docs/concepts/providers
- WillPopScope/PopScope: https://api.flutter.dev/flutter/widgets/PopScope-class.html
