---
id: m01-e05-t06
epic: m01-e05
title: E2E Test - Cross-Workflow Integration (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Cross-Workflow Integration (No Mocks)

## Objective
Validate that all M01 workflows integrate correctly when used in combination, testing state preservation, data consistency, and navigation across browse, filter, search, details, and profile workflows without mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_cross_workflow_integration.yaml`
- [ ] Complex integration test scenario:
  1. Start real Django backend with E2E test data
  2. Launch iOS app
  3. **Browse workflow**: View feed, scroll to position Y=800px
  4. **Filter workflow**: Apply category filter (Events) + Near Me (5km)
  5. Assert: feed updates with filtered results
  6. **Search workflow**: Enter search term "concert"
  7. Assert: feed shows Events + Near Me + "concert" (complex AND/OR logic)
  8. **Profile workflow**: Tap creator on filtered flyer
  9. Assert: profile loads, shows all creator's flyers (filter NOT applied to profile view)
  10. Tap creator's flyer (different from original filtered flyer)
  11. **Details workflow**: View flyer detail, swipe images
  12. Navigate back to profile
  13. Assert: profile scroll position preserved
  14. Navigate back to main feed
  15. Assert: filters still active (Events + Near Me + "concert")
  16. Assert: feed scroll position preserved (Y=800px or near filtered item)
  17. **Clear filters**: Remove all filters
  18. Assert: feed returns to unfiltered state
  19. Assert: scroll position resets to top (expected behavior)
  20. **Pull-to-refresh**: Add new flyer via backend during test
  21. Pull to refresh
  22. Assert: new flyer appears in feed
- [ ] State preservation validations:
  - Filter state maintained across navigation to profile/detail and back
  - Search term preserved across navigation
  - Scroll positions preserved for each screen independently
  - Backend query state consistent (no stale data)
- [ ] Data consistency validations:
  - Profile view shows all creator's flyers (ignores main feed filters)
  - Detail view shows complete flyer data (not filtered subset)
  - Pull-to-refresh updates all data sources consistently
  - No race conditions between filter updates and navigation
- [ ] Performance under integration:
  - Complex filter + search query: <500ms
  - Navigation transitions smooth: <300ms per transition
  - State restoration instant: <100ms
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete workflow integration: browse → filter → search → profile → detail → back → back → clear
- Filter state preservation across multi-level navigation
- Search term persistence
- Scroll position preservation for each unique screen
- Data consistency: profile view independent of main feed filters
- Pull-to-refresh updates across all views
- Race condition prevention: rapid filter changes + navigation
- Memory management: deep navigation stack doesn't cause memory issues
- Background/foreground: integration state preserved after app backgrounds

## Files to Modify/Create
- `maestro/flows/m01-e05/cross_workflow_integration.yaml`
- `maestro/flows/m01-e05/cross_workflow_state_preservation.yaml`
- `maestro/flows/m01-e05/cross_workflow_race_conditions.yaml`
- `maestro/flows/m01-e05/cross_workflow_memory_stress.yaml`

## Dependencies
- m01-e05-t02 (browse workflow E2E)
- m01-e05-t03 (filter/search workflow E2E)
- m01-e05-t04 (flyer details workflow E2E)
- m01-e05-t05 (profile workflow E2E)

## Notes
**Critical: NO MOCKS**
- Real Django backend handling all API requests
- Real database queries for filters, search, profiles
- Real iOS app state management
- Real navigation stack with multiple screens
- Real memory management under deep navigation

**State Preservation Logic**:
- Main feed: filters + search term + scroll position
- Profile screen: creator ID + scroll position (filters NOT applied)
- Detail screen: flyer ID + carousel position
- Each screen maintains independent state
- Navigation back restores previous screen state exactly

**Data Consistency Rules**:
1. Main feed respects active filters
2. Profile view shows ALL creator's flyers (ignores main feed filters)
3. Detail view shows COMPLETE flyer data (not filtered)
4. Pull-to-refresh updates ALL data sources (main feed, profile cache, detail cache)

**Race Condition Tests**:
1. Rapid filter toggling:
   - Toggle Events on/off/on/off rapidly
   - Assert: final state consistent (no duplicate requests, no stale data)
2. Filter + immediate navigation:
   - Apply filter, immediately tap flyer (before results fully load)
   - Assert: detail loads correctly (no crash, no missing data)
3. Search + rapid typing:
   - Type search term quickly ("c", "co", "con", "conc", "conce", "concer", "concert")
   - Assert: debounced correctly (not 7 API requests, but 1-2)
   - Assert: final results match final search term

**Memory Stress Test**:
1. Navigate deep: feed → profile A → detail → profile A → detail → profile B → detail → back → back → back → back → back → back
2. Assert: no memory leaks (iOS memory usage <100MB)
3. Assert: all screens render correctly on return (no missing data)
4. Assert: scroll positions preserved at each level

**Background/Foreground Integration**:
1. Apply filters (Events + Near Me + "concert")
2. Navigate to profile
3. App backgrounds (home button)
4. Wait 5 seconds
5. Return to app
6. Assert: profile still visible, data intact
7. Navigate back to main feed
8. Assert: filters still active, results consistent

**Complex Filter Logic Validation**:
- Test: (Events OR Nightlife) AND (within 5km) AND (title ILIKE '%concert%' OR description ILIKE '%concert%')
- Verify via backend SQL log: query structure matches expected AND/OR logic
- Verify result count: matches backend query result count
- Verify no false positives: manually inspect 5 results for correctness

**Pull-to-Refresh Integration**:
1. Apply filters (Events + Near Me)
2. Note current result count (e.g., 10 flyers)
3. Add new flyer via backend matching filters (Event, within 5km)
4. Pull-to-refresh main feed
5. Assert: result count increases to 11
6. Assert: new flyer appears in feed
7. Navigate to profile of creator who posted new flyer
8. Assert: new flyer appears in creator's profile feed (cache invalidated)

**Performance Under Integration**:
- Measure cumulative performance across full integration flow
- Total time for complete workflow: <15 seconds (20 steps)
- No single step exceeds 2 seconds
- Average transition time: <500ms

**Accessibility During Integration**:
- VoiceOver navigation through complete workflow
- Screen reader announces state changes (filters applied, results updated)
- Focus preservation across navigation transitions
