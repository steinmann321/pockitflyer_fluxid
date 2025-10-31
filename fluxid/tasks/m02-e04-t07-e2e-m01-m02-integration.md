---
id: m02-e04-t07
epic: m02-e04
title: E2E Test - M01/M02 Integration Validation (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - M01/M02 Integration Validation (No Mocks)

## Objective
Validate seamless integration between M01 (Anonymous Discovery) and M02 (User Authentication and Profile Management) features end-to-end. Tests ensure authenticated users can access all M01 features, creator profiles display correctly with M02 profile data, and authentication layer doesn't break existing anonymous discovery workflows.

## Acceptance Criteria
- [ ] Maestro flow: `m02_e04_m01_m02_integration_complete.yaml`
- [ ] Integration test steps:
  1. Start real Django backend
  2. Seed M01 and M02 E2E test data (100+ flyers, 30+ users with profiles)
  3. Launch iOS app (fresh install)
  4. **Anonymous browsing (M01 features)**:
     a. Assert feed loads without authentication (M01 anonymous discovery)
     b. Assert flyer cards display creator names and profile pictures (M02 data)
     c. Tap on flyer created by test_user_001
     d. Assert flyer detail shows creator profile picture (M02 data)
     e. Tap creator name
     f. Assert creator profile screen loads (M01 creator viewing + M02 profile data)
     g. Assert profile displays: name, bio, profile picture, flyer count
     h. Assert "Edit Profile" button NOT visible (not owner, not authenticated)
  5. **Authenticated browsing (M01 + M02 integration)**:
     a. Navigate to feed
     b. Tap "Login" button in header
     c. Login as test_user_001
     d. Assert header shows profile avatar (M02 authenticated state)
     e. Assert feed still loads (M01 features accessible when authenticated)
     f. Tap on flyer created by test_user_001 (own flyer)
     g. Assert flyer detail shows own profile picture
     h. Tap creator name (own profile)
     i. Assert navigates to own profile screen (M02)
     j. Assert "Edit Profile" button IS visible (owner)
  6. **Filter and search with authentication**:
     a. Apply category filter: "Events" (M01 feature)
     b. Assert filtered results display creator profiles correctly (M02 data)
     c. Apply "Near Me" filter (M01 feature)
     d. Assert filtered results still show profile pictures
     e. Search for keyword: "test" (M01 feature)
     f. Assert search results show creator profiles
  7. **Profile picture visibility across M01 features**:
     a. Assert feed flyer cards show profile pictures for all creators
     b. Assert flyer detail screens show profile pictures
     c. Assert creator profile screens show profile pictures
     d. Navigate to own profile (via header avatar)
     e. Edit profile picture (upload new image)
     f. Navigate back to feed
     g. Find own flyer in feed
     h. Assert flyer card shows updated profile picture (immediate visibility)
  8. **Anonymous creator profile viewing (M01 feature with M02 data)**:
     a. Logout
     b. Navigate to feed (anonymous)
     c. Tap on flyer created by test_user_010
     d. Tap creator name
     e. Assert creator profile loads with M02 data (name, bio, picture)
     f. Assert "Edit Profile" button NOT visible (not authenticated)
     g. Assert flyer list shows all test_user_010's flyers (M01 feature)
  9. Verify backend integration:
     - Feed API includes creator profile data (name, picture URL)
     - Flyer detail API includes creator profile data
     - Creator profile API returns all flyers by creator (M01 feature)
     - Authentication doesn't break M01 API endpoints
  10. Cleanup: stop backend
- [ ] Real service validations:
  - M01 feed API enhanced with M02 profile data (creator name, profile picture URL)
  - M01 flyer detail API enhanced with M02 profile data
  - M01 creator profile API integrated with M02 profile retrieval
  - Anonymous users can access all M01 features without authentication
  - Authenticated users can access all M01 features
  - Authentication state doesn't affect M01 API responses (same data for authenticated and anonymous)
  - Profile picture updates immediately visible in M01 feed (no caching issues)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- M01 anonymous browsing works with M02 profile data integration
- M01 authenticated browsing works (all features accessible)
- Feed API returns creator profile data (name, picture URL)
- Flyer detail API returns creator profile data
- Creator profile viewing works for anonymous users
- Creator profile viewing works for authenticated users (own and others)
- Profile picture visibility in feed flyer cards
- Profile picture visibility in flyer detail screens
- Profile picture visibility in creator profile screens
- Profile picture updates reflected immediately in M01 views
- M01 filtering and search work with authentication
- M01 filtering and search work without authentication
- "Edit Profile" button visibility: Owner authenticated only
- No M01 feature regressions due to M02 authentication layer

## Files to Modify/Create
- `maestro/flows/m02-e04/m01_m02_integration_complete_workflow.yaml`
- `maestro/flows/m02-e04/m01_m02_anonymous_creator_viewing.yaml`
- `maestro/flows/m02-e04/m01_m02_authenticated_browsing.yaml`
- `maestro/flows/m02-e04/m01_m02_profile_picture_visibility.yaml`
- `maestro/flows/m02-e04/m01_m02_filter_search_integration.yaml`
- `pockitflyer_backend/scripts/verify_feed_api_includes_profiles.py` (helper script to verify API responses)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure)
- m02-e04-t03 (Login workflow)
- m02-e04-t04 (Profile viewing and editing)
- m01-e05-t02 (M01 browse workflow E2E test)
- m01-e05-t03 (M01 filter and search E2E test)
- m01-e05-t04 (M01 flyer detail and creator viewing E2E test)
- m02-e02-t09 (Frontend flyer card profile picture integration)
- m02-e02-t10 (Backend feed API creator picture integration)

