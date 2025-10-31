---
id: m04-e03-t02
title: Flyer Deletion with Cascade and Confirmation
epic: m04-e03
milestone: m04
status: pending
---

# Task: Flyer Deletion with Cascade and Confirmation

## Context
Part of Flyer Deletion and Lifecycle (m04-e03) in Milestone 4 (m04).

Implements permanent flyer deletion with full cascade cleanup of related data (images, favorites, feed references) and user-facing confirmation dialogs to prevent accidental deletion. This is a destructive action with no recovery, so careful implementation of authorization, confirmation, and data cleanup is critical.

## Implementation Guide for LLM Agent

### Objective
Create a complete flyer deletion system with backend hard delete, cascade cleanup of all related data, frontend confirmation dialogs, and immediate UI updates across all affected screens.

### Steps
1. Create backend DELETE endpoint for flyers
   - Create DELETE handler in `pockitflyer_backend/flyers/views.py`
   - Route: `DELETE /api/flyers/{id}/`
   - Authorization check: verify requesting user owns the flyer (compare `flyer.owner_id` with `request.user.id`)
   - Return 403 Forbidden if user does not own the flyer
   - Return 404 Not Found if flyer does not exist
   - Call deletion service method (step 2) to perform cascade delete
   - Return 204 No Content on successful deletion
   - Log deletion event with user ID, flyer ID, and timestamp for audit trail

2. Implement cascade deletion logic in backend
   - Create deletion service method in `pockitflyer_backend/flyers/services.py` (create file if needed)
   - Use database transaction to ensure atomicity (all deletions succeed or all rollback)
   - Deletion sequence inside transaction:
     ```python
     def delete_flyer_with_cascade(flyer_id, user_id):
         # Begin transaction
         with transaction.atomic():
             # 1. Get flyer and verify ownership
             flyer = Flyer.objects.select_for_update().get(id=flyer_id)
             if flyer.owner_id != user_id:
                 raise PermissionError("User does not own this flyer")

             # 2. Delete favorite records (cascade)
             Favorite.objects.filter(flyer_id=flyer_id).delete()

             # 3. Delete flyer images from file storage
             if flyer.image_path:
                 delete_file_from_storage(flyer.image_path)

             # 4. Delete flyer record (cascade other related data via DB foreign keys)
             flyer.delete()

             # 5. Log deletion event
             log_flyer_deletion(user_id, flyer_id)
         # Transaction commits here if all succeeded
     ```
   - Add error handling and rollback on any failure
   - Create helper function `delete_file_from_storage(file_path)` to remove image files from disk or cloud storage

3. Update database models to support cascade deletion
   - Review foreign key relationships in `pockitflyer_backend/flyers/models.py` and related models
   - Ensure foreign keys have appropriate `on_delete` behavior:
     - Favorites referencing flyers: `on_delete=models.CASCADE` (delete favorites when flyer deleted)
     - Any other relationships: determine appropriate cascade behavior
   - Create database migration if model changes required: `python manage.py makemigrations`
   - Document cascade behavior in model docstrings

4. Create backend tests for deletion endpoint and cascade logic
   - **Unit tests** in `pockitflyer_backend/tests/test_flyer_deletion.py`:
     - Test `delete_flyer_with_cascade` removes flyer record from database
     - Test cascade deletes all favorite records referencing the flyer
     - Test cascade deletes flyer image file from storage
     - Test transaction rollback if any deletion step fails (e.g., file deletion error)
     - Test deletion logs event with correct user ID, flyer ID, timestamp

   - **Integration tests** in `pockitflyer_backend/tests/test_flyer_api.py`:
     - Test DELETE request with valid owner returns 204 No Content
     - Test DELETE request removes flyer from database
     - Test DELETE request removes all related favorites
     - Test DELETE request removes flyer images from storage
     - Test GET request for deleted flyer returns 404 Not Found
     - Test flyer no longer appears in feed queries after deletion
     - Test authorization: DELETE request from non-owner returns 403 Forbidden
     - Test DELETE request for non-existent flyer returns 404 Not Found

5. Create frontend delete button and confirmation dialog
   - Add delete button to flyer edit screen (`pockitflyer_app/lib/screens/flyer_edit_screen.dart`)
   - Position delete button prominently (e.g., at bottom of edit form or in app bar menu)
   - Style as destructive action (e.g., red color, warning icon)
   - On delete button tap, show confirmation dialog (not immediate deletion)
   - Create confirmation dialog widget in `pockitflyer_app/lib/widgets/delete_confirmation_dialog.dart`:
     - Title: "Delete Flyer?"
     - Message: "This will permanently delete your flyer and all associated data. This action cannot be undone."
     - If flyer is active, add warning: "This flyer is currently active and visible to users."
     - Two buttons: "Cancel" (neutral style) and "Delete" (destructive style, red)
     - Return boolean from dialog: `true` if confirmed, `false` if cancelled

