---
id: m04-e01
title: Profile Management
milestone: m04
status: pending
tasks:
  - m04-e01-t01
  - m04-e01-t02
  - m04-e01-t03
---

# Epic: Profile Management

## Overview
Enables users to view and edit their own profiles, including profile picture, display name, and privacy settings. This establishes the user's identity and control over their personal information on the platform.

## Scope
- Navigation from header avatar to own profile page
- Profile view page displaying:
  - Profile picture
  - Display name
  - List of user's published flyers (active and expired)
- Profile edit interface with:
  - Profile picture upload and replacement
  - Display name text input
  - Privacy settings (email contact permission toggle)
- Backend profile update endpoint
- Profile picture upload, storage, and replacement (remove old image)
- Authorization checks (user can only edit own profile)
- Form validation and error handling

## Success Criteria
- [ ] Users can navigate to their own profile by tapping header avatar [Test: navigation flow, profile data loads correctly, handles missing data gracefully]
- [ ] Profile page displays complete user information and flyer list [Test: profile picture rendering, name display, flyer list shows active/expired distinction, empty state when no flyers]
- [ ] Profile editing interface allows updates to all fields [Test: image upload (various formats, sizes), name validation (length limits, special characters), privacy toggle persistence]
- [ ] Backend validates and processes profile updates correctly [Test: authorization checks (reject unauthorized edits), image validation (type, size limits), concurrent update handling]
- [ ] Image replacement removes old files and stores new ones [Test: storage cleanup verified, no orphaned files, handles upload failures gracefully]
- [ ] Changes appear immediately after save [Test: profile view refreshes, changes visible in header avatar, no stale cache]
- [ ] Error scenarios handled with clear user feedback [Test: network failures, validation errors, server errors, file upload failures]

## Tasks
- Profile view page UI and navigation (m04-e01-t01)
- Profile edit interface UI and validation (m04-e01-t02)
- Backend profile update endpoint and image handling (m04-e01-t03)

## Dependencies
- m01 (anonymous browsing infrastructure)
- m02 (authentication - user must be logged in to view/edit profile)
- m03 (flyer publishing - profile displays user's flyers)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
**Frontend Implementation:**
- Profile view is read-only display with "Edit Profile" button
- Edit interface should use forms with validation
- Image upload should preview before save
- Loading states during profile updates
- Success feedback after save
- Handle navigation back to profile view after save

**Backend Implementation:**
- PUT/PATCH endpoint for profile updates
- Authorization middleware (verify user owns profile)
- Image upload handling with validation (file type, size)
- Old profile picture deletion when new one uploaded
- Updated timestamp management
- Rate limiting to prevent abuse

**Security Considerations:**
- Only authenticated users can access profile endpoints
- Users can only edit their own profiles
- Image upload validation (prevent malicious files)
- Input sanitization for display name
- Privacy settings properly enforced
