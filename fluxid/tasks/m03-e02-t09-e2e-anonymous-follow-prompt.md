---
id: m03-e02-t09
epic: m03-e02
title: E2E Test - Anonymous Follow Authentication Prompt
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Anonymous Follow Authentication Prompt

## Objective
Create end-to-end Maestro test validating that anonymous users see disabled follow button and authentication prompt when attempting to follow. Test verifies no backend API call is made and registration/login flow is triggered.

## Acceptance Criteria
- [ ] Test launches app without authentication (anonymous mode)
- [ ] Test navigates to feed and verifies follow button is disabled/grayed
- [ ] Test taps disabled follow button
- [ ] Verify authentication prompt sheet appears (login or register)
- [ ] Verify no backend follow API call was made (button tap does not create follow)
- [ ] Test selects "Register" and completes registration
- [ ] Verify follow button becomes enabled after authentication
- [ ] Test taps follow button successfully after authentication
- [ ] All tests pass and marked complete

## Test Coverage Requirements
- Anonymous user sees disabled follow button on flyer cards
- Anonymous user sees disabled follow button on creator profiles
- Tapping disabled button shows authentication prompt
- No API call made when tapping disabled button
- Authentication prompt allows registration or login
- Follow button becomes enabled after successful authentication
- User can follow after authenticating

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/anonymous_follow_prompt.yaml` (create Maestro flow)
- `pockitflyer_app/maestro/README.md` (document test)

## Dependencies
- m03-e02-t06 (Follow button integration complete)
- m02-e01 (Authentication system with login/register prompts)
- Maestro E2E framework configured

## Notes
- Test should start from clean slate (no authentication state)
- Verify button visual state matches disabled state
- Authentication prompt should match existing design
- After authentication, flow continues to complete follow action
- Test should not leave follow relationship in database (cleanup)