## Notes
**Critical: NO MOCKS**
- Real Django server running on localhost
- Real SQLite database with M01 and M02 test data
- Real iOS app with M01 and M02 features integrated
- Real authentication layer (JWT tokens)
- Real profile pictures served from backend

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**Backend API Integration Points**:

1. **Feed API** (`GET /api/flyers/feed/`):
   - Before M02: `{id, title, description, image_urls, location, distance, category, created_at, creator_id}`
   - After M02: Add `creator_name` and `creator_profile_picture_url`
   ```json
   {
     "id": 1,
     "creator_id": 5,
     "creator_name": "Test User One",
     "creator_profile_picture_url": "/media/profile_pictures/user_5_abc123.jpg",
     ...
   }
   ```

2. **Flyer Detail API** (`GET /api/flyers/{id}/`):
   - Add same creator profile fields as feed API

3. **Creator Profile API** (`GET /api/users/{id}/profile/`):
   - Returns M02 profile data + M01 creator's flyers
   ```json
   {
     "user_id": 5,
     "display_name": "Test User One",
     "bio": "Test bio",
     "profile_picture_url": "/media/profile_pictures/user_5_abc123.jpg",
     "flyers": [...],  // All flyers by this creator (M01 feature)
     "flyer_count": 12
   }
   ```

**Profile Picture Display Strategy**:
- Feed flyer cards: Small thumbnail (50x50px)
- Flyer detail: Medium thumbnail (100x100px)
- Creator profile: Large image (200x200px)
- Fallback: Placeholder image if no profile picture uploaded

**Authentication vs Anonymous Access**:
- **Anonymous users**: Can browse feed, view flyer details, view creator profiles (read-only)
- **Authenticated users**: Same as anonymous + can edit own profile, access settings, logout
- **Authorization**: Only profile owner can edit profile (enforced by "Edit Profile" button visibility and backend API)

**Profile Picture Update Propagation**:
1. User edits profile picture (M02 feature)
2. Backend stores new image, updates profile.profile_picture field
3. User navigates to feed
4. Feed API includes updated profile_picture_url in response
5. Flyer cards display updated profile picture
6. No caching issues (fresh data on each API call)

**"Edit Profile" Button Visibility Logic**:
- Button visible: User authenticated AND viewing own profile
- Button hidden: User not authenticated OR viewing other user's profile
- Frontend logic: `if (isAuthenticated && currentUser.id == profileUser.id) { show button }`

**M01 Feature Regression Testing**:
Ensure M02 authentication doesn't break M01 features:
- [ ] Feed browsing (anonymous and authenticated)
- [ ] Category filtering (Events, Nightlife, Service)
- [ ] "Near Me" radius filtering (5km)
- [ ] Free-text search (title and description)
- [ ] Flyer detail viewing (image carousel, location, dates)
- [ ] iOS Maps integration (location deep link)
- [ ] Creator profile viewing (flyer history)
- [ ] Pagination (scrolling loads more flyers)
- [ ] Pull-to-refresh (updates feed)

**Performance Expectations**:
- Feed load with profile pictures: <2 seconds
- Flyer detail with profile picture: <1 second
- Creator profile with flyers: <2 seconds
- Profile picture thumbnail download: <500ms per image
- No performance degradation compared to M01-only baseline

**Error Handling**:
- Missing profile picture → show placeholder image (don't break UI)
- Profile picture URL invalid → show placeholder image (graceful degradation)
- Creator profile not found → show error message (rare edge case)
- Authentication token expired → auto-logout, redirect to login (M02 feature)

**Edge Cases to Test** (separate Maestro flows):
1. Flyer created by user with no profile picture → placeholder shown
2. Flyer created by user with no bio → bio section hidden or empty
3. Anonymous user taps "Edit Profile" → button not visible (test absence)
4. Authenticated user views other user's profile → "Edit Profile" not visible
5. Profile picture upload during M01 browsing → immediate visibility in feed
6. Logout during M01 browsing → feed still accessible (anonymous)

**Success Indicators**:
- M01 feed accessible anonymously ✅
- M01 feed accessible when authenticated ✅
- Feed flyer cards show creator profile pictures ✅
- Flyer detail shows creator profile picture ✅
- Creator profile shows M02 data (name, bio, picture) ✅
- Creator profile shows M01 data (flyer list) ✅
- "Edit Profile" button visible only for owner ✅
- Profile picture updates visible immediately ✅
- M01 filtering and search work with authentication ✅
- No M01 feature regressions ✅
