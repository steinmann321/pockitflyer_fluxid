---
id: m02-e02
title: User Profile Management
milestone: m02
status: pending
---

# Epic: User Profile Management

## Overview
Users can view and edit their own profile, including profile picture and name. All profiles are publicly viewable by anyone (including anonymous users), displaying the user's profile picture, name, and published flyers. Authenticated users access their own profile by tapping the avatar in the header. Profile editing includes image upload with backend storage and validation. The profile system is intentionally simple - picture and name only, no bio, location, or detailed fields.

## Scope
- Public profile page displaying user info and published flyers
- Profile viewing accessible to all users (authenticated and anonymous)
- Profile avatar tap in header navigates to own profile (authenticated users)
- Profile edit screen with picture and name editing
- Image upload UI with camera/photo library selection
- Backend API endpoints for profile retrieval and update
- Image storage and serving on backend (Pillow for image processing)
- Profile data validation on backend
- Published flyers list on profile page
- Profile picture display in flyer cards (creator identity)
- Default avatar/placeholder for users without profile picture

## Success Criteria
- [ ] Authenticated users can tap header avatar to access own profile [Test: post-login navigation, verify correct profile loaded, back navigation]
- [ ] Profile page displays user's profile picture, name, and published flyers [Test: complete profile, empty profile, profile without picture, no published flyers]
- [ ] Any user (authenticated or anonymous) can view any profile [Test: anonymous access, authenticated access to others' profiles, direct URL access]
- [ ] Users can edit their profile picture [Test: camera capture, photo library selection, image crop/resize, large images, unsupported formats]
- [ ] Users can edit their profile name [Test: valid names, empty name, special characters, very long names, profanity filter if needed]
- [ ] Profile picture uploads are processed and stored correctly [Test: various formats (JPG, PNG, HEIC), file sizes, resolution, orientation]
- [ ] Backend validates and sanitizes profile data [Test: SQL injection attempts, XSS attempts, invalid data types, max length validation]
- [ ] Profile changes are reflected immediately across app [Test: edit name, verify feed updates, verify profile page updates]
- [ ] Published flyers list shows user's active flyers [Test: 0 flyers, 1 flyer, multiple flyers, expired flyers excluded, sorting by date]
- [ ] Default avatar is shown when user has no profile picture [Test: new users, deleted pictures, failed uploads]
- [ ] Profile picture appears correctly in flyer cards [Test: feed display, detail view, various image aspect ratios]
- [ ] Image upload and profile update complete within 5 seconds [Test: various network conditions, large images, concurrent updates]

## Dependencies
- Epic m02-e01 (requires authentication system)
- Builds on M01 flyer display (profile picture in flyer cards)
- External: Pillow library for image processing
- External: iOS UIImagePickerController for image selection

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Profile system is intentionally minimal: picture + name only
- All profiles are public - no private profiles or privacy controls on profile visibility
- Profile picture size limits: max 5MB upload, resized to 512x512px for storage
- Supported image formats: JPG, PNG, HEIC (iOS native)
- Name length: max 50 characters
- Published flyers list includes only active flyers (not expired)
- Backend stores original image and generates thumbnail/optimized versions
- Circuit breaker pattern applies to image processing (Pillow operations)
- Profile URLs should be shareable (consider deep linking in future)
- Default avatar should be a placeholder icon (not user initials - too complex)
- Profile edit screen accessible only to profile owner (not public edit)
- Consider profanity/content moderation for names (optional for MVP)
