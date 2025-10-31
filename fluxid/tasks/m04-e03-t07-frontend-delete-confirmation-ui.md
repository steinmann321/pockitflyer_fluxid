---
id: m04-e03-t07
title: Frontend Delete Confirmation UI
epic: m04-e03
status: pending
---

# Task: Frontend Delete Confirmation UI

## Description
Add delete button to flyer edit screen with confirmation dialog that clearly warns users deletion is permanent and irreversible.

## Scope
- Add delete button to edit screen (prominent but secondary action)
- Show confirmation dialog on delete button press
- Dialog title: "Delete Flyer Permanently?"
- Dialog message: Clear warning about irreversibility
- Dialog actions: "Cancel" and "Delete" buttons
- "Delete" button in destructive color (red)
- Disable delete button during API call
- Show loading state during deletion
- Navigate back to profile on successful deletion
- Show error message on deletion failure
- Handle network errors gracefully

## Success Criteria
- [ ] Delete button visible on edit screen
- [ ] Delete button styled as destructive action
- [ ] Tapping delete shows confirmation dialog
- [ ] Dialog has clear warning text
- [ ] Dialog has Cancel and Delete buttons
- [ ] Delete button is red/destructive color
- [ ] Tapping Cancel closes dialog without deleting
- [ ] Tapping Delete calls API and shows loading state
- [ ] Successful deletion navigates to profile
- [ ] Error message shown on API failure
- [ ] Network errors handled gracefully
- [ ] All tests pass with `tdd_green` tag

## Test Cases
```dart
// tags: ['tdd_red']
testWidgets('Edit screen shows delete button', (tester) async {
  // Verify delete button exists
});

// tags: ['tdd_red']
testWidgets('Delete button styled as destructive', (tester) async {
  // Verify red/destructive color
});

// tags: ['tdd_red']
testWidgets('Tapping delete shows confirmation dialog', (tester) async {
  // Verify dialog appears
});

// tags: ['tdd_red']
testWidgets('Confirmation dialog has warning text', (tester) async {
  // Verify warning message
});

// tags: ['tdd_red']
testWidgets('Dialog has Cancel and Delete buttons', (tester) async {
  // Verify both buttons exist
});

// tags: ['tdd_red']
testWidgets('Cancel button closes dialog without deleting', (tester) async {
  // Verify no API call made
});

// tags: ['tdd_red']
testWidgets('Delete button calls API', (tester) async {
  // Verify API client method called
});

// tags: ['tdd_red']
testWidgets('Shows loading state during deletion', (tester) async {
  // Verify loading indicator
});

// tags: ['tdd_red']
testWidgets('Navigates to profile on success', (tester) async {
  // Verify navigation
});

// tags: ['tdd_red']
testWidgets('Shows error message on failure', (tester) async {
  // Verify error feedback
});

// tags: ['tdd_red']
testWidgets('Handles network errors gracefully', (tester) async {
  // Verify error handling
});
```

## Dependencies
- M04-E03-T04 (Backend Hard Delete API)
- M04-E02-T05 (Frontend Flyer Edit Screen)

## Acceptance
- All tests marked `tdd_green`
- Delete flow works correctly
- User warnings clear and prominent
