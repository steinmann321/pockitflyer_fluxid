---
id: m02-e02-t06
epic: m02-e02
title: Create Profile Edit Screen UI
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Edit Screen UI

## Objective
Implement Flutter profile edit screen that allows users to edit their name and profile picture. Screen is accessible only to the profile owner (authenticated user viewing their own profile).

## Acceptance Criteria
- [ ] ProfileEditScreen widget for editing own profile
- [ ] Text field for editing name with validation (max 50 characters)
- [ ] Current profile picture displayed
- [ ] "Change Picture" button to trigger image picker
- [ ] "Save" button to submit changes
- [ ] "Cancel" button to discard changes
- [ ] Name validation: required, max 50 characters, no empty string
- [ ] Loading state during save operation
- [ ] Success feedback after save (snackbar/toast)
- [ ] Error feedback for failed save
- [ ] Navigation back to profile screen after successful save
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Edit screen renders with current profile data
- Name field validates max 50 characters
- Name field rejects empty string
- "Save" button disabled when name invalid
- "Cancel" button navigates back without saving
- Save operation shows loading indicator
- Successful save shows success message
- Failed save shows error message
- Navigation back to profile after save
- Unsaved changes warning when navigating away (optional)

## Files to Modify/Create
- `pockitflyer_app/lib/screens/profile_edit_screen.dart`
- `pockitflyer_app/lib/widgets/profile_edit_form.dart`
- `pockitflyer_app/test/screens/profile_edit_screen_test.dart`
- `pockitflyer_app/test/widgets/profile_edit_form_test.dart`

## Dependencies
- m02-e02-t05 (Profile screen)
- m02-e02-t02 (Backend profile update API)
- m02-e01-t06 (Authentication state management)

## Notes
- Screen accessible via "Edit Profile" button on own profile
- Picture upload handled separately in t07 (image picker integration)
- Form validation should be inline (real-time feedback)
- Consider unsaved changes warning dialog (optional for MVP)
- Use existing design patterns from M02-E01 registration/login screens
