---
id: m04-e03
title: Flyer Deletion and Lifecycle
milestone: m04
status: pending
tasks:
  - m04-e03-t01
  - m04-e03-t02
---

# Epic: Flyer Deletion and Lifecycle

## Overview
Completes the flyer lifecycle management by enabling users to reactivate expired flyers through date extension and permanently delete flyers they no longer want. Includes hard deletion with cascade removal of all related data and confirmation dialogs for destructive actions.

## Scope
- Reactivation of expired flyers:
  - Edit expired flyer dates to extend validity
  - Automatic return to active status when dates updated
- Flyer deletion functionality:
  - Delete button/option in edit interface or profile
  - Confirmation dialog for destructive action
  - Immediate removal from all feeds and profile
- Backend hard delete implementation:
  - Permanent deletion (no archiving or soft delete)
  - Cascade deletion of related data:
    - Flyer images (file storage cleanup)
    - User favorites of the flyer
    - Feed references
  - No recovery after deletion
- Authorization checks (user can only delete own flyers)

## Success Criteria
- [ ] Expired flyers can be edited and reactivated by extending dates [Test: date picker allows future dates, flyer returns to active status, appears in active feed again, status change reflected immediately in profile]
- [ ] Delete action requires explicit confirmation [Test: confirmation dialog shown, action cancellable, dialog explains permanence, different confirmation for active vs expired flyers]
- [ ] Deleted flyers removed immediately from all locations [Test: disappears from profile list, removed from feed, detail view returns 404, favorites list no longer includes it, search results exclude it]
- [ ] Backend performs hard delete with full cascade [Test: database record deleted, all images removed from storage, favorite records deleted, feed references cleaned up, no orphaned data remains]
- [ ] Authorization prevents unauthorized deletions [Test: user can only delete own flyers, attempt to delete others' flyers rejected, proper error messages, logs security attempts]
- [ ] Deletion is permanent with no recovery [Test: deleted flyers cannot be retrieved, no soft delete flag, no undo functionality, user clearly warned before confirming]

## Tasks
- Flyer reactivation through date editing (m04-e03-t01)
- Flyer deletion with cascade and confirmation (m04-e03-t02)

## Dependencies
- m03 (flyer publishing - creates flyers to be deleted)
- m04-e01 (profile management - displays active/expired status)
- m04-e02 (flyer editing - provides interface for date updates)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
**Reactivation Logic:**
- Expired flyers become active again when expiration date extended to future
- Use existing edit interface from e02
- No special "reactivate" button needed - date editing handles it
- Status automatically recalculated based on dates
- Flyer appears in feed again after reactivation

**Frontend Implementation (Deletion):**
- Delete button in edit interface or profile flyer list
- Confirmation dialog with:
  - Clear warning about permanence
  - Explanation of what will be deleted
  - Cancel and Confirm buttons
  - Different styling for destructive action
- Loading state during deletion
- Navigation back to profile after successful deletion
- Error handling if deletion fails

**Backend Implementation (Deletion):**
- DELETE endpoint for flyers
- Authorization middleware (verify user owns flyer)
- Hard delete implementation:
  1. Begin transaction
  2. Delete favorite records (cascade)
  3. Delete flyer images from storage
  4. Delete flyer record
  5. Commit transaction
- Rollback on any failure
- Return 204 No Content on success
- Log deletion events (audit trail)

**Cascade Deletion Requirements:**
- Flyer images: Remove from file storage (S3, local storage, etc.)
- Favorites: Delete all favorite records referencing this flyer
- Feed references: Handle feed cache invalidation
- Search indexes: Update search indexes if applicable
- No orphaned data: Verify all related data removed

**Data Integrity:**
- Use database foreign key cascade where appropriate
- Verify all related data cleaned up
- Handle deletion failures gracefully (rollback)
- Prevent deletion if business logic requires preservation (unlikely in this case)

**Security and Audit:**
- Authorization checks prevent unauthorized deletions
- Log deletion events with user ID, flyer ID, timestamp
- Rate limiting to prevent abuse (mass deletions)
- Consider soft delete for audit purposes (currently hard delete per requirements)

**User Experience:**
- Clear distinction between active and expired flyers in profile
- Confirmation dialog prevents accidental deletion
- Immediate feedback when deletion complete
- No confusing states (flyer either exists or doesn't)
