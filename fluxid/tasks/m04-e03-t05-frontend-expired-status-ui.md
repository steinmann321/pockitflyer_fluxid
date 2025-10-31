---
id: m04-e03-t05
title: Frontend Expired Status UI
epic: m04-e03
status: pending
---

# Task: Frontend Expired Status UI

## Description
Display expired status indicator on flyer cards in user's profile view. Clearly distinguish active vs expired flyers visually.

## Scope
- Update FlyerCard widget to accept `status` field
- Add visual indicator for expired status (badge, overlay, or dimmed style)
- Only show expired indicator on user's own profile
- Do not show indicator on public feeds (expired flyers already filtered out)
- Update API client to parse `status` field from backend
- Accessibility: status indicator readable by screen readers

## Success Criteria
- [ ] FlyerCard widget accepts `status` parameter
- [ ] Expired flyers show visual indicator (e.g., "Expired" badge)
- [ ] Active flyers show no indicator or "Active" status
- [ ] Indicator only appears on user's own profile
- [ ] Public feed flyers have no status indicator
- [ ] API client parses `status` field correctly
- [ ] Accessibility: status announced by screen readers
- [ ] All tests pass with `tdd_green` tag

## Test Cases
```dart
// tags: ['tdd_red']
testWidgets('FlyerCard shows expired badge for expired flyers', (tester) async {
  // Verify "Expired" badge visible
});

// tags: ['tdd_red']
testWidgets('FlyerCard shows no badge for active flyers', (tester) async {
  // Verify no expired badge
});

// tags: ['tdd_red']
testWidgets('Expired badge has correct styling', (tester) async {
  // Verify visual distinction (color, position)
});

// tags: ['tdd_red']
test('API client parses status field from response', () {
  // Verify JSON parsing
});

// tags: ['tdd_red']
testWidgets('Status indicator is screen reader accessible', (tester) async {
  // Verify Semantics widget
});
```

## Dependencies
- M04-E03-T02 (Backend Expiration Feed Filtering)
- M01-E01-T06 (Frontend Flyer Card Widget)

## Acceptance
- All tests marked `tdd_green`
- Visual design matches mockups/guidelines
- Accessibility requirements met
