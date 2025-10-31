---
id: m03-e04-t06
epic: m03-e04
title: E2E Test - Filter Switching and Persistence
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test - Filter Switching and Persistence

## Objective
Validate filter switching behavior, UI transitions, content updates, and filter state persistence across app restarts and navigation flows.

## Acceptance Criteria
- [ ] Maestro flow: `m03_e04_filter_switching_persistence.yaml`
- [ ] Test steps:
  1. Launch app
  2. Login as power user with favorites and follows
  3. Navigate to feed (All filter active by default)
  4. Verify All filter button highlighted/selected
  5. Count flyers in feed (expect 100+ from test data)
  6. Tap Favorites filter button
  7. Verify smooth transition animation (fade/slide)
  8. Verify Favorites button highlighted, All button unhighlighted
  9. Verify feed updates to show only favorited flyers
  10. Count flyers (expect ~10 favorited flyers for power user)
  11. Scroll through Favorites feed
  12. Tap Following filter button
  13. Verify smooth transition animation
  14. Verify Following button highlighted, Favorites unhighlighted
  15. Verify feed updates to show only followed creators' flyers
  16. Count flyers (expect ~30 flyers from 5+ followed creators)
  17. Scroll through Following feed
  18. Tap All filter button
  19. Verify transition back to full feed
  20. Verify All button highlighted
  21. Tap Favorites filter
  22. Force quit app (while on Favorites filter)
  23. Relaunch app
  24. Verify app opens to Favorites filter (persisted state)
  25. Verify Favorites button highlighted
  26. Verify feed shows favorited flyers
  27. Navigate to flyer detail
  28. Return to feed
  29. Verify still on Favorites filter (state persists across navigation)
  30. Navigate to creator profile
  31. Return to feed
  32. Verify still on Favorites filter
  33. Pull-to-refresh on Favorites filter
  34. Verify filter remains active after refresh
  35. Tap Following filter
  36. Navigate to Settings screen
  37. Return to feed
  38. Verify Following filter still active
- [ ] UI validation:
  - Filter buttons have clear selected/unselected states
  - Transition animations smooth (no jank)
  - Feed content updates correctly for each filter
  - Loading indicators shown during filter switch (if applicable)
  - No blank screens or flashing during transitions
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Default filter state (All filter active on first launch)
- Filter selection visual state (highlighted button)
- Filter switching: All ↔ Favorites ↔ Following
- Transition animations between filters
- Feed content updates match selected filter
- Filter state persists across app restart
- Filter state persists across navigation (detail ↔ feed, profile ↔ feed)
- Filter state persists across pull-to-refresh
- Filter state persists across app backgrounding/foregrounding
- Correct flyer counts for each filter

## Files to Modify/Create
- `maestro/flows/m03-e04/filter_switching_workflow.yaml`
- `maestro/flows/m03-e04/filter_persistence_restart.yaml`
- `maestro/flows/m03-e04/filter_persistence_navigation.yaml`

## Dependencies
- m03-e04-t01 (M03 E2E test data infrastructure)
- m03-e03 (Feed filters epic - complete implementation)
- m02-e01 (User authentication)

## Notes
**Default Filter State**:
- On first app launch (fresh install), All filter should be active
- On subsequent launches, last active filter should be persisted
- If filter persistence fails (e.g., corrupted storage), default to All filter

**Filter Button UI States**:
- Selected state: Highlighted background, bold text, or underline
- Unselected state: Normal background, regular text
- Disabled state (anonymous users): Grayed out, reduced opacity
- Transition: Smooth animation when switching states

**Transition Animations**:
- Feed content fade-out/fade-in during filter switch
- Or feed content slide left/right during filter switch
- Duration: 200-300ms (fast enough to feel responsive)
- Easing: Ease-out or similar (smooth deceleration)

**Content Update Timing**:
- Optimistic UI: Filter button state changes immediately
- Feed update: Slight delay for API call (200-500ms acceptable)
- Loading indicator: Show if API call takes >500ms
- Error handling: If API fails, show error and revert to previous filter

**Persistence Strategy**:
- Store filter state in local storage (shared preferences / user defaults)
- Key: `lastActiveFilter` or similar
- Values: `all`, `favorites`, `following`
- Persistence scope: Per-user (different users can have different filter states)

**Navigation Flow Persistence**:
- Scenario: User on Favorites filter → taps flyer → views detail → returns to feed
- Expected: Feed still on Favorites filter (not reverted to All)
- Implementation: Filter state should be maintained in feed screen state, not reset on navigation

**App Lifecycle Persistence**:
- Backgrounding: User switches to another app, returns to PockitFlyer
- Expected: Feed still on same filter as when backgrounded
- Implementation: Filter state saved on app pause, restored on resume

**Pull-to-Refresh Behavior**:
- When on Favorites filter, pull-to-refresh should refresh Favorites feed
- When on Following filter, pull-to-refresh should refresh Following feed
- Filter state should NOT change during refresh
- After refresh completes, same filter should be active

**Error Scenarios**:
- API call for Favorites feed fails: Show error, keep filter button highlighted (don't revert)
- API call for Following feed fails: Show error, keep filter button highlighted
- User can tap All filter to see cached feed while debugging network issue

**Performance Assertions**:
- Filter switch responds within 200ms (button state change)
- Feed content updates within 2 seconds (API call + render)
- Transition animation runs at 60fps (no dropped frames)

**Accessibility**:
- Filter buttons announce selected state to screen reader
- Filter buttons have accessibility labels (e.g., "Show all flyers", "Show favorited flyers")
- Filter state announced when changed (e.g., "Now showing favorited flyers")

**Cleanup**:
- After test, optionally reset filter to All for next test run
- Or accept that each test run may start with different filter (test should handle both)
