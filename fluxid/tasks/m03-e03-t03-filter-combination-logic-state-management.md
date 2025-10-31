---
id: m03-e03-t03
title: Filter Combination Logic and State Management
epic: m03-e03
milestone: m03
status: pending
---

# Task: Filter Combination Logic and State Management

## Context
Part of Relationship Filtering (m03-e03) in Social engagement features (m03).

Implements the state management and business logic for combining relationship filters (Favorites, Following) with existing category tag filters. Handles filter activation/deactivation, API calls to backend endpoints, scroll position preservation, and filter state persistence across navigation. Ensures filters work correctly together using proper AND/OR logic.

## Implementation Guide for LLM Agent

### Objective
Create filter state management that coordinates relationship and category filters, makes API calls to backend endpoints, preserves scroll position, persists state across navigation, and handles all filter combination scenarios.

### Steps
1. **Create or extend filter state provider/controller**
   - File: `pockitflyer_app/lib/providers/feed_filter_provider.dart` (create or modify if exists)
   - Define state properties:
     - `activeRelationshipFilter: String?` (null, 'favorites', or 'following')
     - `activeCategoryTags: Set<String>` (existing from m01)
     - `isLoading: bool` (feed fetch in progress)
     - `feedData: List<Flyer>` (current feed results)
   - Ensure state uses Provider, Riverpod, or existing state management pattern from m01/m02

2. **Implement relationship filter activation logic**
   - Create method: `activateRelationshipFilter(String filterType)` where filterType is 'favorites' or 'following'
   - When called:
     - If `activeRelationshipFilter == filterType`, deactivate (set to null)
     - Else, set `activeRelationshipFilter = filterType` (exclusive: only one relationship filter at a time)
     - Preserve existing `activeCategoryTags`
     - Trigger feed fetch with new filter combination
     - Set `isLoading = true` before fetch

3. **Implement feed fetch with filter combination**
   - Create method: `fetchFilteredFeed()`
   - Build API URL based on active filters:
     - If `activeRelationshipFilter != null`: add `?relationship={filterType}`
     - If `activeCategoryTags.isNotEmpty`: add `&tags={tag1},{tag2}` (or `?tags=` if no relationship)
     - Example: `/api/feed/?relationship=favorites&tags=events,food`
   - Make HTTP GET request to backend (m03-e03-t01 endpoints)
   - Handle responses:
     - Success 200: update `feedData`, set `isLoading = false`
     - Error 401: show re-authentication prompt (should not happen if auth gating works)
     - Error 400: show error toast "Invalid filter selection"
     - Error 5xx: show error toast "Failed to load feed"
   - Update UI with new feed data

4. **Implement filter combination validation**
   - Verify logic: Relationship filters are EXCLUSIVE (Favorites OR Following, not both)
   - Verify logic: Category tags are INCLUSIVE within categories (Events OR Food)
   - Verify logic: Relationship + Category is AND (Favorites AND (Events OR Food))
   - Create method: `getCombinedFilterDescription(): String` that returns human-readable description
   - Examples:
     - "Favorites" (only relationship filter)
     - "Events, Food" (only category filters)
     - "Favorites · Events, Food" (combination with separator)

5. **Implement scroll position preservation**
   - File: Modify feed screen component (likely `pockitflyer_app/lib/screens/feed_screen.dart`)
   - Use Flutter `ScrollController` to track scroll position
   - Before applying filter change:
     - Store current scroll offset: `savedScrollOffset = scrollController.offset`
   - After feed data updates:
     - Restore scroll position: `scrollController.jumpTo(savedScrollOffset)`
     - Handle edge case: if new feed is shorter, scroll to top instead
   - Test: scroll to position 500px, apply filter, verify position maintained

6. **Implement filter state persistence across navigation**
   - When user navigates away from feed screen:
     - Keep filter state in provider/controller (do NOT reset)
   - When user returns to feed screen:
     - Re-use existing filter state
     - Feed data should still be available (cached)
   - When app restarts:
     - Reset all filters to default (no relationship filter, no category tags)
   - Test: apply filter, navigate to profile, return, verify filter still active

7. **Wire filter chip tap handlers to state management**
   - File: Modify relationship filter bar component (from m03-e03-t02)
   - Connect Favorites chip `onTap` to `activateRelationshipFilter('favorites')`
   - Connect Following chip `onTap` to `activateRelationshipFilter('following')`
   - Bind `isActive` prop to `activeRelationshipFilter == 'favorites'` (for Favorites chip)
   - Bind `isActive` prop to `activeRelationshipFilter == 'following'` (for Following chip)
   - Ensure auth check happens before calling activation method

