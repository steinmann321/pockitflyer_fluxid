---
id: m04-e04-t15
title: E2E Test - Deleted Flyer Permanently Removed from Storage
epic: m04-e04
milestone: m04
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Deleted Flyer Permanently Removed from Storage

## Context
Part of E2E Milestone Validation (m04-e04) in Milestone 04 (m04).

Validates hard delete behavior: deleted flyer record removed from database, associated images deleted from storage, no recovery possible end-to-end with NO MOCKS.

## Implementation Guide for LLM Agent

### Objective
Create E2E test validating permanent deletion from database and storage through real system stack.

### Steps

1. Create Maestro E2E test file for permanent deletion
   - Create file `pockitflyer_app/maestro/flows/m04-e04/deleted_flyer_permanent_storage.yaml`
   - Start real Django backend (use `./scripts/start_e2e_backend.sh`)
   - Seed authenticated user with owned flyer (3 images)
   - Launch iOS app → authenticate

2. Implement database hard delete test
   - Test: 'Deleted flyer record removed from database'
   - Navigate to profile → "My Flyers"
   - Select flyer to delete, note flyer ID (from test data)
   - Note image file paths from database (e.g., media/flyers/image1.jpg, image2.jpg, image3.jpg)
   - Tap flyer → tap "Delete" → confirm deletion
   - Wait for success message
   - Verify: Database query for flyer ID returns no record (404 or empty)
   - Verify: Flyer record permanently deleted (not soft deleted with flag)

3. Implement image storage cleanup test
   - Test: 'Associated images deleted from backend storage'
   - After deletion (from step 2)
   - Verify: Image files deleted from backend media directory
   - Check file paths: media/flyers/image1.jpg, image2.jpg, image3.jpg
   - Assert: Files do not exist in storage
   - Verify: Backend storage space freed (files not just hidden)

4. Implement no recovery test
   - Test: 'Deleted flyer cannot be recovered'
   - After deletion, attempt to access flyer via API (if direct API test possible)
   - Backend GET /api/flyers/{deleted_id}/ → returns 404 Not Found
   - Verify: No soft delete flag or "deleted_at" field (truly hard deleted)
   - Verify: Profile "My Flyers" does not include deleted flyer

5. Add cleanup
   - Cleanup: Test flyer already deleted (cleanup is the test itself)
   - Stop backend, reset app state
   - Mark Maestro flows with appropriate TDD markers after passing

### Acceptance Criteria
- [ ] Deleted flyer record removed from database [Verify: database query returns no record]
- [ ] Associated images deleted from storage [Verify: image files do not exist in media directory]
- [ ] No recovery possible (hard delete) [Verify: API returns 404, no soft delete flag]

### Files to Create/Modify
- `pockitflyer_app/maestro/flows/m04-e04/deleted_flyer_permanent_storage.yaml` - NEW: E2E test
- `pockitflyer_backend/users/tests/utils/verify_deletion.py` - NEW: Helper to verify database/storage cleanup

### Testing Requirements
**Note**: This task IS the E2E testing for permanent deletion. Test runs against real backend without mocks.

- **E2E test**: Full-stack validation using real backend, database, file storage

### Definition of Done
- [ ] Maestro test passes against real backend
- [ ] Database record permanently deleted (hard delete)
- [ ] Image files deleted from backend storage
- [ ] No recovery possible (API returns 404)
- [ ] Backend logs show deletion operations
- [ ] No errors during test execution
- [ ] Changes committed with reference to task ID

## Dependencies
- Requires: m04-e04-t01 (E2E test data infrastructure)
- Requires: m04-e04-t14 (User deletes flyer workflow)
- Requires: m04-e03 (Flyer hard delete implementation)
- Blocks: None (can run in parallel with other E2E tests)

## Technical Notes
- **Backend must be running**: Use `./scripts/start_e2e_backend.sh`
- **Test data**: Seed flyer with 3 images for comprehensive storage cleanup test
- **Hard delete**: Django ORM delete() method permanently removes record
- **Image cleanup**: Django signals or custom delete logic removes associated files
- **Storage verification**: Use backend filesystem check (ls, exists() check)
- **No soft delete**: No "is_deleted" flag, no "deleted_at" timestamp
- **Performance**: Deletion with storage cleanup should complete within 3 seconds
- **File orphans**: Ensure no orphaned image files remain after deletion
- **Helper function**: Create Python helper to verify database/storage cleanup
