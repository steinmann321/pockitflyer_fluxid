---
id: m04-e03-t03
title: Backend Reactivation API
epic: m04-e03
status: pending
---

# Task: Backend Reactivation API

## Description
Add API endpoint to allow users to extend expiration date and optionally reactivate expired flyers. Requires explicit reactivation toggle to prevent accidental republishing.

## Scope
- Update flyer update API to accept `expiration_date` and `is_active` fields
- Validate user owns the flyer
- Business logic: extending expiration alone does NOT automatically reactivate
- Only allow `is_active=True` if user explicitly sets it AND expiration is in future
- Prevent setting `is_active=True` if expiration is in past
- Return clear error messages for validation failures

## Success Criteria
- [ ] PATCH /api/flyers/{id}/ accepts `expiration_date` field
- [ ] PATCH /api/flyers/{id}/ accepts `is_active` field
- [ ] Authorization check: only flyer owner can update
- [ ] Extending expiration alone keeps `is_active` unchanged
- [ ] Setting `is_active=True` requires future expiration date
- [ ] Cannot activate flyer with past expiration date
- [ ] Clear error messages for validation failures
- [ ] All tests pass with `tdd_green` marker

## Test Cases
```python
@pytest.mark.tdd_red
def test_update_expiration_date_authorized():
    """Owner can update expiration_date"""

@pytest.mark.tdd_red
def test_update_expiration_date_unauthorized():
    """Non-owner cannot update expiration_date"""

@pytest.mark.tdd_red
def test_extend_expiration_keeps_inactive():
    """Extending expiration on inactive flyer keeps is_active=False"""

@pytest.mark.tdd_red
def test_reactivate_with_future_expiration():
    """Setting is_active=True with future expiration succeeds"""

@pytest.mark.tdd_red
def test_reactivate_with_past_expiration_fails():
    """Setting is_active=True with past expiration returns 400 error"""

@pytest.mark.tdd_red
def test_update_both_fields_simultaneously():
    """Can update both expiration_date and is_active in one request"""

@pytest.mark.tdd_red
def test_reactivation_error_message():
    """Error message clearly explains why reactivation failed"""

@pytest.mark.tdd_red
def test_only_owner_can_reactivate():
    """Only flyer owner can set is_active field"""
```

## Dependencies
- M04-E03-T01 (Backend Expiration Model Logic)
- M04-E02-T02 (Backend Flyer Update API)

## Acceptance
- All tests marked `tdd_green`
- API endpoints working correctly
- Clear validation error messages
