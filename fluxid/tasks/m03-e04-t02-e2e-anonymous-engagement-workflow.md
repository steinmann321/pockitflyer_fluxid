---
id: m03-e04-t02
epic: m03-e04
title: E2E Test - Anonymous User Engagement Workflow
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Anonymous User Engagement Workflow

## Objective
Validate that anonymous users see disabled/grayed-out favorite and follow buttons with clear authentication prompts when attempting to use engagement features.

## Acceptance Criteria
- [ ] Maestro flow: `m03_e04_anonymous_engagement.yaml`
- [ ] Test steps:
  1. Launch app (fresh install, no authentication)
  2. Navigate to feed
  3. Verify flyer cards display with engagement buttons
  4. Verify favorite button appears grayed-out/disabled
  5. Tap favorite button
  6. Assert authentication prompt appears (modal/dialog)
  7. Assert prompt message: "Sign in to favorite flyers"
  8. Assert prompt has "Sign In" and "Cancel" buttons
  9. Tap "Cancel"
  10. Assert prompt dismisses
  11. Navigate to creator profile
  12. Verify follow button appears grayed-out/disabled
  13. Tap follow button
  14. Assert authentication prompt appears
  15. Assert prompt message: "Sign in to follow creators"
  16. Tap "Sign In"
  17. Assert navigation to login screen
  18. Cancel login and return to feed
  19. Verify filter buttons (Favorites/Following) are hidden or disabled
- [ ] UI validation:
  - Disabled button visual state clear (grayed out, reduced opacity)
  - Authentication prompt well-designed (not jarring)
  - Prompt messaging helpful and clear
  - "Sign In" button in prompt works correctly
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Anonymous user can browse feed (no regression from M01)
- Favorite button disabled for anonymous users
- Follow button disabled for anonymous users
- Tapping disabled favorite button shows auth prompt
- Tapping disabled follow button shows auth prompt
- Auth prompt "Cancel" dismisses modal
- Auth prompt "Sign In" navigates to login screen
- Filter buttons (Favorites/Following) hidden/disabled for anonymous users
- No crashes when tapping disabled engagement features
- Error messages helpful and non-technical

## Files to Modify/Create
- `maestro/flows/m03-e04/anonymous_engagement_workflow.yaml`
- `maestro/flows/m03-e04/anonymous_favorite_prompt.yaml`
- `maestro/flows/m03-e04/anonymous_follow_prompt.yaml`

## Dependencies
- m03-e04-t01 (M03 E2E test data infrastructure)
- m03-e01-t09 (Anonymous favorite prompt implementation)
- m03-e02-t09 (Anonymous follow prompt implementation)
- m02-e01 (Login screen implementation)

## Notes
**Anonymous User Experience**:
- Browsing feed: Fully functional (M01 feature)
- Viewing flyer details: Fully functional
- Viewing creator profiles: Fully functional
- Favorite/follow buttons: Visible but disabled
- Filter buttons: Hidden or grayed-out

**Authentication Prompt Design**:
- Non-blocking: User can cancel and continue browsing
- Clear messaging: Explain why authentication is required
- Easy sign-in: Direct link to login screen
- Consistent: Same prompt pattern for favorite and follow

**Visual Disabled State**:
- Button opacity reduced (0.5 or similar)
- Icon grayed out (not full color)
- No animation on tap (unlike enabled buttons)
- Tooltip/hint on long-press: "Sign in to use this feature" (optional)

**Edge Cases**:
- Rapid tapping disabled buttons (should debounce, show prompt once)
- Tapping disabled button, dismissing prompt, tapping again (should show prompt again)
- Navigating away from prompt (should dismiss gracefully)

**Performance**:
- Prompt appears immediately on tap (<100ms)
- No lag or janky UI when showing prompt
- Dismiss animation smooth

**Accessibility**:
- Screen reader announces button as "disabled"
- Screen reader announces prompt content
- Focus management when prompt appears
