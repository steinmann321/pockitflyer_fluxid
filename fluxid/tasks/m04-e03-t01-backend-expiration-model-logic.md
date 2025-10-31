---
id: m04-e03-t01
title: Backend Expiration Model Logic
epic: m04-e03
status: pending
---

# Task: Backend Expiration Model Logic

## Description
Add `is_active` boolean field to Flyer model and implement model-level logic to automatically mark flyers as inactive when expired. Use check-on-read pattern (filter in queries) rather than scheduled tasks for MVP simplicity.

## Scope
- Add `is_active` field to Flyer model with default=True
- Add database migration
- Add model property `is_expired` that checks `expiration_date < timezone.now()`
- Add model method `deactivate_if_expired()` that sets `is_active=False` if expired
- Update feed query filters to exclude inactive flyers
- Update user's own flyers query to include inactive flyers
- Database index on (`is_active`, `expiration_date`) for query performance

## Success Criteria
- [ ] Flyer model has `is_active` boolean field
- [ ] Migration creates field with default=True
- [ ] `is_expired` property correctly identifies expired flyers (timezone-aware)
- [ ] `deactivate_if_expired()` method sets `is_active=False` only when expired
- [ ] Feed queries exclude `is_active=False` flyers
- [ ] User's profile queries include both active and inactive flyers
- [ ] Database index exists for performance
- [ ] All tests pass with `tdd_green` marker

## Test Cases
```python
@pytest.mark.tdd_red
def test_flyer_is_active_default_true():
    """New flyers are active by default"""

@pytest.mark.tdd_red
def test_flyer_is_expired_property_future_date():
    """Flyers with future expiration are not expired"""

@pytest.mark.tdd_red
def test_flyer_is_expired_property_past_date():
    """Flyers with past expiration are expired"""

@pytest.mark.tdd_red
def test_deactivate_if_expired_sets_inactive():
    """deactivate_if_expired() sets is_active=False for expired flyers"""

@pytest.mark.tdd_red
def test_deactivate_if_expired_keeps_active():
    """deactivate_if_expired() keeps is_active=True for non-expired flyers"""

@pytest.mark.tdd_red
def test_feed_query_excludes_inactive_flyers():
    """Public feed queries exclude is_active=False flyers"""

@pytest.mark.tdd_red
def test_user_flyers_query_includes_inactive():
    """User's own flyers query includes inactive flyers"""

@pytest.mark.tdd_red
def test_timezone_handling_utc():
    """Expiration logic uses UTC timezone correctly"""
```

## Dependencies
- Existing Flyer model from M04-E01

## Acceptance
- All tests marked `tdd_green`
- Migration applied successfully
- No regressions in existing flyer tests