8. **Create comprehensive integration tests**
   - File: `pockitflyer_app/test/integration/filter_combination_test.dart` (create new)
   - Test: Activating Favorites filter makes API call to `/api/feed/?relationship=favorites`
   - Test: Activating Following filter makes API call to `/api/feed/?relationship=following`
   - Test: Toggling same filter twice deactivates it (API call to `/api/feed/` without relationship param)
   - Test: Switching from Favorites to Following replaces filter (exclusive behavior)
   - Test: Combining relationship filter + category tags builds correct URL: `?relationship=favorites&tags=events`
   - Test: Scroll position preserved after filter change
   - Test: Filter state persists across navigation (navigate away and back)
   - Test: Filter state resets on app restart
   - Test: Loading state shows during fetch, hides after completion
   - Test: Error handling for 401, 400, 5xx responses

9. **Create unit tests for state management logic**
   - File: `pockitflyer_app/test/providers/feed_filter_provider_test.dart` (create new)
   - Test: `activateRelationshipFilter('favorites')` sets state correctly
   - Test: Calling same filter twice toggles it off
   - Test: Activating new relationship filter replaces previous one
   - Test: `getCombinedFilterDescription()` returns correct strings for various combinations
   - Test: Filter URL building logic produces correct query parameters

### Acceptance Criteria
- [ ] Tapping Favorites chip activates filter and fetches filtered feed [Test: tap chip, verify API call to `/api/feed/?relationship=favorites`]
- [ ] Tapping Following chip activates filter and fetches filtered feed [Test: tap chip, verify API call to `/api/feed/?relationship=following`]
- [ ] Tapping active filter toggles it off [Test: tap Favorites twice, verify second tap calls `/api/feed/` without relationship param]
- [ ] Only one relationship filter can be active at a time [Test: activate Favorites, then Following, verify Favorites deactivates]
- [ ] Relationship filter combines with category tags [Test: activate Favorites + Events tag, verify API call to `?relationship=favorites&tags=events`]
- [ ] Scroll position is preserved after filter change [Test: scroll to 500px, apply filter, verify position maintained]
- [ ] Filter state persists across navigation [Test: activate filter, navigate away, return, verify filter still active]
- [ ] Filter state resets on app restart [Test: restart app, verify no filters active]
- [ ] Loading state displays during fetch [Test: trigger filter, verify isLoading=true until fetch completes]
- [ ] Error handling works for API failures [Test: simulate 400, 401, 500 responses, verify appropriate error messages]
- [ ] Tests pass with >85% coverage [Test: run Flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/providers/feed_filter_provider.dart` - MODIFY or NEW: state management for filters
- `pockitflyer_app/lib/screens/feed_screen.dart` - MODIFY: integrate scroll controller, wire providers
- `pockitflyer_app/lib/widgets/relationship_filter_bar.dart` - MODIFY: connect tap handlers to state management
- `pockitflyer_app/lib/services/feed_service.dart` - MODIFY or NEW: API service for feed fetching with filters
- `pockitflyer_app/test/integration/filter_combination_test.dart` - NEW: integration tests for filter combinations
- `pockitflyer_app/test/providers/feed_filter_provider_test.dart` - NEW: unit tests for state management

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit test**: Filter state management logic, filter URL building, state transitions, filter combination validation
- **Integration test**: Full filter workflow with mocked API service, test tap handlers trigger correct state changes and API calls, verify scroll preservation, test navigation persistence, test error handling

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Flutter state management patterns)
- [ ] No console errors or warnings
- [ ] Filter combinations work correctly (AND/OR logic verified)
- [ ] Scroll position preservation works reliably
- [ ] Changes committed with reference to task ID: `m03-e03-t03`
- [ ] Epic m03-e03 is fully functional end-to-end

## Dependencies
- **Requires**: m03-e03-t01 (Backend endpoints) - API endpoints must be implemented
- **Requires**: m03-e03-t02 (Frontend chips) - UI components must exist to wire up
- **Requires**: M01 (Browse flyers) - Base feed and category filter state management
- **Requires**: M02 (User authentication) - Auth context for authenticated API calls

## Technical Notes
- **Filter combination logic**:
  - Relationship filters: EXCLUSIVE (Favorites OR Following, not both at once)
  - Category tags: INCLUSIVE (Events OR Food)
  - Relationship + Category: AND (Favorites AND (Events OR Food))
- **State management**: Use existing pattern from m01/m02 (Provider, Riverpod, etc.)
- **Scroll controller**: Use `ScrollController` with `keepScrollOffset: true`, store offset before fetch, restore after
- **API URL building**: Ensure proper query parameter encoding, use `Uri.parse().replace(queryParameters: {...})`
- **Loading states**: Set `isLoading = true` immediately on filter change for responsive UI (< 100ms perceived delay)
- **Error handling**: Show toast messages for errors, don't crash app, allow user to retry
- **Performance**: Target filter change to first content rendered in < 500ms (from epic requirements)

## References
- Flutter Provider state management: https://pub.dev/packages/provider
- Flutter ScrollController: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
- Epic filter combination logic: `/Users/jakob.steinmann/vscodeprojects/pockitflyer_fluxid/fluxid/epics/m03-e03-relationship-filtering.md` (lines 80-84)
- Epic performance targets: `/Users/jakob.steinmann/vscodeprojects/pockitflyer_fluxid/fluxid/epics/m03-e03-relationship-filtering.md` (lines 70-73)
