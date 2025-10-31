---
id: m04-e03-t01
title: Flyer Reactivation Through Date Editing
epic: m04-e03
milestone: m04
status: pending
---

# Task: Flyer Reactivation Through Date Editing

## Context
Part of Flyer Deletion and Lifecycle (m04-e03) in Milestone 4 (m04).

Enables users to reactivate expired flyers by extending their expiration date through the existing edit interface. When a user edits an expired flyer and changes the expiration date to a future date, the flyer automatically becomes active again and reappears in the feed. This provides a seamless way to extend flyer validity without requiring a separate "reactivate" action.

## Implementation Guide for LLM Agent

### Objective
Implement automatic flyer reactivation logic when expired flyers have their expiration date updated to a future date, ensuring the flyer returns to active status and appears in feeds again.

### Steps
1. Update backend flyer status calculation logic
   - Locate the Flyer model in `pockitflyer_backend/flyers/models.py`
   - Add or update a property method `is_active` that calculates status based on current date vs expiration date
   - Logic: `is_active = True if expiration_date > current_date else False`
   - Ensure this property is used consistently across all feed queries and profile displays
   - If a separate `status` field exists on the model, update it to be auto-calculated or remove it in favor of the property

2. Verify flyer update endpoint handles date changes correctly
   - Locate the flyer update endpoint (likely `PUT /api/flyers/{id}/` in `pockitflyer_backend/flyers/views.py`)
   - Ensure the endpoint accepts `expiration_date` field updates
   - Verify authorization check: user must own the flyer to edit it
   - No special logic needed - the `is_active` property automatically recalculates when date changes
   - Return updated flyer data including current active status in response

3. Update backend serializer to include active status
   - Locate the flyer serializer in `pockitflyer_backend/flyers/serializers.py`
   - Add `is_active` field to serializer output (read-only field)
   - Include `expiration_date` in editable fields
   - Ensure serializer returns updated status after date modification

4. Update frontend flyer edit interface for expired flyers
   - Locate the flyer edit screen/widget (likely in `pockitflyer_app/lib/screens/flyer_edit_screen.dart` or similar)
   - Ensure expired flyers can be opened in edit mode (no restrictions preventing editing)
   - Verify date picker allows selecting future dates for `expiration_date` field
   - Add informational message when editing expired flyer: "Update the expiration date to reactivate this flyer"
   - Ensure date picker validation: expiration_date must be in the future to reactivate

5. Update frontend state management to reflect status changes
   - Locate the flyer state provider/notifier (likely using Riverpod in `pockitflyer_app/lib/providers/`)
   - After successful flyer update API call, update the flyer object in local state
   - Ensure the updated `is_active` status from API response is applied to local flyer object
   - Trigger UI refresh for affected screens (profile, feed) to show updated status

6. Update frontend profile/feed display logic
   - Locate profile screen showing user's flyers (likely in `pockitflyer_app/lib/screens/profile_screen.dart`)
   - Ensure profile groups flyers by active/expired status using `is_active` field
   - After flyer date update, verify flyer moves from "Expired" section to "Active" section
   - Locate feed logic and ensure reactivated flyers appear in the feed again
   - Feed should query/filter based on `is_active` status from backend

7. Create comprehensive tests for reactivation flow
   - **Backend unit tests** (`pockitflyer_backend/tests/test_flyers.py`):
     - Test `is_active` property returns `True` when `expiration_date` is in future
     - Test `is_active` property returns `False` when `expiration_date` is in past
     - Test updating expired flyer's date to future changes `is_active` to `True`
     - Test feed queries exclude flyers where `is_active` is `False`
     - Test feed queries include flyers where `is_active` is `True`

   - **Backend integration tests** (`pockitflyer_backend/tests/test_flyer_api.py`):
     - Test PUT request to update expired flyer's `expiration_date` to future returns updated flyer with `is_active=True`
     - Test updated flyer appears in GET feed request after reactivation
     - Test authorization: non-owner cannot update flyer dates
     - Test validation: expiration_date cannot be set to past date

   - **Frontend widget tests** (`pockitflyer_app/test/screens/flyer_edit_screen_test.dart`):
     - Test expired flyer can be opened in edit mode
     - Test date picker allows selecting future dates
     - Test informational message displays when editing expired flyer
     - Test successful update shows success feedback

   - **Frontend integration tests** (`pockitflyer_app/test/integration/flyer_reactivation_test.dart`):
     - Test updating expired flyer date to future (with mocked API)
     - Test flyer moves from expired to active section in profile after update
     - Test reactivated flyer appears in feed after update
     - Test state management updates flyer status correctly

