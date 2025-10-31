---
id: m03-e04-t05
epic: m03-e04
title: E2E Test - Combined Engagement Workflows
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Combined Engagement Workflows

## Objective
Validate combined favorite and follow workflows including simultaneous use of both features, overlap scenarios (favoriting flyer from followed creator), and complex filter interactions (switching between All/Favorites/Following filters).

## Acceptance Criteria
- [ ] Maestro flow: `m03_e04_combined_engagement_workflow.yaml`
- [ ] Test steps:
  1. Launch app
  2. Login as power user (test user with existing favorites and follows)
  3. Navigate to feed (All filter active)
  4. Favorite 3 new flyers from creators user doesn't follow
  5. Favorite 2 flyers from creators user already follows (overlap scenario)
  6. Navigate to creator profile for non-followed creator
  7. Follow that creator
  8. Navigate back to feed
  9. Tap Favorites filter
  10. Verify 5 newly favorited flyers visible (3 non-followed + 2 followed)
  11. Verify all flyers show filled heart icon
  12. Tap Following filter
  13. Verify all flyers from followed creators visible
  14. Verify favorited flyers from followed creators show filled heart
  15. Verify non-favorited flyers from followed creators show empty heart
  16. Favorite a non-favorited flyer from followed creator (while on Following filter)
  17. Verify heart icon changes to filled immediately
  18. Tap Favorites filter
  19. Verify newly favorited flyer now appears in Favorites
  20. Navigate to flyer detail for overlapped flyer (favorited + from followed creator)
  21. Verify both favorite button (filled) and creator profile link available
  22. Unfollow creator from profile
  23. Return to Following filter
  24. Verify unfollowed creator's flyers disappeared
  25. Tap Favorites filter
  26. Verify favorited flyer from unfollowed creator still visible (favorites independent of follows)
  27. Unfavorite that flyer
  28. Verify flyer disappears from Favorites filter
  29. Tap All filter
  30. Verify flyer still visible (back in general feed)
  31. Verify empty heart icon (unfavorited)
  32. Force quit and relaunch app
  33. Verify all engagement states persisted (favorites, follows, filter selection)
- [ ] Backend validation:
  - Favorites and follows are independent (separate tables)
  - Favoriting flyer from followed creator creates favorite, doesn't affect follow
  - Unfollowing creator doesn't delete favorites of their flyers
  - Unfavoriting flyer from followed creator doesn't affect follow
  - All relationships persist correctly in database
- [ ] UI validation:
  - Flyers in Following filter show correct favorite state (filled/empty heart)
  - Flyers in Favorites filter show all favorites regardless of creator follow status
  - All filter shows all flyers with correct engagement states
  - No visual glitches when switching filters rapidly
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Simultaneous use of favorites and follows
- Favoriting flyer from followed creator (overlap scenario)
- Favoriting flyer from non-followed creator
- Following creator of favorited flyer (reverse overlap)
- Unfollowing creator while favorite of their flyer exists (independence)
- Unfavoriting flyer from followed creator (independence)
- Filter switching: All → Favorites → Following → All
- State synchronization across all filters
- Cross-session persistence of all engagement states
- Correct icon states (favorite + follow) on same flyer

## Files to Modify/Create
- `maestro/flows/m03-e04/combined_engagement_workflow.yaml`
- `maestro/flows/m03-e04/combined_overlap_scenarios.yaml`
- `maestro/flows/m03-e04/combined_independence_validation.yaml`

## Dependencies
- m03-e04-t01 (M03 E2E test data infrastructure)
- m03-e04-t03 (Favorite workflow integration)
- m03-e04-t04 (Follow workflow integration)
- m03-e03 (Feed filters epic)

## Notes
**Power User Test Data**:
- Use `test_user_power@pockitflyer.test` from M03 E2E data
- User should have:
  - 10+ existing favorites
  - 5+ existing follows
  - Mix of overlapping and non-overlapping favorites/follows

**Overlap Scenarios**:
1. **Favorite first, follow later**: User favorites flyer, then follows creator
2. **Follow first, favorite later**: User follows creator, then favorites their flyer
3. **Both exist**: Flyer from followed creator that user also favorited
4. **Neither exist**: Flyer from non-followed creator that user hasn't favorited

**Independence Validation**:
- Unfollowing creator should NOT delete favorites of their flyers
- Unfavoriting flyer should NOT unfollow creator
- Following filter shows all followed creators' flyers (favorited or not)
- Favorites filter shows all favorited flyers (from followed creators or not)

**Filter State Consistency**:
- When on Favorites filter, all flyers should have filled hearts
- When on Following filter, some flyers have filled hearts (favorited), some empty (not favorited)
- When on All filter, mix of filled/empty hearts based on individual favorite status

**Complex Interaction Flow**:
1. Start on All filter
2. Favorite flyer X
3. Switch to Favorites filter
4. Verify flyer X visible
5. Navigate to creator profile from flyer X
6. Follow creator
7. Switch to Following filter
8. Verify flyer X visible (now in both filters)
9. Verify flyer X has filled heart
10. Unfollow creator
11. Verify flyer X disappears from Following filter
12. Switch to Favorites filter
13. Verify flyer X still visible (favorite persists)

**Performance Validation**:
- Filter switching should be instant (<500ms)
- No lag when switching between filters with large datasets
- Optimistic updates should work correctly on any filter

**Edge Cases**:
- Rapidly switching filters (All → Favorites → Following → All in 2 seconds)
- Favoriting/unfavoriting while on different filters
- Following/unfollowing while on different filters
- Verifying correct filter remains active after app restart

**State Persistence**:
- After app restart, verify:
  - All favorites persisted
  - All follows persisted
  - Last active filter persisted (e.g., if on Favorites when quit, reopen to Favorites)
  - All flyers in filtered feeds show correct engagement states

**Cleanup**:
- After test, optionally reset power user to known state
- Or create fresh power user for each test run
- Ensure test data doesn't accumulate over multiple runs
