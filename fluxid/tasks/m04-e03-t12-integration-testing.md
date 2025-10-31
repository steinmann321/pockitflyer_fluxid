---
id: m04-e03-t12
title: Integration Testing
epic: m04-e03
status: pending
---

# Task: Integration Testing

## Description
Comprehensive integration tests validating expiration and deletion features across backend and frontend, including edge cases and error scenarios.

## Scope
- Backend integration tests for expiration + favorites interaction
- Backend integration tests for expiration + following interaction
- Backend integration tests for deletion + cascade effects
- Frontend integration tests for expiration UI states
- Frontend integration tests for deletion error handling
- Edge cases: timezone boundaries, concurrent operations
- Error scenarios: network failures, authorization failures
- Regression tests to ensure no breaking changes

## Success Criteria
- [ ] Expired flyers removed from favorites feed
- [ ] Expired flyers removed from following feed
- [ ] Deleting flyer removes it from other users' favorites
- [ ] Deleting followed user's flyer updates feed correctly
- [ ] Timezone edge cases handled correctly (UTC boundaries)
- [ ] Concurrent expiration checks don't cause race conditions
- [ ] Concurrent deletions are idempotent
- [ ] Network failures handled gracefully in UI
- [ ] Authorization failures show clear error messages
- [ ] No regressions in existing features
- [ ] All tests pass with `tdd_green` marker/tag

## Test Cases
```python
# Backend integration tests
@pytest.mark.tdd_red
def test_expired_flyer_removed_from_favorites_feed():
    """Favorited flyer expires, removed from favorites feed"""

@pytest.mark.tdd_red
def test_expired_flyer_removed_from_following_feed():
    """Followed creator's flyer expires, removed from feed"""

@pytest.mark.tdd_red
def test_delete_flyer_removes_from_others_favorites():
    """Deleting flyer removes it from all users' favorites"""

@pytest.mark.tdd_red
def test_delete_flyer_updates_following_feed():
    """Deleting flyer removes it from followers' feeds"""

@pytest.mark.tdd_red
def test_timezone_utc_boundary_expiration():
    """Flyer expiring at UTC midnight handled correctly"""

@pytest.mark.tdd_red
def test_concurrent_expiration_checks():
    """Multiple simultaneous expiration checks don't race"""

@pytest.mark.tdd_red
def test_concurrent_deletions_idempotent():
    """Multiple delete requests handled safely"""
```

```dart
// Frontend integration tests
// tags: ['tdd_red']
testWidgets('Expiration UI updates on status change', (tester) async {
  // Verify UI reflects backend status changes
});

// tags: ['tdd_red']
testWidgets('Deletion network failure shows error', (tester) async {
  // Verify error handling
});

// tags: ['tdd_red']
testWidgets('Deletion authorization failure shows error', (tester) async {
  // Verify 403 error handling
});

// tags: ['tdd_red']
testWidgets('No regressions in feed screen', (tester) async {
  // Verify existing features still work
});
```

## Dependencies
- M04-E03-T01 through T11 (all implementation and optimization tasks)
- M03-E01 (Favorite Flyers)
- M03-E02 (Follow Creators)
- M03-E03 (Feed Filters)

## Acceptance
- All tests marked `tdd_green`
- Integration scenarios validated
- Edge cases handled
- No regressions detected
