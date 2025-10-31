---
id: m02-e04-t04
epic: m02-e04
title: E2E Test - Profile Viewing and Editing Workflow (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Profile Viewing and Editing Workflow (No Mocks)

## Objective
Validate complete profile viewing and editing workflows end-to-end using real Django backend, real image storage, and real iOS app with no mocks. Tests cover authenticated profile viewing, editing (name, bio, picture), and cross-app visibility updates.

## Acceptance Criteria
- [ ] Maestro flow: `m02_e04_profile_viewing_complete.yaml`
- [ ] Profile viewing test steps:
  1. Start real Django backend
  2. Seed M02 E2E test data (includes users with profiles and profile pictures)
  3. Launch iOS app (fresh install)
  4. Login as test_user_001 (has profile picture and bio)
  5. Tap profile avatar in header
  6. Assert profile screen loads
  7. Assert display name matches: test_user_001's display name
  8. Assert email matches: `test_user_001@pockitflyer.test`
  9. Assert profile picture displays (not placeholder)
  10. Assert bio text displays
  11. Navigate back to feed
  12. Tap on a flyer card created by test_user_001
  13. Verify flyer detail shows same profile picture
  14. Tap creator name to view creator profile (anonymous viewing)
  15. Assert creator profile matches test_user_001 profile
- [ ] Maestro flow: `m02_e04_profile_editing_complete.yaml`
- [ ] Profile editing test steps:
  1. Continue from authenticated state as test_user_001
  2. Navigate to profile screen
  3. Tap "Edit Profile" button
  4. Assert edit profile screen appears
  5. Change display name from "Test User One" to "Updated User One"
  6. Change bio from existing text to "New bio text for testing E2E updates"
  7. Tap "Choose Photo" button
  8. Select photo from test image library (or camera roll)
  9. Assert photo preview appears in edit screen
  10. Tap "Save" button
  11. Assert loading indicator appears
  12. Assert save succeeds (no error messages)
  13. Assert profile screen shows updated name, bio, picture
  14. Navigate to feed
  15. Find flyer created by test_user_001
  16. Assert flyer card shows updated profile picture
  17. Assert flyer card shows updated display name
  18. Tap flyer to view details
  19. Assert flyer detail shows updated profile picture and name
  20. Tap creator name
  21. Assert creator profile shows all updates (name, bio, picture)
  22. Verify backend database:
      - Profile updated with new display name
      - Profile updated with new bio
      - Profile picture file stored in backend storage
      - Profile picture URL updated in database
  23. Cleanup: revert profile changes, stop backend
- [ ] Real service validations:
  - Backend profile retrieval API returns accurate data
  - Backend profile update API persists changes
  - Image upload to backend storage (media files)
  - Image URL generation and storage in database
  - Profile picture displayed from backend URL
  - Profile updates visible across entire app (feed, flyer cards, flyer details, creator profile)
- [ ] Anonymous profile viewing test (separate Maestro flow):
  - Launch app without login (anonymous)
  - View flyer created by test_user_001
  - Tap creator name to view profile
  - Assert profile visible (public access)
  - Assert "Edit Profile" button NOT visible (not owner)
  - Assert display name, bio, picture visible
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete vertical slice: iOS profile screen → REST API → Django profile retrieval → SQLite → profile data display
- Complete vertical slice: iOS edit profile screen → REST API → Django profile update → SQLite → image storage → profile data update
- Profile retrieval for authenticated user (own profile)
- Profile retrieval for other users (creator profile viewing)
- Profile editing (display name, bio)
- Profile picture upload (image selection, upload, storage)
- Profile picture display from backend URL
- Cross-app visibility updates (profile → feed → flyer card → flyer detail → creator profile)
- Anonymous profile viewing (public access control)
- Edit button visibility (owner only)
- Image upload error handling (file too large, unsupported format)
- Network error handling during profile update

## Files to Modify/Create
- `maestro/flows/m02-e04/profile_viewing_complete_workflow.yaml`
- `maestro/flows/m02-e04/profile_editing_complete_workflow.yaml`
- `maestro/flows/m02-e04/profile_viewing_anonymous.yaml`
- `maestro/flows/m02-e04/profile_editing_image_upload_error.yaml`
- `maestro/flows/m02-e04/profile_cross_app_visibility.yaml`
- `pockitflyer_backend/scripts/verify_profile_updated.py` (helper script for database verification)
- `pockitflyer_backend/scripts/revert_profile_changes.py` (cleanup helper)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure with test users and profiles)
- m02-e04-t03 (Login workflow for authentication)
- m02-e02-t01 (Backend profile retrieval API)
- m02-e02-t02 (Backend profile update API)
- m02-e02-t03 (Backend image storage service)
- m02-e02-t04 (Backend profile picture API)
- m02-e02-t05 (Frontend profile screen)
- m02-e02-t06 (Frontend profile edit screen)
- m02-e02-t07 (Frontend image picker integration)

