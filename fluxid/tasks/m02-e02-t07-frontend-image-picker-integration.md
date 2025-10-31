---
id: m02-e02-t07
epic: m02-e02
title: Integrate iOS Image Picker for Profile Picture Upload
status: pending
priority: high
tdd_phase: red
---

# Task: Integrate iOS Image Picker for Profile Picture Upload

## Objective
Implement iOS image picker integration for selecting profile pictures from camera or photo library, with image upload to backend.

## Acceptance Criteria
- [ ] ImagePickerService using UIImagePickerController (iOS native)
- [ ] Option to select from photo library
- [ ] Option to capture from camera
- [ ] Action sheet UI to choose camera vs. library
- [ ] Selected image uploaded to backend via multipart/form-data
- [ ] Loading indicator during upload
- [ ] Success feedback after upload
- [ ] Error handling for upload failures
- [ ] Error handling for permission denials (camera/photos)
- [ ] Image compression before upload (reduce file size)
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Image picker opens when "Change Picture" tapped
- Action sheet shows camera and library options
- Camera permission denial handled gracefully
- Photo library permission denial handled gracefully
- Selected image compressed before upload
- Upload shows loading indicator
- Successful upload updates UI with new picture
- Failed upload shows error message
- Large images compressed to < 5MB
- Upload cancellation works correctly

## Files to Modify/Create
- `pockitflyer_app/lib/services/image_picker_service.dart`
- `pockitflyer_app/lib/services/profile_picture_upload_service.dart`
- `pockitflyer_app/lib/screens/profile_edit_screen.dart` (integrate picker)
- `pockitflyer_app/test/services/image_picker_service_test.dart`
- `pockitflyer_app/test/services/profile_picture_upload_service_test.dart`
- `pockitflyer_app/ios/Runner/Info.plist` (add permissions)

## Dependencies
- m02-e02-t06 (Profile edit screen)
- m02-e02-t04 (Backend profile picture upload API)
- External: image_picker Flutter package

## Notes
- Use image_picker package (official Flutter plugin)
- iOS permissions required: NSCameraUsageDescription, NSPhotoLibraryUsageDescription
- Compress images to reduce upload time and bandwidth
- Consider image cropping UI for better UX (optional for MVP)
- Action sheet is iOS-native pattern (use CupertinoActionSheet)
- Handle iOS 14+ photo library limited access permission
