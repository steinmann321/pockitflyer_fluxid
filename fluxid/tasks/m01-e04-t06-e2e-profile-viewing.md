---
id: m01-e04-t06
epic: m01-e04
title: E2E Test for Profile Viewing Flow
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test for Profile Viewing Flow

## Objective
Create end-to-end Maestro test validating the complete creator profile viewing flow from feed to profile and back.

## Acceptance Criteria
- [ ] E2E test covers: main feed → tap creator → view profile → view creator flyers → back to feed
- [ ] Test validates navigation from creator name tap
- [ ] Test validates navigation from creator avatar tap
- [ ] Test validates profile information displays correctly
- [ ] Test validates creator flyers feed loads and displays
- [ ] Test validates back navigation returns to feed
- [ ] Test validates feed scroll position preserved after return
- [ ] Test validates profile with multiple flyers (pagination)
- [ ] Test validates profile with no flyers (empty state)
- [ ] Test runs successfully in CI/CD pipeline
- [ ] All tests marked with appropriate TDD marker after passing

## Test Coverage Requirements
- Complete navigation flow (feed → profile → back)
- Profile header rendering (name, avatar, bio)
- Creator flyers feed rendering
- Tap targets for both creator name and avatar
- Scroll position preservation
- Edge cases: no flyers, multiple flyers, missing profile picture
- Performance: profile load time < 2s

## Files to Modify/Create
- `pockitflyer_app/.maestro/m01-e04-profile-viewing.yaml`
- `pockitflyer_backend/users/tests/test_e2e_profiles.py` (if backend E2E needed)

## Dependencies
- m01-e04-t05 (Profile navigation)
- m01-e04-t04 (Creator flyers feed)
- All previous M01-E04 tasks completed

## Notes
- Test should use realistic test data with multiple creators
- Create test users with varying profile states (with/without picture, with/without bio)
- Create test flyers for different creators (0, 1, many flyers)
- Validate performance metrics during E2E test
- Consider screenshot comparisons for visual regression testing
- Test should run against local development environment before CI/CD
