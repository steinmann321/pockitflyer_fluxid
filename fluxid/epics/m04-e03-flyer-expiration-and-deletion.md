---
id: m04-e03
title: Flyer Expiration and Deletion
milestone: m04
status: pending
---

# Epic: Flyer Expiration and Deletion

## Overview
Expired flyers are automatically deactivated and removed from public feeds based on their expiration date. Users can manually extend expiration dates, which requires manual reactivation to prevent accidental republishing. Users can permanently delete flyers via hard delete with clear confirmation UI warning that deletion is irreversible and unrecoverable.

## Scope
- Backend expiration logic (scheduled checks or check-on-read)
- Expired flyer deactivation (remove from public feeds, keep in user's profile with "expired" status)
- Expiration date extension UI on edit screen
- Manual reactivation toggle when extending expiration
- Delete button on edit screen with confirmation dialog
- Backend hard delete API endpoint
- Database cascade deletion for related data (images, tags, etc.)
- Image storage cleanup on deletion
- UI indication of expired status on profile view
- Backend scheduled task or cron job for expiration processing (if not check-on-read)

## Success Criteria
- [ ] Expired flyers do not appear in public feeds [Test: flyer expires today, flyer expired yesterday, flyer expires tomorrow, timezone edge cases]
- [ ] Expired flyers still appear on user's profile with "expired" status indicator [Test: expired flyer visibility on own profile, status badge/label]
- [ ] Backend checks expiration automatically [Test: scheduled task execution, check-on-read logic, performance with 1000+ flyers]
- [ ] Users can extend expiration date on expired flyers [Test: extend by days/weeks/months, date picker validation]
- [ ] Extending expiration requires manual reactivation toggle [Test: extend without reactivation = still expired, extend with reactivation = active again]
- [ ] Reactivation is intentional and prevents accidental republishing [Test: UI flow requires explicit action, confirmation prompt if needed]
- [ ] Delete button shows clear warning about permanent deletion [Test: confirmation dialog with explicit warning text, cancel option]
- [ ] Confirmed deletion removes flyer permanently [Test: flyer removed from database, images deleted from storage, feed update, profile update]
- [ ] Hard delete is irreversible (no soft delete or recovery) [Test: attempt to recover deleted flyer = impossible, database record gone]
- [ ] Image storage is cleaned up on deletion [Test: verify storage files deleted, no orphaned images]
- [ ] Database cascade deletes related data [Test: tags removed, relationships cleaned up, no orphaned foreign keys]
- [ ] Deletion provides user feedback [Test: success confirmation, error handling, loading state]
- [ ] Expiration logic performs efficiently [Test: 1000+ flyers, query performance, index usage]

## Dependencies
- M04-E01 (Create and Publish Flyers) for flyer data structure
- M04-E02 (View and Edit Own Flyers) for edit/delete UI access
- Backend scheduler or cron for automatic expiration checks (or check-on-read implementation)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Expiration implementation choice: scheduled task (e.g., Django Celery) vs. check-on-read (filter expired in queries)
- Check-on-read is simpler and sufficient for MVP (filter `WHERE expiration_date > NOW()` in feed queries)
- Scheduled task is more robust for large scale (batch processing, separate worker)
- Hard delete is permanent - confirmation dialog must be explicit and clear
- Consider grace period before hard delete (e.g., "trash" state for 7 days) - but milestone specifies hard delete
- Image cleanup must happen atomically with database deletion (transaction or cleanup job)
- Timezone handling: expiration date should use UTC in backend, display in user's timezone in UI
- Reactivation toggle prevents users from accidentally republishing old content when just trying to preserve it
- Profile view should clearly distinguish active vs. expired flyers (visual indicator)
- Delete operation should be idempotent (safe to retry on network failure)
