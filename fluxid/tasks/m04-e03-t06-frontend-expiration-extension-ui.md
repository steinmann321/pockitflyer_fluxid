---
id: m04-e03-t06
title: Frontend Expiration Extension UI
epic: m04-e03
status: pending
---

# Task: Frontend Expiration Extension UI

## Description
Add UI controls on flyer edit screen to extend expiration date and optionally reactivate expired flyers. Requires explicit reactivation toggle to prevent accidental republishing.

## Scope
- Add date picker widget to edit screen for expiration date
- Add reactivation toggle switch (only enabled for expired flyers)
- Show current expiration date and status
- Disable reactivation toggle if new expiration is in past
- Show helper text explaining reactivation requirement
- Validate expiration date is in future before allowing reactivation
- Update API client methods to send both fields
- Show loading state during update
- Show success/error feedback

## Success Criteria
- [ ] Edit screen shows expiration date picker
- [ ] Edit screen shows reactivation toggle for expired flyers
- [ ] Toggle disabled for active flyers
- [ ] Toggle disabled if new expiration date is in past
- [ ] Helper text explains manual reactivation requirement
- [ ] Validation prevents activating with past expiration
- [ ] API client sends both `expiration_date` and `is_active`
- [ ] Loading state shown during update
- [ ] Success message on successful update
- [ ] Error message on validation failure
- [ ] All tests pass with `tdd_green` tag

## Test Cases
```dart
// tags: ['tdd_red']
testWidgets('Edit screen shows expiration date picker', (tester) async {
  // Verify date picker widget exists
});

// tags: ['tdd_red']
testWidgets('Reactivation toggle shown for expired flyers', (tester) async {
  // Verify toggle visible when flyer is expired
});

// tags: ['tdd_red']
testWidgets('Reactivation toggle hidden for active flyers', (tester) async {
  // Verify toggle not shown when flyer is active
});

// tags: ['tdd_red']
testWidgets('Toggle disabled when expiration in past', (tester) async {
  // Verify toggle disabled state
});

// tags: ['tdd_red']
testWidgets('Helper text explains reactivation', (tester) async {
  // Verify explanatory text visible
});

// tags: ['tdd_red']
testWidgets('Cannot activate with past expiration', (tester) async {
  // Verify validation error shown
});

// tags: ['tdd_red']
test('API client sends expiration_date and is_active', () {
  // Verify API request body
});

// tags: ['tdd_red']
testWidgets('Shows loading state during update', (tester) async {
  // Verify loading indicator
});

// tags: ['tdd_red']
testWidgets('Shows success message on update', (tester) async {
  // Verify success feedback
});

// tags: ['tdd_red']
testWidgets('Shows error message on validation failure', (tester) async {
  // Verify error feedback
});
```

## Dependencies
- M04-E03-T03 (Backend Reactivation API)
- M04-E02-T05 (Frontend Flyer Edit Screen)
- M04-E01-T09 (Frontend Date Picker Widgets)

## Acceptance
- All tests marked `tdd_green`
- UI flows work correctly
- Clear user guidance provided
