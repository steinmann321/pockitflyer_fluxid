---
id: m03-e04-t04
epic: m03-e04
title: E2E Test - Complete Follow Workflow Integration
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Follow Workflow Integration

## Objective
Validate complete end-to-end follow workflow including user login, following multiple creators, filtering by following, unfollowing, and verifying followed creators' flyers appear in filtered feed with real backend integration.

## Acceptance Criteria
- [ ] Maestro flow: `m03_e04_follow_complete_workflow.yaml`
- [ ] Test steps:
  1. Launch app
  2. Login as existing test user (active user with 0 follows)
  3. Navigate to feed
  4. Tap on flyer card to view flyer detail
  5. Tap creator profile picture to navigate to creator profile
  6. Verify follow button visible and enabled
  7. Tap follow button
  8. Verify button changes to "Following" state immediately (optimistic update)
  9. Wait for backend sync (2 seconds)
  10. Return to feed
  11. Navigate to second flyer from different creator
  12. Navigate to creator profile
  13. Tap follow button (second creator)
  14. Return to feed
  15. Navigate to third flyer from different creator
  16. Navigate to creator profile
  17. Tap follow button (third creator)
  18. Return to feed
  19. Tap "Following" filter button
  20. Verify filter activates (visual indication)
  21. Verify feed shows only flyers from 3 followed creators
  22. Scroll through entire following feed
  23. Count flyers (should be sum of all flyers from 3 creators)
  24. Navigate to one creator profile from feed
  25. Tap unfollow button
  26. Return to feed (still on Following filter)
  27. Verify flyers from unfollowed creator disappear immediately
  28. Verify flyers from 2 remaining followed creators still visible
  29. Tap "All" filter to return to full feed
  30. Force quit app
  31. Relaunch app
  32. Navigate to Following filter
  33. Verify 2 followed creators' flyers visible (unfollowed creator excluded)
  34. Pull-to-refresh
  35. Verify following feed updates from backend
- [ ] Backend validation:
  - 3 follow records created in database
  - 1 follow record deleted (unfollow action)
  - Final state: 2 follows persisted in database
  - All follows linked to correct user and creators
  - Following feed API returns only followed creators' flyers
- [ ] Performance validation:
  - Follow action responds within 200ms (optimistic update)
  - Backend sync completes within 2 seconds
  - Following filter loads within 2 seconds
  - Pull-to-refresh completes within 2 seconds
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Login as existing authenticated user
- Multiple follows across different creators
- Navigation: feed → flyer detail → creator profile → follow → back to feed
- Optimistic update UI (immediate button state change)
- Backend persistence (follow records in database)
- Following filter shows only followed creators' flyers
- Correct flyer count (sum of flyers from all followed creators)
- Unfollow action (immediate UI update, flyers disappear)
- Cross-session persistence (app restart)
- Pull-to-refresh on following feed
- Self-follow prevention (if creator views own profile)

## Files to Modify/Create
- `maestro/flows/m03-e04/follow_complete_workflow.yaml`
- `maestro/flows/m03-e04/follow_login_flow.yaml`
- `maestro/flows/m03-e04/follow_multiple_creators.yaml`

## Dependencies
- m03-e04-t01 (M03 E2E test data infrastructure)
- m03-e04-t02 (Anonymous engagement workflow)
- m03-e02 (Complete Follow Creators epic)
- m03-e03 (Feed filters epic)
- m02-e01 (User login)
- m01-e04 (Creator profiles)

## Notes
**Test User Selection**:
- Use existing test user from M02 E2E data: `test_user_active@pockitflyer.test`
- Ensure user has 0 follows at start of test (clean state)
- User should have authentication token (login flow)

**Creator Selection**:
- Select 3 creators from M02 test data with different flyer counts:
  - Creator A: 5+ flyers
  - Creator B: 2-3 flyers
  - Creator C: 1 flyer
- Verifies following feed aggregates all flyers from all followed creators

**Navigation Flow**:
- Test validates complete navigation: feed → detail → profile → follow → back
- Verifies follow state persists across navigation
- Verifies creator profile updates after follow (button state change)

**Following Filter Validation**:
- Count expected flyers: Creator A (5) + Creator B (3) + Creator C (1) = 9 flyers
- After unfollowing Creator A: Creator B (3) + Creator C (1) = 4 flyers
- Verify actual count matches expected count

**Optimistic Update Validation**:
- Follow button text changes from "Follow" to "Following" immediately
- Button style changes (e.g., outline → filled)
- No waiting for backend response before UI update

**Backend Persistence Validation**:
- Use Django management command or API call to verify database state
- Query follows table for user: expect 3 follows initially, 2 after unfollow
- Verify creator IDs match followed creators in UI

**Cross-Session Persistence**:
- Force quit app (simulate user closing app)
- Relaunch app (cold start)
- Verify authentication token persisted (no login required)
- Verify follows state persisted (following filter shows 2 creators' flyers)

**Self-Follow Prevention**:
- If test user has created flyers, navigate to own creator profile
- Verify follow button hidden or disabled (cannot follow self)
- This validates m03-e02-t10 (self-follow prevention)

**Pull-to-Refresh**:
- While on Following filter, pull down to refresh
- Verify loading indicator appears
- Verify feed updates from backend
- If followed creator publishes new flyer, verify it appears in feed

**Performance Assertions**:
- Use Maestro `waitForAnimationToEnd` with timeout assertions
- Measure time from button tap to state change (<200ms)
- Measure time from filter tap to feed load (<2s)
- Fail test if performance thresholds not met

**Cleanup**:
- After test completion, unfollow all creators (return to clean state)
- Ensure test user has 0 follows for next test run
- Use `cleanup_m03_e2e_data` or manual API calls
