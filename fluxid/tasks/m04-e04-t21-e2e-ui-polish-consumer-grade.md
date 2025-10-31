---
id: m04-e04-t21
title: E2E Test - UI Polish and Consumer Grade Quality
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - UI Polish and Consumer Grade Quality

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates consumer-grade UI quality: loading states, success confirmations, error messages, intuitive workflows, visual polish, accessibility end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating UI polish and consumer-grade quality through real system stack.

### Steps

1. Create Maestro E2E test file for UI polish validation
   - Create file `pockitflyer_app/maestro/flows/m04-e04/ui_polish_consumer_grade.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user
   - Launch iOS app → authenticate

2. Implement loading states test
   - Test: 'All async operations show loading indicators'
   - Navigate to creation screen → upload image
   - Assert: Loading spinner or progress indicator visible during upload
   - Tap "Publish" (with geocoding)
   - Assert: Loading indicator visible with appropriate message "Creating flyer..."
   - Navigate to feed → pull-to-refresh
   - Assert: Loading indicator visible during refresh
   - Navigate to profile → edit flyer → save changes
   - Assert: Loading indicator visible during save

3. Implement success confirmations test
   - Test: 'Success actions show clear confirmation messages'
   - Create new flyer → wait for completion
   - Assert: Success message appears "Flyer published successfully!"
   - Assert: Success message auto-dismisses after 2-3 seconds OR has dismiss button
   - Edit flyer → save changes
   - Assert: Success message appears "Changes saved"
   - Delete flyer → confirm deletion
   - Assert: Success message appears "Flyer deleted"

4. Implement intuitive workflow test
   - Test: 'Workflows are intuitive and follow user expectations'
   - Create flyer workflow:
     - Assert: Form fields appear in logical order (image → title → description → location → dates → category)
     - Assert: Required fields clearly marked with asterisk or label
     - Assert: Date pickers use native iOS date picker (familiar UX)
     - Assert: Category dropdown shows clear options
   - Edit workflow:
     - Assert: Edit screen pre-populated (no empty fields)
     - Assert: Cancel button available (escape hatch)
     - Assert: Save button clearly labeled "Save Changes" (not "Submit" or generic)
   - Delete workflow:
     - Assert: Confirmation dialog explicit "This action cannot be undone"
     - Assert: Destructive action button red (iOS convention)

5. Implement visual polish test
   - Test: 'Visual design is polished and consistent'
   - Navigate through all M04 screens (creation, edit, profile)
   - Assert: Consistent button styling across screens
   - Assert: Consistent spacing and padding
   - Assert: Consistent typography (font sizes, weights)
   - Assert: Consistent color scheme (primary, accent, error colors)
   - Assert: Images display with rounded corners or consistent styling
   - Assert: No visual glitches (text overflow, cutoff images, misaligned elements)

6. Implement error message quality test
   - Test: 'Error messages are user-friendly and actionable'
   - Trigger validation error (empty required field)
   - Assert: Error message uses plain language (not technical jargon)
   - Assert: Error message suggests solution "Please enter a title"
   - Trigger network error (stop backend)
   - Assert: Error message friendly "Unable to connect. Please check your connection."
   - Assert: Retry button or action available

7. Implement accessibility test
   - Test: 'Key accessibility features present'
   - Navigate through M04 screens
   - Assert: All interactive elements have accessibility labels (for VoiceOver)
   - Assert: Sufficient touch target sizes (44x44pt minimum iOS guideline)
   - Assert: Sufficient color contrast (text readable)
   - Assert: Form inputs have labels (not just placeholders)

8. Implement empty states test
   - Test: 'Empty states are informative and actionable'
   - New user with 0 flyers → navigate to profile
   - Assert: "My Flyers" section shows empty state
   - Assert: Empty state message "You haven't created any flyers yet"
   - Assert: Call-to-action button "Create Your First Flyer"

9. Add cleanup
   - Cleanup: Delete created test flyers
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] All async operations show loading indicators [Maestro: verify spinners during uploads, saves, refreshes]
- [ ] Success actions show clear confirmation messages [Maestro: verify success messages appear and dismiss]
- [ ] Visual design is polished and consistent [Maestro: visual inspection across all screens]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/ui_polish_consumer_grade.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for UI polish. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation with focus on user experience and visual quality

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] All loading states present and appropriate
- [ ] Success confirmations clear and user-friendly
- [ ] Workflows intuitive and follow conventions
- [ ] Visual design polished and consistent
- [ ] Error messages user-friendly and actionable
- [ ] Basic accessibility features present
- [ ] Empty states informative
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e01, m04-e02, m04-e03 (All M04 feature implementations)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Visual testing**: Maestro supports screenshot capture for visual regression
- **Loading indicators**: Should appear for operations >500ms
- **Success messages**: Auto-dismiss after 2-3 seconds OR dismissible by user
- **iOS conventions**: Follow Apple Human Interface Guidelines
- **Accessibility**: VoiceOver labels, touch targets, contrast ratios
- **Consumer-grade**: "Would you use this?" standard - polish matters
- **Empty states**: Every list/collection should have empty state design
- **Consistency**: Use design system or style guide (even informal)