6. Implement frontend deletion API call and state management
   - Create deletion method in flyer service (`pockitflyer_app/lib/services/flyer_service.dart` or similar):
     ```dart
     Future<void> deleteFlyer(String flyerId) async {
       final response = await dio.delete('/api/flyers/$flyerId/');
       if (response.statusCode != 204) {
         throw Exception('Failed to delete flyer');
       }
     }
     ```
   - Add error handling for 403 Forbidden (show error: "You don't have permission to delete this flyer")
   - Add error handling for 404 Not Found (show error: "Flyer not found")
   - Add error handling for network errors (show error: "Failed to delete flyer. Please try again.")

   - Update flyer provider/notifier (`pockitflyer_app/lib/providers/flyer_provider.dart`):
     - Create `deleteFlyer(String flyerId)` method
     - Show loading state during deletion (e.g., loading indicator on screen)
     - Call flyer service deletion method
     - On success: remove flyer from local state, invalidate affected providers (feed, profile)
     - On error: show error message to user, keep flyer in state
     - Navigate back to profile screen after successful deletion

7. Update UI to reflect deletion across all screens
   - Profile screen (`pockitflyer_app/lib/screens/profile_screen.dart`):
     - After deletion, remove flyer from profile list immediately
     - Update empty state if no flyers remain
   - Feed screen (main feed widget):
     - Ensure deleted flyer does not appear in feed after deletion (provider invalidation handles this)
   - Flyer detail screen:
     - If user navigates to deleted flyer URL, show 404 error or redirect to profile

8. Create frontend tests for deletion flow
   - **Widget tests** in `pockitflyer_app/test/widgets/delete_confirmation_dialog_test.dart`:
     - Test dialog renders with correct title, message, and buttons
     - Test dialog shows active flyer warning when flyer is active
     - Test cancel button returns `false` and closes dialog
     - Test delete button returns `true` and closes dialog
     - Test dialog styling matches destructive action patterns

   - **Widget tests** in `pockitflyer_app/test/screens/flyer_edit_screen_test.dart`:
     - Test delete button renders in edit screen
     - Test tapping delete button shows confirmation dialog
     - Test cancelling dialog keeps flyer and stays on edit screen
     - Test confirming dialog triggers deletion

   - **Integration tests** in `pockitflyer_app/test/integration/flyer_deletion_test.dart`:
     - Test full deletion flow with mocked API (tap delete → confirm → API called → navigation to profile)
     - Test deleted flyer removed from profile list after deletion
     - Test deleted flyer removed from feed after deletion
     - Test error handling when API returns 403 Forbidden
     - Test error handling when API returns 404 Not Found
     - Test error handling when network request fails
     - Test loading state displays during deletion

