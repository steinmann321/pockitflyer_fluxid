---
id: m04-e02-t03
epic: m04-e02
title: Extend Flyer Detail API for Edit Context
status: pending
priority: medium
tdd_phase: red
---

# Task: Extend Flyer Detail API for Edit Context

## Objective
Extend existing flyer detail API endpoint to include edit-specific fields and permissions for flyer owners to pre-populate the edit screen.

## Acceptance Criteria
- [ ] GET endpoint at `/api/v1/flyers/{id}/` enhanced with edit metadata
- [ ] Response includes `is_owner` boolean field (true if authenticated user is creator)
- [ ] Response includes `can_edit` boolean field (true if user can edit this flyer)
- [ ] For owners: includes all images with full URLs (not just thumbnails)
- [ ] For owners: includes complete location_address and geocoordinates
- [ ] For owners: includes all editable fields in full detail
- [ ] For non-owners: excludes sensitive edit-only information
- [ ] Anonymous users: `is_owner` and `can_edit` always false
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Anonymous user: is_owner=false, can_edit=false
- Authenticated non-owner: is_owner=false, can_edit=false
- Authenticated owner: is_owner=true, can_edit=true
- Owner receives all images (not just thumbnails)
- Owner receives complete address and coordinate data
- Non-owner receives appropriate limited data
- 404 for non-existent flyer
- Response format consistent with existing detail API

## Files to Modify/Create
- `pockitflyer_backend/flyers/serializers.py` (extend FlyerDetailSerializer)
- `pockitflyer_backend/flyers/tests/test_views.py`

## Dependencies
- M01-E03-T02 (Existing flyer detail API)
- M02-E01 (JWT authentication)

## Notes
- This builds on existing detail API from M01-E03-T02
- Use SerializerMethodField for is_owner and can_edit
- Consider using different serializers for owner vs non-owner (or dynamic fields)
- Ensure backwards compatibility with existing detail API consumers
- Images should include order field for correct display sequence