## Notes
**Critical: NO MOCKS**
- Real Django server running on localhost
- Real SQLite database with test data
- Real image storage (Django FileField, media directory)
- Real iOS app making actual HTTP requests
- Real iOS image picker for photo selection

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**Test User Profile Data** (from seed_m02_e2e_data):
- test_user_001: Has profile picture, has bio, has 5+ flyers
- test_user_010: No profile picture (placeholder), no bio, has 1 flyer
- test_user_020: Has profile picture, no bio, has 0 flyers

**Profile Viewing Scenarios**:
1. **Own profile (authenticated)**: Full access, edit button visible
2. **Other user profile (anonymous)**: Public view, no edit button
3. **Other user profile (authenticated)**: Public view, no edit button
4. **From flyer card**: Tap creator name → navigate to creator profile
5. **From header avatar**: Tap avatar → navigate to own profile

**Profile Editing Validations**:
- Display name: Required, 1-50 characters, Unicode support
- Bio: Optional, 0-500 characters, Unicode support
- Profile picture: Optional, JPEG/PNG/HEIC, max 5MB
- All fields updated atomically (transaction)

**Image Upload Flow**:
1. User taps "Choose Photo" button
2. iOS image picker appears (photo library or camera)
3. User selects photo
4. Photo preview appears in edit screen
5. User taps "Save"
6. Photo uploaded to backend (multipart/form-data)
7. Backend stores image in media directory
8. Backend generates URL: `/media/profile_pictures/user_1_abc123.jpg`
9. Backend updates profile.profile_picture field with URL
10. iOS app displays image from backend URL

**Cross-App Visibility Validation**:
After profile update, verify updates appear in:
1. Profile screen (immediate update)
2. Header avatar (updated profile picture)
3. Feed flyer cards (creator name and picture updated)
4. Flyer detail screen (creator name and picture updated)
5. Creator profile screen (all fields updated)

**Backend Database Verification** (after profile update):
```python
# pockitflyer_backend/scripts/verify_profile_updated.py
profile = Profile.objects.get(user__email='test_user_001@pockitflyer.test')
assert profile.display_name == 'Updated User One'
assert profile.bio == 'New bio text for testing E2E updates'
assert profile.profile_picture  # File exists
assert profile.profile_picture.url  # URL generated
```

**Anonymous Profile Viewing Access Control**:
- All profiles public by default (M02 scope)
- Anonymous users can view profiles
- Anonymous users cannot edit profiles (no edit button visible)
- Profile picture visible to all users (public)
- Bio visible to all users (public)

**Image Storage Backend Configuration**:
- Django media root: `pockitflyer_backend/media/`
- Profile pictures subdirectory: `media/profile_pictures/`
- File naming: `user_{user_id}_{random_hash}.{extension}`
- URL format: `/media/profile_pictures/user_1_abc123.jpg`
- Served by Django during development (static file serving)

**Error Handling Tests** (separate Maestro flows):
1. Image too large (>5MB) → error message: "Image too large. Maximum 5MB."
2. Unsupported format (GIF, BMP) → error message: "Unsupported format. Use JPEG or PNG."
3. Network failure during upload → error message with retry button
4. Display name too long (>50 characters) → validation error: "Display name too long."
5. Bio too long (>500 characters) → validation error: "Bio too long."

**Performance Expectations**:
- Profile retrieval: <2 seconds
- Profile update (no image): <2 seconds
- Profile update (with image): <5 seconds
- Image upload (1-2MB): <3 seconds
- Cross-app visibility update: Immediate (no cache invalidation delay)

**UI State Validations**:
- Edit profile screen: All fields pre-populated with current values
- Photo preview: Shows selected image before upload
- Loading state: Disabled "Save" button during upload
- Success state: Navigate back to profile screen after save
- Error state: Error message shown, fields remain editable

**Cleanup Strategy**:
- Revert profile changes after test (restore original display name, bio)
- Delete uploaded test images from media directory
- Use helper script: `python manage.py revert_profile_changes test_user_001@pockitflyer.test`

**Edge Cases to Test** (separate Maestro flows):
1. Edit profile without making changes → save succeeds (no-op)
2. Upload same image twice → second upload replaces first (no duplicate files)
3. Edit display name to empty string → validation error
4. Edit bio to very long text (>500 chars) → validation error
5. Upload image during network outage → timeout, retry button
6. Navigate away from edit screen without saving → changes discarded (no auto-save)

**Success Indicators**:
- Profile viewing works for own profile (authenticated) ✅
- Profile viewing works for other users (anonymous and authenticated) ✅
- Profile editing updates display name, bio, picture ✅
- Image upload and storage works correctly ✅
- Profile updates visible across entire app ✅
- Edit button visible only for own profile ✅
- All error cases handled gracefully ✅
- Performance meets expectations ✅
