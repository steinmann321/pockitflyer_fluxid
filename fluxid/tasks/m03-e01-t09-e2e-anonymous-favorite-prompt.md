---
id: m03-e01-t09
epic: m03-e01
title: E2E Test - Anonymous User Favorite Prompt
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Anonymous User Favorite Prompt

## Objective
Create end-to-end Maestro test validating that anonymous users see disabled favorite button and authentication prompt when attempting to favorite a flyer.

## Acceptance Criteria
- [ ] Test launches app as anonymous user (no login)
- [ ] Test navigates to feed view
- [ ] Test verifies flyer cards visible
- [ ] Test verifies favorite button appears disabled/grayed out
- [ ] Test taps favorite button
- [ ] Test verifies authentication prompt modal appears
- [ ] Test verifies modal has login and register options
- [ ] Test dismisses modal (cancel or tap outside)
- [ ] Test verifies no backend API call was made (flyer not favorited)
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Anonymous user sees disabled favorite button on flyer cards
- Tapping disabled button shows authentication prompt
- Authentication prompt has login and register options
- Tapping login navigates to login screen
- Tapping register navigates to registration screen
- Dismissing modal returns to feed view
- No backend API call made when anonymous user taps button
- Test passes on real iOS device or simulator

## Files to Modify/Create
- `pockitflyer_app/maestro/m03-e01-anonymous-favorite-prompt.yaml` (create Maestro test flow)

## Dependencies
- m03-e01-t06 (favorite button integration with auth check)
- m02-e01-t07 (login screen exists)

## Notes
- Test should NOT log in - test anonymous user flow
- Use Maestro assertions to verify disabled button state
- Verify modal appears using testID or text matching
- Test both login and register navigation paths
- Consider testing modal dismiss (back button, tap outside, cancel button)
