---
id: m01-e05-t05
epic: m01-e05
title: E2E Test - Complete Creator Profile Workflow (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Creator Profile Workflow (No Mocks)

## Objective
Validate complete creator profile viewing workflow end-to-end using real Django backend with real user data, real flyer filtering by creator, and real navigation state preservation without mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_profile_complete.yaml`
- [ ] Test steps:
  1. Start real Django backend with E2E test data (20+ users, 100+ flyers)
  2. Launch iOS app and navigate to feed
  3. Tap creator name on flyer card
  4. Assert: creator profile screen loads
  5. Verify all profile fields displayed correctly:
     - Creator username (matches database)
     - Profile picture (loaded from backend, or default if null)
     - Bio (displayed if present, or empty state if null)
     - Flyer count (accurate count of creator's flyers)
  6. Scroll creator's flyers feed
  7. Assert: feed shows only flyers by this creator (verify via backend query)
  8. Assert: flyers ordered correctly (most recent first)
  9. Test pagination: scroll to load more creator flyers
  10. Tap on a creator's flyer to view details
  11. Navigate back to creator profile
  12. Assert: scroll position preserved in creator's flyer feed
  13. Navigate back to main feed
  14. Assert: main feed scroll position preserved
  15. Test edge case: view profile of creator with 0 flyers
  16. Assert: empty state displayed ("No flyers yet")
- [ ] Real service validations:
  - Backend API returns user profile JSON with all fields
  - Creator flyers endpoint filters correctly by creator ID
  - Profile picture served from real storage
  - Flyer count matches actual database count for creator
  - Navigation preserves scroll positions (no data refetch unless necessary)
- [ ] Performance under realistic conditions:
  - Profile screen loads in <1 second
  - Creator flyers query completes in <500ms (even for prolific creators with 50+ flyers)
  - Smooth scrolling through creator's flyers (60fps)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete vertical slice: tap creator → load profile → view creator's flyers → navigate back
- All profile field accuracy (username, picture, bio, flyer count)
- Creator flyer filtering (only creator's flyers shown)
- Creator flyers ordering (most recent first)
- Pagination for prolific creators (50+ flyers)
- Navigation state preservation (scroll positions)
- Empty state (creator with 0 flyers)
- Missing profile picture (default avatar shown)
- Missing bio (empty state or placeholder)
- Deep navigation: main feed → profile → flyer detail → back → back

## Files to Modify/Create
- `maestro/flows/m01-e05/profile_complete_workflow.yaml`
- `maestro/flows/m01-e05/profile_empty_state.yaml`
- `maestro/flows/m01-e05/profile_navigation_preservation.yaml`
- `pockitflyer_backend/scripts/verify_creator_query.py` (debug script for creator filtering)

## Dependencies
- m01-e05-t01 (E2E test data infrastructure with diverse user profiles)
- m01-e04-t01 through m01-e04-t05 (all profile implementation)
- m01-e04-t06 (basic E2E profile flow, which this extends)

## Notes
**Critical: NO MOCKS**
- Real Django backend serving user profile and creator flyers APIs
- Real SQLite database with 20+ users, diverse flyer counts (0-50 per creator)
- Real profile pictures served from backend storage
- Real iOS app making actual HTTP requests
- Real navigation state preservation (scroll positions cached)

**Test Data Requirements**:
- Users with 0 flyers (empty state test)
- Users with 1-5 flyers (small creators)
- Users with 10-20 flyers (medium creators)
- Users with 30-50 flyers (prolific creators, pagination test)
- Users with profile pictures (70% of test users)
- Users without profile pictures (30% of test users, default avatar)
- Users with bios (60% of test users)
- Users without bios (40% of test users, empty state)

**Creator Flyers Query Validation**:
- Backend endpoint: `/api/users/{user_id}/flyers/`
- Assert: SQL query includes `WHERE creator_id = {user_id}`
- Assert: results ordered by `created_at DESC`
- Verify: result count matches flyer_count field on profile
- Log SQL query and verify via database inspection

**Navigation State Preservation**:
1. Main feed at scroll position Y=500px
2. Tap creator → navigate to profile
3. Profile loads, scroll creator's flyers to Y=300px
4. Tap flyer → navigate to detail
5. Navigate back to profile
6. Assert: profile scroll position Y=300px (preserved)
7. Navigate back to main feed
8. Assert: main feed scroll position Y=500px (preserved)

**Performance Validation**:
- Profile load time: <1 second from tap to full display
- Creator flyers query: <500ms even for 50+ flyers
- Profile picture load: <500ms (cached on second view)
- Scroll performance: 60fps through creator's flyers (no lag)

**Edge Cases**:
1. Creator with 0 flyers:
   - Empty state UI: "This creator hasn't posted any flyers yet"
   - No "Load more" button
2. Creator without profile picture:
   - Default avatar displayed (initials or generic icon)
3. Creator without bio:
   - Empty bio section (or placeholder text: "No bio available")
4. Deleted creator:
   - Profile shows "User not found" (if flyer still exists but creator deleted)

**Deep Navigation Test**:
1. Main feed → tap creator A → profile A
2. Profile A → tap creator A's flyer → flyer detail
3. Flyer detail → tap creator name (creator A again) → profile A (should use cached data, not refetch)
4. Navigate back → flyer detail (preserved)
5. Navigate back → profile A (scroll preserved)
6. Navigate back → main feed (scroll preserved)

**Accessibility Testing**:
- VoiceOver reads profile fields correctly
- Profile picture has alt text (creator username)
- Empty states announced clearly
- Navigation stack accessible via VoiceOver gestures
