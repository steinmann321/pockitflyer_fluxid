---
id: m04-e04
title: E2E Milestone Validation (No Mocks)
milestone: m04
status: pending
tasks:
  - m04-e04-t01
  - m04-e04-t02
  - m04-e04-t03
  - m04-e04-t04
---

# Epic: E2E Milestone Validation (No Mocks)

## Overview
Validates the complete milestone m04 deliverable through end-to-end testing WITHOUT MOCKS. All tests run against real Django backend, real SQLite database, and real geocoding service to verify that users can manage their profiles and edit flyers exactly as shipped to production.

## Scope
- Real Django backend server running (all services operational)
- Real SQLite database with test data (users, flyers, favorites)
- Real geocoding service integration (geopy with actual API calls)
- Complete user workflows for profile and flyer management
- Performance validation under realistic conditions
- Error scenarios with actual service failures

## Success Criteria
- [ ] Complete profile management workflow succeeds end-to-end [Test: real backend + database, user navigates to profile, edits picture/name/privacy, changes persist, profile view refreshes, no mocks]
- [ ] Complete flyer editing workflow succeeds end-to-end [Test: real backend + database + geocoding service, user edits all fields including address, geocoding converts address, images replaced, changes appear in feed immediately, no mocks]
- [ ] Flyer reactivation workflow succeeds end-to-end [Test: real backend + database, expired flyer date extended, flyer returns to active status, appears in feed again, no mocks]
- [ ] Flyer deletion workflow succeeds end-to-end [Test: real backend + database, confirmation dialog shown, flyer deleted with cascade (images, favorites, feed references), removed from all views, no mocks]
- [ ] Authorization enforced across all operations [Test: real backend, attempt unauthorized edits/deletions rejected, only own content editable, proper error responses]
- [ ] Error handling works with actual service failures [Test: real geocoding timeouts, real image upload failures, real database constraint violations, user sees clear error messages]
- [ ] System performs within defined targets under realistic load [Test: real network latency, real database queries, profile/edit operations complete within acceptable time]
- [ ] All milestone success criteria validated end-to-end [Test: verify against m04 success criteria in milestone file, all workflows complete]

## Tasks
- E2E test environment setup with real services (m04-e04-t01)
- Profile management E2E validation (m04-e04-t02)
- Flyer editing and lifecycle E2E validation (m04-e04-t03)
- Authorization and error handling E2E validation (m04-e04-t04)

## Dependencies
- m04-e01 (profile management) - MUST BE COMPLETE
- m04-e02 (flyer editing) - MUST BE COMPLETE
- m04-e03 (flyer deletion and lifecycle) - MUST BE COMPLETE
- Real backend deployment capability (Django dev server or test environment)
- Test data seeding capability (users, flyers, favorites)
- Geocoding service access (geopy with real API credentials or test account)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks completed with real services (NO MOCKS)
- [ ] All milestone success criteria validated end-to-end
- [ ] Performance meets targets in realistic conditions
- [ ] Error handling verified with actual failures
- [ ] Complete vertical slice works as shipped to users

## Notes
**CRITICAL: This epic uses NO MOCKS**

All services, databases, and external integrations must be real and functional. This is the final validation that milestone m04 delivers on its promise to users.

**Setup Requirements:**
- Django backend server running (manage.py runserver or test deployment)
- SQLite database with realistic test data:
  - Multiple user accounts
  - Active and expired flyers
  - Favorite records
  - Profile pictures
- Geocoding service access:
  - Real geopy configuration
  - API credentials for geocoding provider (Nominatim or similar)
  - Rate limiting considerations for test runs
- File storage configured (profile pictures, flyer images)
- Ability to simulate realistic network conditions
- Ability to trigger actual error scenarios (geocoding failures, storage failures)

**User Workflows to Validate:**

1. **Profile Management Workflow:**
   - User logs in (from m02)
   - User taps header avatar to navigate to profile
   - Profile displays picture, name, flyer list
   - User taps "Edit Profile"
   - User uploads new profile picture
   - User changes display name
   - User toggles privacy settings
   - User saves changes
   - Verify: profile view refreshes, changes visible, header avatar updates

2. **Flyer Editing Workflow:**
   - User navigates to own profile
   - User taps one of their flyers
   - Edit interface loads with current data
   - User updates: images, title, description, category, address, dates
   - Address change triggers geocoding (real API call)
   - User saves changes
   - Verify: feed updates immediately, profile reflects changes, geocoding succeeded

3. **Flyer Reactivation Workflow:**
   - User navigates to expired flyer in profile
   - User edits expiration date to future
   - User saves changes
   - Verify: flyer status changes to active, appears in feed again

4. **Flyer Deletion Workflow:**
   - User navigates to flyer (active or expired)
   - User initiates delete action
   - Confirmation dialog shown
   - User confirms deletion
   - Verify: flyer removed from profile, removed from feed, images deleted from storage, favorite records deleted

5. **Authorization and Error Handling:**
   - Attempt to edit/delete another user's content (should fail)
   - Simulate geocoding service failure (should handle gracefully)
   - Simulate image upload failure (should show error, rollback)
   - Concurrent edits (should handle optimistically or prevent)

**What This Is NOT:**
- Not unit tests (those are in regular tasks)
- Not integration tests with mocks (those are in regular tasks)
- Not performance benchmarks (though performance is validated)
- Not load testing (though realistic load is used)

**What This IS:**
- Validation that milestone m04 works end-to-end as shipped
- Real user workflows through the complete stack
- Verification with actual services and data
- Final quality gate before milestone completion

**Performance Targets:**
- Profile view loads within 2 seconds
- Profile save completes within 3 seconds
- Flyer edit save completes within 4 seconds (includes geocoding)
- Flyer deletion completes within 2 seconds
- All operations responsive under realistic network latency

**Test Data Setup:**
- Seed database with at least:
  - 5 user accounts
  - 20 flyers (mix of active and expired)
  - 10 favorite records
  - Profile pictures for all users
  - Various addresses for geocoding tests
- Use realistic data (actual addresses, valid images, proper dates)
- Include edge cases (expired flyers, flyers with max images, etc.)

**Geocoding Service Considerations:**
- Use actual geocoding provider (Nominatim or similar)
- Respect rate limits during testing
- Include tests for geocoding failures (invalid addresses, service timeouts)
- Verify coordinates stored correctly after geocoding
