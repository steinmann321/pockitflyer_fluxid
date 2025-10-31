---
id: m03-e04
title: E2E Milestone Validation (No Mocks)
milestone: m03
status: pending
tasks:
  - m03-e04-t01
  - m03-e04-t02
  - m03-e04-t03
  - m03-e04-t04
  - m03-e04-t05
---

# Epic: E2E Milestone Validation (No Mocks)

## Overview
Validates the complete milestone m03 deliverable through end-to-end testing WITHOUT MOCKS. All tests run against real backend, real database, and real external services to verify users can save favorites, follow creators, and filter feeds exactly as the feature will be shipped.

## Scope
- Real Django backend server running
- Real SQLite database with test data
- Real authentication system (JWT tokens)
- Complete user workflows for favorites and following
- Complete user workflows for relationship filtering
- Performance validation under realistic conditions
- Error scenarios with actual service failures
- Auth gate workflows for anonymous users

## Success Criteria
- [ ] Complete favorite workflow works end-to-end [Test: authenticate, browse feed, favorite flyer, verify database persistence, unfavorite, verify removal]
- [ ] Complete following workflow works end-to-end [Test: authenticate, browse feed, follow creator, verify database persistence, unfollow, verify removal]
- [ ] Favorites filter shows correct results [Test: favorite multiple flyers, apply filter, verify only favorited flyers shown, check database queries]
- [ ] Following filter shows correct results [Test: follow multiple creators, apply filter, verify only followed creators' flyers shown, check database queries]
- [ ] Filter combination works correctly [Test: apply "Favorites + Events" filter, verify results match both criteria, check query logic]
- [ ] Anonymous user auth gates work [Test: tap favorite/follow as anonymous, verify login prompt, complete login flow, verify action completes]
- [ ] Optimistic UI updates and rollbacks work [Test: trigger network failures during favorite/follow, verify UI rollback, verify database consistency]
- [ ] Relationship state persists across sessions [Test: favorite/follow, close app, reopen, verify state preserved]
- [ ] Performance meets targets under realistic load [Test: feed with 100+ flyers, 50+ favorites, 20+ follows, measure filter response times]
- [ ] All milestone success criteria validated end-to-end [Test: reference m03 success criteria, verify each point]

## Tasks
- E2E test environment setup with real backend (m03-e04-t01)
- Favorite/unfavorite user journey validation (m03-e04-t02)
- Follow/unfollow user journey validation (m03-e04-t03)
- Relationship filtering user journey validation (m03-e04-t04)
- Error handling and edge cases validation (m03-e04-t05)

## Dependencies
- M03-E01 (Flyer favorites) - Must be complete
- M03-E02 (Creator following) - Must be complete
- M03-E03 (Relationship filtering) - Must be complete
- Real backend deployment capability (local Django server)
- Test data seeding scripts
- Real authentication tokens (M02)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks completed with real services (NO MOCKS)
- [ ] All milestone success criteria validated end-to-end
- [ ] Performance meets targets in realistic conditions
- [ ] Error handling verified with actual failures
- [ ] Complete vertical slice works as shipped to users

## Notes
**CRITICAL: This epic uses NO MOCKS**

All backend services, database operations, and authentication flows must be real and functional. This is the final validation that m03 delivers on its promise: authenticated users can favorite flyers, follow creators, and filter feeds to build a personalized, curated experience.

**Setup Requirements:**
- Django backend running locally (`python manage.py runserver`)
- SQLite database with realistic test data (multiple users, flyers, categories)
- JWT authentication working with real token generation
- Test user accounts with varying relationship states (some favorites, some follows, some none)
- Ability to simulate network failures (airplane mode, backend shutdown)
- Flutter app running on simulator/device connected to local backend

**User Journeys to Validate:**

1. **Authenticated Favorite Journey:**
   - Login as test user
   - Browse feed
   - Tap favorite on flyer
   - Verify visual state change
   - Verify database has favorite record
   - Close and reopen app
   - Verify favorite state persists
   - Unfavorite flyer
   - Verify visual state change
   - Verify database removes favorite record

2. **Authenticated Following Journey:**
   - Login as test user
   - Browse feed
   - Tap follow on creator
   - Verify visual state change
   - Verify database has following record
   - Close and reopen app
   - Verify following state persists
   - Unfollow creator
   - Verify visual state change
   - Verify database removes following record

3. **Relationship Filtering Journey:**
   - Login as test user with existing favorites and follows
   - Tap "Favorites" filter
   - Verify feed shows only favorited flyers
   - Verify database query uses JOIN on favorites table
   - Tap "Following" filter
   - Verify feed shows only followed creators' flyers
   - Verify database query uses JOIN on following table
   - Combine with category filter (e.g., "Following + Events")
   - Verify feed shows only followed creators' event flyers
   - Verify query uses both JOINs and WHERE clauses

4. **Anonymous User Auth Gate Journey:**
   - Browse feed as anonymous user
   - Tap favorite button
   - Verify login prompt appears with value explanation
   - Complete login flow
   - Verify returned to same flyer
   - Verify favorite action completes automatically
   - Same flow for follow button

5. **Error Handling Journey:**
   - Enable airplane mode
   - Attempt to favorite flyer
   - Verify optimistic UI shows favorited state
   - Verify error message appears
   - Verify UI rolls back to unfavorited state
   - Re-enable network
   - Favorite again
   - Verify success

**What This Is NOT:**
- Not unit tests (those are in e01, e02, e03 tasks)
- Not integration tests with mocks (those are in feature epic tasks)
- Not performance benchmarks (though performance is validated)

**What This IS:**
- Validation that m03 works end-to-end as shipped
- Real user workflows through the complete stack
- Verification with actual backend, database, and auth
- Final quality gate before milestone completion
