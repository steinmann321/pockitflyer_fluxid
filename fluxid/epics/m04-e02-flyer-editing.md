---
id: m04-e02
title: Flyer Editing
milestone: m04
status: pending
tasks:
  - m04-e02-t01
  - m04-e02-t02
  - m04-e02-t03
---

# Epic: Flyer Editing

## Overview
Enables users to edit all aspects of their published flyers, including images, text content, category tags, location, and dates. Changes are immediately reflected in feeds and profile, with backend validation and geocoding support for address updates.

## Scope
- Navigation from profile flyer list to flyer edit interface
- Flyer edit interface with all fields editable:
  - Image upload/replacement (1-5 images)
  - Title text field
  - Two description/info text fields
  - Category tag selector
  - Address input field
  - Publication date picker
  - Expiration date picker
  - Save button
- Backend flyer update endpoint
- Image replacement handling (upload new, remove old)
- Address geocoding integration for location updates
- Authorization checks (user can only edit own flyers)
- Validation for all fields
- Immediate feed and profile refresh after save

## Success Criteria
- [ ] Users can navigate from profile to edit any of their own flyers [Test: navigation flow, edit form pre-populated with current values, handles various flyer states (active, expired)]
- [ ] Edit interface allows modification of all flyer fields [Test: image upload (add/remove/replace, validate count 1-5), text fields (length validation, special characters), category selection, address input, date pickers (past/future dates, expiration after publication)]
- [ ] Address changes trigger backend geocoding conversion [Test: valid addresses geocoded correctly, invalid addresses rejected with clear errors, geocoding service failures handled gracefully, coordinates stored properly]
- [ ] Backend validates all updates before saving [Test: field validation (required fields, length limits, data types), image validation (count, size, type), date validation (publication before expiration), authorization (reject edits to others' flyers)]
- [ ] Image replacement manages storage correctly [Test: old images deleted when replaced, new images stored, handles partial failures (some images succeed, some fail), no orphaned files]
- [ ] Saved changes appear immediately in all views [Test: feed updates instantly, profile list reflects changes, detail view shows new data, no stale cache]
- [ ] Error scenarios provide actionable feedback [Test: validation errors shown inline, geocoding failures explained, network errors recoverable, concurrent edit conflicts handled]

## Tasks
- Flyer edit interface UI and form handling (m04-e02-t01)
- Backend flyer update endpoint with validation (m04-e02-t02)
- Image and geocoding integration for updates (m04-e02-t03)

## Dependencies
- m01 (feed display infrastructure - changes must appear in feed)
- m02 (authentication - user must be logged in)
- m03 (flyer publishing - creates flyers to be edited)
- m04-e01 (profile management - navigation from profile to edit)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
**Frontend Implementation:**
- Edit form pre-populated with current flyer data
- Image upload with preview and ability to remove/reorder
- Category tag selector (multi-select or radio based on design)
- Address autocomplete/validation feedback
- Date pickers with validation (expiration must be after publication)
- Form validation before save
- Loading state during save
- Success/error feedback
- Handle navigation back to profile after save

**Backend Implementation:**
- PUT/PATCH endpoint for flyer updates
- Authorization middleware (verify user owns flyer)
- Field validation (all fields as per m03 requirements)
- Image handling:
  - Upload new images
  - Delete removed images
  - Maintain 1-5 image count
- Geocoding integration for address changes:
  - Call geocoding service (geopy)
  - Update coordinates
  - Handle geocoding failures
- Updated timestamp management
- Transaction handling (rollback on partial failure)

**Geocoding Integration:**
- Reuse existing geocoding service from m03
- Handle geocoding failures gracefully (don't block save if coordinates can't be updated)
- Validate address format before geocoding
- Circuit breaker pattern for resilience

**Data Integrity:**
- Maintain referential integrity (favorites, feed references)
- Validate date changes don't break business logic
- Ensure image count stays within bounds
- Handle concurrent edits (optimistic locking or last-write-wins)
