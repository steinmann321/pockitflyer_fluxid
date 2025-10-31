---
id: m02-e03
title: E2E Milestone Validation (No Mocks)
milestone: m02
status: pending
tasks:
  - m02-e03-t01
  - m02-e03-t02
  - m02-e03-t03
  - m02-e03-t04
---

# Epic: E2E Milestone Validation (No Mocks)

## Overview
Validates the complete milestone m02 deliverable through end-to-end testing WITHOUT MOCKS. All tests run against real Django backend, real SQLite database, and real geocoding service (geopy) to verify the milestone works exactly as it will be shipped to users. This epic validates the complete user journey: register account → log in → create flyer with images and location → publish → verify appearance in discovery feed.

## Scope
- Real Django backend server running (all services operational)
- Real SQLite database with test data
- Real geopy geocoding service integration
- Complete user workflows from product requirements:
  - New user registration and automatic profile creation
  - User login and JWT token management
  - Authenticated flyer creation with all fields
  - Image upload and storage
  - Address geocoding to coordinates
  - Flyer publication and feed integration
- Performance validation under realistic conditions
- Error scenarios with actual service failures (geocoding failures, invalid images, etc.)

## Success Criteria
- [ ] Complete registration → login → create flyer → publish workflow succeeds [Test: real backend + database + geopy, no mocks, end-to-end user journey]
- [ ] Newly registered user has default profile created automatically [Test: verify database state, profile associations]
- [ ] JWT authentication works across all protected endpoints [Test: token generation, validation, expiration, refresh]
- [ ] Flyer creation with 1-5 images completes successfully [Test: single image, multiple images, file uploads, storage verification]
- [ ] Address geocoding converts to coordinates via real geopy service [Test: various addresses, geocoding success, coordinate accuracy]
- [ ] Published flyers immediately appear in m01 discovery feed [Test: query feed endpoint, verify new flyer presence, ranking position]
- [ ] Published flyers are visible to both anonymous and authenticated users [Test: unauthenticated feed access, authenticated feed access]
- [ ] Flyers respect ranking algorithm (recency, proximity) [Test: verify new flyer ranks appropriately, proximity affects order]
- [ ] System performs within defined targets under realistic load [Test: real network latency, multiple concurrent users, image uploads]
- [ ] Error handling works with actual service failures [Test: geocoding API failures, invalid image uploads, auth failures]
- [ ] Data persists correctly across the full stack [Test: verify database state after all operations, associations correct]
- [ ] All milestone m02 success criteria validated end-to-end [Test: reference milestone success criteria lines 13-32]

## Tasks
- E2E test environment setup (real Django backend, SQLite, geopy) (m02-e03-t01)
- User registration and login E2E validation (m02-e03-t02)
- Flyer creation and publishing E2E validation (m02-e03-t03)
- Feed integration and ranking E2E validation (m02-e03-t04)

## Dependencies
- Epic m02-e01 (authentication) must be complete
- Epic m02-e02 (flyer creation) must be complete
- Milestone m01 (discovery feed) must be complete
- Real Django backend deployment capability (local or test environment)
- Test data seeding capability
- Geopy service access (or test/sandbox accounts if using paid geocoding service)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks completed with real services (NO MOCKS)
- [ ] All milestone m02 success criteria validated end-to-end
- [ ] Performance meets targets in realistic conditions
- [ ] Error handling verified with actual failures
- [ ] Complete vertical slice works as shipped to users

## Notes
**CRITICAL: This epic uses NO MOCKS**

All services, databases, and external integrations must be real and functional. This is the final validation that the milestone delivers on its promise to users: "Users can create accounts and publish their own flyers."

**Setup Requirements:**
- Django backend server running locally or in test environment
- SQLite database with realistic test data (seed users, existing flyers from m01)
- Geopy geocoding service access (Nominatim is free, or use test accounts for Google/other)
- Flutter app connected to real backend (not mocked APIs)
- Ability to simulate realistic network conditions
- Ability to trigger actual error scenarios (network failures, invalid data)

**User Journeys to Validate:**

1. **New User Registration & Login**
   - User registers with email/password
   - Default profile created automatically
   - User logs in and receives JWT token
   - Header shows profile avatar (not "Login" button)
   - "Flyern" button appears

2. **Flyer Creation & Publishing**
   - User taps "Flyern" button
   - Creation interface loads
   - User uploads 1-5 images (test both single and multiple)
   - User fills all fields: title, info fields, categories, address, dates
   - Address sent to backend, geocoded via geopy to coordinates
   - User publishes flyer
   - Flyer immediately appears in discovery feed

3. **Feed Integration & Visibility**
   - Published flyer visible to anonymous users
   - Published flyer visible to authenticated users
   - Flyer respects ranking algorithm (new flyer ranks high)
   - Flyer location matches geocoded coordinates

**Error Scenarios to Validate:**
- Geocoding service failure (network timeout, invalid address)
- Invalid image upload (unsupported format, too large)
- Invalid credentials (login failure)
- Expired JWT token
- Missing required flyer fields
- Invalid date ranges (expiration before publication)

**What This Is NOT:**
- Not unit tests (those are in epic tasks)
- Not integration tests with mocks (those are in epic tasks)
- Not performance benchmarks (though performance is validated)
- Not load testing (though realistic load is used)

**What This IS:**
- Validation that milestone m02 works end-to-end as shipped
- Real user workflows through the complete stack (Flutter → Django → SQLite → geopy)
- Verification with actual services and data
- Final quality gate before milestone completion

**Performance Targets:**
- Registration/login: < 2s response time
- Flyer creation: < 5s for full workflow (including geocoding)
- Feed refresh: < 3s to show new flyer
- Image upload: < 10s for 5 images
