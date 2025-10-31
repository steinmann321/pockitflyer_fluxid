---
id: m04
title: Users can manage their profiles and edit flyers
status: pending
---

# Milestone: Users can manage their profiles and edit flyers

## Deliverable
Users can view and edit their own profiles (picture and name), manage the full lifecycle of their published flyers including editing content and dates, reactivating expired flyers, and permanently deleting flyers they no longer want. This completes the user's control over their presence and content on the platform, enabling ongoing maintenance and curation of published materials.

## Success Criteria
- [ ] Users can tap their profile avatar in header to navigate to their own profile page
- [ ] Profile page displays: profile picture, name, and list of user's published flyers (active and expired)
- [ ] Users can tap "Edit Profile" to access profile editing interface
- [ ] Profile editing allows changing profile picture (upload new image)
- [ ] Profile editing allows changing display name
- [ ] Profile editing includes privacy settings (email contact permission)
- [ ] Users can tap any of their own flyers in profile to access flyer edit interface
- [ ] Flyer editing allows changing: all images, title, description fields, category tags, address, publication date, expiration date
- [ ] Address changes trigger backend geocoding conversion
- [ ] Users can save edited flyers and changes appear immediately in feed and profile
- [ ] Expired flyers can be edited and reactivated by extending dates
- [ ] Users can permanently delete flyers with confirmation dialog
- [ ] Deleted flyers are immediately removed from all feeds and profile
- [ ] Backend validates all profile and flyer updates
- [ ] Backend handles image replacements (upload new, remove old)
- [ ] Backend handles geocoding for address updates
- [ ] Backend implements hard delete (permanent removal, no archiving)
- [ ] Complete UI implementation for profile and flyer management workflows
- [ ] Full backend integration for updates and deletions
- [ ] All flows are polished and production-ready
- [ ] Can be deployed independently (builds on m01, m02, m03)
- [ ] Requires no additional milestones to be useful

## Validation Questions
**Before marking this milestone complete, answer:**
- [ ] Can a real user perform complete workflows with only this milestone? Yes - view profile, edit profile, edit flyers, delete flyers
- [ ] Is it polished enough to ship publicly? Yes - complete management experience
- [ ] Does it solve a real problem end-to-end? Yes - users need control over their identity and content
- [ ] Does it include both complete UI and functional backend integration? Yes - profile UI, edit UI, backend update/delete operations
- [ ] Can it run independently without waiting for other milestones? Yes - completes the user lifecycle started in m02
- [ ] Would you personally use this if it were released today? Yes - essential for maintaining content and presence

## Notes
This milestone closes the loop on content lifecycle management, giving users full control over their presence on the platform. Users can iterate on their flyers, update information as circumstances change, extend durations, and remove outdated content. The implementation includes:

**Frontend Components:**
- Profile view page (own profile) with edit button
- Profile editing interface:
  - Image upload for profile picture
  - Text input for display name
  - Privacy settings toggle (email contact permission)
- Flyer editing interface:
  - Image upload/replacement (1-5 images)
  - Text fields (title, 2 info fields)
  - Category tag selector
  - Address input
  - Date pickers (publication/expiration)
  - Save button
- Delete confirmation dialog
- Visual distinction between active and expired flyers in profile
- Navigation from profile flyer list to edit screen
- Form validation and error handling

**Backend Components:**
- Profile update endpoint
- Profile picture upload and storage
- Flyer update endpoint with full field validation
- Image replacement handling (remove old, store new)
- Geocoding for address updates
- Flyer deletion endpoint (hard delete)
- Cascade deletion of related data (favorites, images)
- Authorization checks (users can only edit/delete their own content)
- Timestamp updates (updated_at fields)

**Data Lifecycle Considerations:**
- Hard delete implementation (permanent removal)
- Cascade deletion of:
  - Flyer images
  - User favorites of the flyer
  - References in following feeds
- No soft delete or archiving
- No recovery after deletion

**User Experience Considerations:**
- Clear indication of expired flyers in profile
- Confirmation dialog for destructive actions (delete)
- Auto-save or explicit save button (recommend explicit)
- Validation errors displayed inline
- Loading states during saves
- Success feedback after updates
- Preserved form state on navigation back

**Security and Authorization:**
- Backend verifies user owns profile/flyer before allowing edits
- Image upload validation (size, type, count)
- Text field length limits
- Rate limiting on updates to prevent abuse

This milestone maps to requirements in refined-product-analysis.md sections:
- Authentication & User Profiles (lines 168-180)
- Flyer Creation & Management - Editing, Expiration, Deletion (lines 187-199)
- User Management (lines 78-87)
- Settings & Account Management (lines 102-105)
