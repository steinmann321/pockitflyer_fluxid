---
id: m02-e02-t11
epic: m02-e02
title: E2E Tests for Profile Viewing Workflows
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Tests for Profile Viewing Workflows

## Objective
Implement Maestro E2E tests for profile viewing workflows covering authenticated and anonymous access, navigation patterns, and profile display.

## Acceptance Criteria
- [ ] Test: Authenticated user taps header avatar to view own profile
- [ ] Test: Authenticated user views another user's profile from flyer
- [ ] Test: Anonymous user views profile from flyer (public access)
- [ ] Test: Profile displays correct user information (name, picture)
- [ ] Test: Profile displays published flyers list
- [ ] Test: Default avatar shown when user has no profile picture
- [ ] Test: Empty state shown when user has no published flyers
- [ ] Test: Navigation from profile to flyer detail works
- [ ] Test: Back navigation from profile works correctly
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Header avatar navigation to own profile (post-login)
- Profile view from flyer card creator avatar tap
- Profile view from flyer detail creator name tap
- Anonymous user can view public profiles
- Profile displays all required fields correctly
- Published flyers list populated correctly
- Default avatar display when no picture
- Empty state when no published flyers
- Navigation to/from profile screen
- Pull-to-refresh updates profile data

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/profile/view_own_profile.yaml`
- `pockitflyer_app/maestro/flows/profile/view_other_profile_authenticated.yaml`
- `pockitflyer_app/maestro/flows/profile/view_profile_anonymous.yaml`
- `pockitflyer_app/maestro/flows/profile/profile_flyers_list.yaml`
- `pockitflyer_app/maestro/flows/profile/profile_navigation.yaml`

## Dependencies
- m02-e02-t05 (Profile screen)
- m02-e02-t08 (Header avatar navigation)
- m02-e02-t09 (Flyer card profile pictures)
- m01-e05-t01 (E2E test infrastructure from M01)

## Notes
- Reuse test data infrastructure from M01-E05
- Test both authenticated and anonymous access paths
- Verify public profile visibility is working correctly
- Tests should be independent and idempotent
- Use Maestro assertions for UI element verification
