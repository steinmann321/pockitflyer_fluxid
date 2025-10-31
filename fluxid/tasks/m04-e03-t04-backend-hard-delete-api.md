---
id: m04-e03-t04
title: Backend Hard Delete API
epic: m04-e03
status: pending
---

# Task: Backend Hard Delete API

## Description
Implement hard delete API endpoint that permanently removes flyer from database and cleans up associated images from storage. Irreversible operation with cascade deletion.

## Scope
- Add DELETE /api/flyers/{id}/ endpoint
- Authorization: only flyer owner can delete
- Hard delete (not soft delete - actually remove from database)
- Cascade delete related data (favorites, tags, relationships)
- Delete associated images from storage
- Handle transaction atomicity (rollback on failure)
- Return 204 No Content on success
- Return 404 if flyer already deleted (idempotent)

## Success Criteria
- [ ] DELETE /api/flyers/{id}/ endpoint exists
- [ ] Only flyer owner authorized to delete
- [ ] Flyer removed from database permanently
- [ ] Associated images deleted from storage
- [ ] Cascade deletes favorites, follows, tags
- [ ] Transaction rollback on storage cleanup failure
- [ ] Returns 204 No Content on success
- [ ] Returns 404 on already-deleted flyer (idempotent)
- [ ] Returns 403 for non-owner
- [ ] All tests pass with `tdd_green` marker

## Test Cases
```python
@pytest.mark.tdd_red
def test_delete_flyer_authorized_owner():
    """Owner can delete their flyer"""

@pytest.mark.tdd_red
def test_delete_flyer_unauthorized_non_owner():
    """Non-owner cannot delete flyer (403)"""

@pytest.mark.tdd_red
def test_delete_flyer_removes_from_database():
    """Flyer is permanently removed from database"""

@pytest.mark.tdd_red
def test_delete_flyer_removes_images():
    """Associated images are deleted from storage"""

@pytest.mark.tdd_red
def test_delete_flyer_cascade_favorites():
    """Favorites are deleted when flyer is deleted"""

@pytest.mark.tdd_red
def test_delete_flyer_cascade_tags():
    """Tags/relationships are deleted when flyer is deleted"""

@pytest.mark.tdd_red
def test_delete_flyer_returns_204():
    """Successful deletion returns 204 No Content"""

@pytest.mark.tdd_red
def test_delete_flyer_idempotent_404():
    """Deleting already-deleted flyer returns 404"""

@pytest.mark.tdd_red
def test_delete_flyer_rollback_on_storage_failure():
    """Database rollback if image deletion fails"""

@pytest.mark.tdd_red
def test_delete_flyer_removes_from_feed():
    """Deleted flyer no longer appears in feeds"""
```

## Dependencies
- M04-E03-T01 (Backend Expiration Model Logic)
- M01-E03-T01 (Backend Image Storage and Serving)
- M03-E01 (Favorite Flyers)

## Acceptance
- All tests marked `tdd_green`
- Delete endpoint working correctly
- No orphaned data or images
- Transaction safety verified
