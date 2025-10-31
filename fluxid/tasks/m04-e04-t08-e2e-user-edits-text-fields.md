---
id: m04-e04-t08
title: E2E Test - User Edits Text Fields and Saves
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - User Edits Text Fields and Saves

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates text field editing (title, description, category) with database persistence and feed/profile updates end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating text field editing and persistence through real system stack.

### Steps

1. Create Maestro E2E test file for text editing
   - Create file `pockitflyer_app/maestro/flows/m04-e04/user_edits_text_fields.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (use M04 test fixtures)
   - Launch iOS app → authenticate

2. Implement text field editing test
   - Test: 'User edits title, description, category and saves'
   - Navigate to profile → "My Flyers" → tap first flyer → edit screen opens
   - Note original values (title, description, category)
   - Edit title: Clear field → input "Updated Title [timestamp]"
   - Edit description: Clear field → input "Updated description text"
   - Edit category: Tap dropdown → select different category (e.g., Events → Nightlife)
   - Tap "Save Changes" button → loading indicator appears
   - Assert: Success message appears
   - Assert: App navigates back to profile or flyer detail
   - Verify: Backend logs show PATCH /api/flyers/{id}/ request
   - Verify: Database record updated with new values

3. Add verification in feed test
   - After saving edits, navigate to main feed
   - Scroll to find edited flyer (search by new title)
   - Assert: Flyer card shows updated title "Updated Title [timestamp]"
   - Assert: Flyer card shows updated category tag (e.g., "Nightlife")
   - Tap flyer → detail screen shows updated description

4. Add verification on profile test
   - Navigate back to profile → "My Flyers"
   - Assert: Edited flyer shows updated title
   - Assert: Flyer card shows updated category

5. Add cleanup
   - Cleanup: Restore original flyer values or delete test flyer
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] User edits text fields and saves [Maestro: inputText → tapOn "Save" → assertVisible "Success"]
- [ ] Updated flyer displays in feed with new values [Maestro: navigate feed → verify updated title/category]
- [ ] Database persists changes [Verify: backend database query shows updated values]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/user_edits_text_fields.yaml` - NEW: E2E test

### Testing Requirements
**Note**: This task IS the E2E testing for text field editing. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, update API

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Text field edits save successfully
- [ ] Updated flyer displays in feed and profile with new values
- [ ] Backend API processes PATCH request correctly
- [ ] Database persists changes
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t07 (Navigation to edit screen)
- Requires: m04-e02 (Edit flyer implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Use authenticated user with owned flyer
- **PATCH request**: Backend expects PATCH (not PUT) for partial updates
- **Performance**: Save operation should complete within 2 seconds
- **Validation**: Ensure edited title/description meet validation rules (non-empty, length limits)
- **Timestamp**: Use timestamp in new title to uniquely identify edited flyer in feed
- **Maestro text input**: Use clear field then inputText for editing existing values
- **Cleanup**: Restore original values after test or delete test flyer