### Acceptance Criteria
- [ ] Expired flyers can be edited and have their expiration date updated [Test: open expired flyer in edit mode, change date to future, save successfully]
- [ ] Flyer automatically becomes active when expiration date changed to future [Test: update expired flyer date, verify `is_active` property returns `True`]
- [ ] Reactivated flyer appears in active section of profile [Test: after date update, verify flyer shows in "Active" section, not "Expired" section]
- [ ] Reactivated flyer appears in main feed [Test: after date update, verify flyer appears in feed query results]
- [ ] Status change reflected immediately in UI after update [Test: save date change, verify UI updates without refresh, verify status badge changes]
- [ ] Authorization prevents non-owners from editing flyers [Test: attempt to update another user's flyer, receive 403 Forbidden]
- [ ] Backend tests pass with >90% coverage on flyer model and update endpoint
- [ ] Frontend tests pass with >90% coverage on edit screen and state management

### Files to Create/Modify
- `pockitflyer_backend/flyers/models.py` - MODIFY: add/update `is_active` property based on date comparison
- `pockitflyer_backend/flyers/views.py` - MODIFY/VERIFY: ensure update endpoint handles date changes
- `pockitflyer_backend/flyers/serializers.py` - MODIFY: include `is_active` in serializer output
- `pockitflyer_backend/tests/test_flyers.py` - NEW/MODIFY: unit tests for `is_active` property
- `pockitflyer_backend/tests/test_flyer_api.py` - NEW/MODIFY: integration tests for update endpoint
- `pockitflyer_app/lib/screens/flyer_edit_screen.dart` - MODIFY: ensure expired flyers editable, add informational message
- `pockitflyer_app/lib/providers/flyer_provider.dart` - MODIFY: update state after successful edit
- `pockitflyer_app/lib/screens/profile_screen.dart` - MODIFY: ensure active/expired grouping uses `is_active` field
- `pockitflyer_app/test/screens/flyer_edit_screen_test.dart` - NEW: widget tests for edit screen
- `pockitflyer_app/test/integration/flyer_reactivation_test.dart` - NEW: integration tests for reactivation flow

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit test**: Flyer model `is_active` property logic, date comparison, edge cases (same day, past dates, far future)
- **Widget test**: Edit screen rendering for expired flyers, date picker interaction, informational messages
- **Integration test**: Full update flow with mocked API, state management updates, UI refresh, feed/profile display updates

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Django and Flutter style guides)
- [ ] No console errors or warnings
- [ ] Flyer status automatically updates based on date changes
- [ ] UI reflects status changes immediately without manual refresh
- [ ] Authorization checks prevent unauthorized edits
- [ ] Changes committed with reference to task ID (m04-e03-t01)
- [ ] Ready for dependent tasks to use

## Dependencies
- Requires: m04-e02 (flyer editing interface and endpoints must exist)
- Requires: m04-e01 (profile page displaying active/expired flyers must exist)
- Blocks: m04-e03-t02 (deletion feature - depends on understanding active/expired status)

## Technical Notes
- **Date comparison**: Use timezone-aware date comparison to avoid edge cases with different timezones
- **Status calculation**: Prefer calculated property over stored status field to avoid data inconsistencies
- **Feed queries**: Ensure all feed queries filter by `is_active` property or equivalent logic
- **State management**: Use Riverpod's state invalidation to trigger UI updates after flyer modification
- **Validation**: Consider adding backend validation to prevent setting expiration_date in the past (or allow it but warn user flyer will be expired)
- **Performance**: If `is_active` is a property (not database field), consider indexing strategy for feed queries (may need to query by date field instead)

## References
- Django model properties: https://docs.djangoproject.com/en/5.1/topics/db/models/#model-methods
- Django REST Framework serializers: https://www.django-rest-framework.org/api-guide/serializers/
- Flutter Riverpod state management: https://riverpod.dev/docs/concepts/reading/
- Flutter date picker: https://api.flutter.dev/flutter/material/showDatePicker.html
