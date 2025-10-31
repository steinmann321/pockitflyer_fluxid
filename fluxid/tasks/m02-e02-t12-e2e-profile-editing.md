---
id: m02-e02-t12
epic: m02-e02
title: E2E Tests for Profile Editing Workflows
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Tests for Profile Editing Workflows

## Objective
Implement Maestro E2E tests for profile editing workflows covering name updates, profile picture uploads, validation, and error handling.

## Acceptance Criteria
- [ ] Test: User navigates to profile edit screen from own profile
- [ ] Test: User updates profile name successfully
- [ ] Test: Name validation: max 50 characters enforced
- [ ] Test: Name validation: empty name rejected
- [ ] Test: User uploads profile picture from photo library
- [ ] Test: User uploads profile picture from camera
- [ ] Test: Large image upload works (< 5MB limit)
- [ ] Test: Image upload > 5MB rejected with error message
- [ ] Test: Profile changes reflected immediately across app
- [ ] Test: Cancel button discards changes
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Edit button visible only on own profile
- Edit button hidden on others' profiles
- Name update flow: edit → save → verify change
- Name validation errors displayed inline
- Picture upload from library: select → upload → verify change
- Picture upload from camera: capture → upload → verify change
- Large file rejection with error message
- Changes reflected in feed (flyer cards show new picture)
- Changes reflected in header avatar
- Cancel button navigation without saving
- Pull-to-refresh after edit shows updated data

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/profile/edit_profile_name.yaml`
- `pockitflyer_app/maestro/flows/profile/edit_profile_picture_library.yaml`
- `pockitflyer_app/maestro/flows/profile/edit_profile_picture_camera.yaml`
- `pockitflyer_app/maestro/flows/profile/profile_validation.yaml`
- `pockitflyer_app/maestro/flows/profile/profile_edit_cancel.yaml`
- `pockitflyer_app/maestro/flows/profile/profile_changes_reflected.yaml`

## Dependencies
- m02-e02-t06 (Profile edit screen)
- m02-e02-t07 (Image picker integration)
- m02-e02-t11 (Profile viewing E2E tests)
- m01-e05-t01 (E2E test infrastructure)

## Notes
- Camera tests require iOS simulator camera permission setup
- Use test images with known sizes for validation tests
- Verify changes propagate to all UI locations (feed, header, profile)
- Tests should clean up uploaded images after completion
- Consider permission denial scenarios for camera/photos