### Acceptance Criteria
- [ ] Delete button visible in flyer edit interface [Test: open flyer edit screen, verify delete button present]
- [ ] Delete button shows confirmation dialog when tapped [Test: tap delete, verify dialog appears with warning message]
- [ ] Confirmation dialog explains permanence and consequences [Test: read dialog message, verify mentions permanent deletion and data loss]
- [ ] Cancelling dialog keeps flyer unchanged [Test: tap cancel, verify dialog closes, flyer still exists]
- [ ] Confirming dialog triggers deletion API call [Test: tap delete in dialog, verify API request sent]
- [ ] Backend deletes flyer record from database [Test: confirm deletion, query database, verify flyer record removed]
- [ ] Backend deletes all favorite records for the flyer [Test: create favorites, delete flyer, verify favorites removed]
- [ ] Backend deletes flyer image from file storage [Test: delete flyer with image, verify image file removed from storage]
- [ ] Backend returns 403 if user does not own flyer [Test: attempt to delete another user's flyer, receive 403 error]
- [ ] Backend logs deletion event [Test: delete flyer, verify log entry with user ID, flyer ID, timestamp]
- [ ] Frontend removes flyer from profile immediately after deletion [Test: delete flyer, verify profile list updates without refresh]
- [ ] Frontend removes flyer from feed after deletion [Test: delete flyer, verify feed no longer shows it]
- [ ] Frontend navigates back to profile after successful deletion [Test: confirm deletion, verify navigation to profile screen]
- [ ] Frontend shows error message if deletion fails [Test: simulate API error, verify error message displayed]
- [ ] Deleted flyers cannot be retrieved (permanent deletion) [Test: attempt to GET deleted flyer, receive 404]
- [ ] Backend tests pass with >90% coverage on deletion logic
- [ ] Frontend tests pass with >90% coverage on deletion UI and flow

### Files to Create/Modify
- `pockitflyer_backend/flyers/views.py` - MODIFY: add DELETE endpoint handler
- `pockitflyer_backend/flyers/services.py` - NEW: cascade deletion service method
- `pockitflyer_backend/flyers/models.py` - MODIFY: verify/update foreign key cascade behavior
- `pockitflyer_backend/flyers/migrations/XXXX_update_cascade_delete.py` - NEW: migration if model changes needed
- `pockitflyer_backend/tests/test_flyer_deletion.py` - NEW: unit tests for deletion service
- `pockitflyer_backend/tests/test_flyer_api.py` - MODIFY: add integration tests for DELETE endpoint
- `pockitflyer_app/lib/screens/flyer_edit_screen.dart` - MODIFY: add delete button
- `pockitflyer_app/lib/widgets/delete_confirmation_dialog.dart` - NEW: confirmation dialog widget
- `pockitflyer_app/lib/services/flyer_service.dart` - MODIFY: add deleteFlyer method
- `pockitflyer_app/lib/providers/flyer_provider.dart` - MODIFY: add deletion state management
- `pockitflyer_app/lib/screens/profile_screen.dart` - MODIFY: handle flyer removal after deletion
- `pockitflyer_app/test/widgets/delete_confirmation_dialog_test.dart` - NEW: dialog widget tests
- `pockitflyer_app/test/screens/flyer_edit_screen_test.dart` - NEW/MODIFY: edit screen tests with deletion
- `pockitflyer_app/test/integration/flyer_deletion_test.dart` - NEW: integration tests for deletion flow

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit test**: Cascade deletion logic, transaction rollback, file deletion, authorization checks, logging
- **Widget test**: Delete button rendering, confirmation dialog display and interaction, button styling
- **Integration test**: Full deletion flow with mocked API, state updates, navigation, error scenarios, UI updates across screens

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Django and Flutter style guides)
- [ ] No console errors or warnings
- [ ] Deletion is atomic (all-or-nothing via transactions)
- [ ] All related data properly cleaned up (no orphaned records or files)
- [ ] Authorization prevents unauthorized deletions
- [ ] User receives clear confirmation and feedback
- [ ] UI updates immediately across all screens
- [ ] Deletion events logged for audit purposes
- [ ] Changes committed with reference to task ID (m04-e03-t02)
- [ ] Ready for dependent tasks to use

## Dependencies
- Requires: m04-e02 (flyer edit interface - provides location for delete button)
- Requires: m04-e01 (profile page - needs to reflect deletion)
- Requires: m03 (flyer creation and favorites - creates data to be deleted)
- Blocks: None (final task in epic)

## Technical Notes
- **Database transactions**: Use Django's `transaction.atomic()` to ensure all deletions succeed or rollback
- **File deletion**: Consider using try-except for file deletion to handle missing files gracefully (file may already be deleted)
- **Foreign key cascade**: Django's `on_delete=models.CASCADE` handles database-level cascade, but you still need to handle file storage cleanup manually
- **Rate limiting**: Consider adding rate limiting to DELETE endpoint to prevent abuse (e.g., max 10 deletions per minute per user)
- **Soft delete alternative**: Epic specifies hard delete, but consider if audit requirements change (soft delete = mark as deleted, keep data)
- **Favorites cleanup**: If favorites are in separate table, ensure foreign key cascade or manual deletion
- **Search indexes**: If using search indexes (e.g., ElasticSearch), ensure deleted flyers removed from indexes
- **Cache invalidation**: If using caching, invalidate cache entries for deleted flyers
- **State management**: Use Riverpod's `ref.invalidate()` to refresh feed and profile providers after deletion
- **Navigation**: Use `Navigator.pop()` or router to navigate back after deletion completes
- **Loading states**: Show loading indicator during deletion to prevent user confusion or double-taps

## References
- Django transactions: https://docs.djangoproject.com/en/5.1/topics/db/transactions/
- Django on_delete options: https://docs.djangoproject.com/en/5.1/ref/models/fields/#django.db.models.ForeignKey.on_delete
- Flutter dialog: https://api.flutter.dev/flutter/material/showDialog.html
- Flutter navigation: https://docs.flutter.dev/cookbook/navigation/navigation-basics
- Riverpod state invalidation: https://riverpod.dev/docs/concepts/reading/#invalidating-a-provider
