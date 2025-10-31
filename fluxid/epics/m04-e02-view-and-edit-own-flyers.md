---
id: m04-e02
title: View and Edit Own Flyers
milestone: m04
status: pending
---

# Epic: View and Edit Own Flyers

## Overview
Users view all their published flyers listed on their own profile page. Tapping any flyer navigates to a full edit screen where they can modify all aspects: swap/reorder/add/remove images (maintaining 1-5 limit), edit text fields, change category tags, update location with new geocoding, and adjust publication/expiration dates. All changes are persisted via backend update APIs with complete validation.

## Scope
- Profile page UI shows user's published flyers list
- Tap navigation from profile flyer card to edit screen
- Edit screen with all creation fields pre-populated
- Image editing (add, remove, reorder within 1-5 limit)
- Text field editing with character limit enforcement
- Category tag editing (multi-select modification)
- Location address editing with geocoding re-trigger
- Date editing with publication/expiration validation
- Save action with backend update API call
- Backend flyer update endpoint
- Model-layer validation for all field updates
- Image storage updates (new uploads, deletions of removed images)
- Geocoding re-execution for address changes
- Concurrent edit handling and conflict resolution

## Success Criteria
- [ ] User profile page displays list of all user's published flyers [Test: 0 flyers, 1 flyer, many flyers, pagination if needed]
- [ ] Tapping a flyer from profile navigates to edit screen [Test: navigation, screen transition, data loading]
- [ ] Edit screen pre-populates all existing flyer data [Test: images, text, tags, location, dates all match published flyer]
- [ ] Users can add/remove/reorder images maintaining 1-5 limit [Test: remove to 1, add to 5, reorder, attempt to remove all, attempt to add 6th]
- [ ] Text fields show existing content and allow editing with character limits [Test: modify text, exceed limits, clear fields]
- [ ] Category tags can be added/removed [Test: add new tags, remove existing tags, change all tags]
- [ ] Location can be changed triggering new geocoding [Test: valid new address, invalid address, geocoding failures]
- [ ] Dates can be modified with validation [Test: extend expiration, change publication date, invalid date ranges]
- [ ] Save action persists all changes to backend [Test: successful save, network failures, validation errors, rollback on error]
- [ ] Backend validates all updates at model layer [Test: invalid data rejection, required field enforcement, business logic validation]
- [ ] Image storage properly handles additions and deletions [Test: new image upload, old image removal, storage cleanup]
- [ ] Geocoding service is called only when address changes [Test: no address change = no geocoding call, address change triggers geocoding]
- [ ] Concurrent edits are handled gracefully [Test: simultaneous edits from multiple devices, last-write-wins or optimistic locking]
- [ ] Edit flow provides clear feedback for all actions [Test: loading states, success confirmation, error messages]

## Dependencies
- M02 (User Authentication) for user profile context
- M04-E01 (Create and Publish Flyers) for flyer data structure
- External: geopy library for geocoding (on address changes)
- External: Pillow library for image processing (on new uploads)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Edit preserves flyer ID and creator relationship (no creator transfer)
- Geocoding should only be triggered if address actually changes (performance optimization)
- Image deletions must clean up storage to prevent orphaned files
- Consider UX for long-running operations (geocoding, image uploads)
- Backend validation must prevent invalid state transitions
- Profile flyer list should show flyer status (active, expired, scheduled for future publication)
- Optimistic updates in UI with server-side reconciliation on conflicts
- Clear user feedback when geocoding fails during edit (allow retry or manual coordinate input)
