---
id: m01-e04-t03
title: Pull-to-Refresh Implementation with State Management
epic: m01-e04
milestone: m01
status: pending
---

# Task: Pull-to-Refresh Implementation with State Management

## Context
Part of Search and Real-time Feed Updates (m01-e04) in Milestone 1 (m01).

Implements the standard iOS pull-to-refresh pattern that allows users to manually refresh the feed to fetch the latest flyers from the backend. Refresh maintains current filter and search state, providing updated results within the user's active view context.

## Implementation Guide for LLM Agent

### Objective
Add pull-to-refresh functionality to the flyer feed that triggers a manual refresh of content while maintaining active search and filter state.

### Steps

1. Add RefreshIndicator to feed display
   - Locate the main feed display widget from m01-e02 (likely `pockitflyer_app/lib/widgets/feed_display.dart` or similar)
   - Wrap the scrollable feed list with Flutter's `RefreshIndicator` widget
   - Configure `RefreshIndicator`:
     - Set `onRefresh` callback to async refresh function
     - Use default color scheme (or brand colors if defined)
     - Ensure displacement allows enough space for indicator to show

2. Implement refresh logic in feed provider
   - Locate flyer feed provider from m01-e02 (likely `pockitflyer_app/lib/providers/flyer_provider.dart`)
   - Add `refreshFeed()` method that:
     - Shows loading state (if not already handled by RefreshIndicator)
     - Fetches fresh data from backend API
     - Includes current search query parameter (if search is active)
     - Includes current filter parameters (category, proximity if active)
     - Replaces existing feed data with fresh results
     - Handles errors gracefully (show error message, keep existing data)
     - Returns Future that completes when refresh finishes (required by RefreshIndicator)

3. Connect RefreshIndicator to refresh provider method
   - Wire `RefreshIndicator.onRefresh` to feed provider's `refreshFeed()` method
   - Ensure method is called through provider reference (e.g., `ref.read(flyerProvider.notifier).refreshFeed()`)
   - Handle loading states during refresh
   - Ensure UI remains responsive during refresh

4. Add haptic feedback on refresh trigger
   - Use Flutter's `HapticFeedback.mediumImpact()` when refresh is triggered
   - Call haptic feedback at start of `onRefresh` callback
   - Ensure haptic works on iOS (verify in iOS simulator or device)

5. Handle refresh during active search/filters
   - Verify refresh preserves search query [Test: search for "pizza", pull-to-refresh, verify search still active]
   - Verify refresh preserves category filter [Test: filter by "food", pull-to-refresh, verify filter still active]
   - Verify refresh preserves proximity filter [Test: filter by 5km radius, pull-to-refresh, verify filter still active]
   - Verify refresh combines all active filters [Test: search + category + proximity, pull-to-refresh, verify all filters maintained]

6. Handle error states during refresh
   - If API request fails, show error message (SnackBar or similar)
   - Keep existing feed data visible on error
   - Allow user to retry refresh
   - Log error for debugging (don't crash app)

7. Create integration tests
   - Test pull-to-refresh triggers feed refresh [Test: mock refresh, verify API called]
   - Test refresh maintains search query [Test: active search + refresh, verify search parameter sent to API]
   - Test refresh maintains category filter [Test: active category filter + refresh, verify filter parameter sent to API]
   - Test refresh maintains proximity filter [Test: active proximity filter + refresh, verify filter parameter sent to API]
   - Test refresh combines multiple filters [Test: search + category + proximity + refresh, verify all parameters sent]
   - Test refresh updates feed with new data [Test: mock API with different data, verify feed updates]
   - Test refresh handles errors gracefully [Test: mock API failure, verify error message shown, existing data preserved]
   - Test refresh loading state [Test: verify loading indicator shown during refresh]
   - Test haptic feedback triggers [Test: verify haptic method called on refresh]

### Acceptance Criteria
- [ ] Pull-to-refresh gesture triggers feed refresh [Test: pull down on feed, see refresh indicator, feed updates]
- [ ] Refresh fetches latest flyers from backend API [Test: mock API with new data, verify feed updates after refresh]
- [ ] Refresh maintains active search query [Test: search "pizza", refresh, verify search still active and results updated]
- [ ] Refresh maintains active category filter [Test: filter "food", refresh, verify filter still active and results updated]
- [ ] Refresh maintains active proximity filter [Test: filter 5km, refresh, verify filter still active and results updated]
- [ ] Refresh combines all active filters [Test: search + category + proximity, refresh, verify all maintained]
- [ ] Refresh shows loading indicator [Test: visual feedback during refresh operation]
- [ ] Refresh provides haptic feedback on trigger [Test: feel haptic on iOS when refresh starts]
- [ ] Refresh handles API errors gracefully [Test: mock API failure, verify error message, existing data preserved]
- [ ] Refresh does not crash app on error [Test: various error scenarios, app remains stable]
- [ ] Integration tests pass with >90% coverage

### Files to Create/Modify
- `pockitflyer_app/lib/widgets/feed_display.dart` - MODIFY: wrap feed list with RefreshIndicator
- `pockitflyer_app/lib/providers/flyer_provider.dart` - MODIFY: add refreshFeed() method
- `pockitflyer_app/test/integration/pull_to_refresh_test.dart` - NEW: integration tests for refresh functionality
- `pockitflyer_app/test/providers/flyer_provider_test.dart` - MODIFY: add unit tests for refreshFeed() method

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit test**: Feed provider refreshFeed() method logic, error handling, state management
- **Widget test**: RefreshIndicator rendering, onRefresh callback triggering
- **Integration test**: Full refresh flow with mocked API, filter preservation, error scenarios

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Flutter/Dart style guide)
- [ ] No console errors or warnings
- [ ] Pull-to-refresh works smoothly without performance issues
- [ ] Haptic feedback works on iOS
- [ ] Error handling is robust and user-friendly
- [ ] Changes committed with reference to task ID
- [ ] Ready for dependent tasks to use

## Dependencies
- Requires: m01-e01 (Backend Flyer API) - API endpoint must exist for fetching fresh data
- Requires: m01-e02 (Core Feed Display) - feed display and provider must exist
- Requires: m01-e03 (Category and Proximity Filtering) - filter state must exist for preservation
- Requires: m01-e04-t02 (Real-time search filtering) - search state must exist for preservation
- Can be implemented in parallel with m01-e04-t02 if search state is not yet available (add search preservation later)

## Technical Notes

### Flutter RefreshIndicator
- Use Flutter's built-in `RefreshIndicator` widget (Material design component)
- RefreshIndicator requires a scrollable child (ListView, CustomScrollView, etc.)
- `onRefresh` callback must return `Future<void>` and complete when refresh is done
- RefreshIndicator automatically shows loading animation and handles scroll physics

### iOS-specific Considerations
- RefreshIndicator uses iOS-style refresh indicator on iOS (Cupertino style)
- Haptic feedback uses `HapticFeedback.mediumImpact()` - works automatically on iOS
- Test on iOS simulator/device to ensure native feel

### State Management
- Feed provider already handles loading/error states from m01-e02
- Refresh should use same state management patterns
- Preserve all current filter/search state when making API request
- Don't clear feed data during refresh (show old data with loading indicator on top)

### Error Handling
- Network errors: show "Failed to refresh feed, please try again"
- Timeout errors: show "Request timed out, please check your connection"
- Server errors: show "Server error, please try again later"
- Keep existing feed data visible on error (don't show empty state)
- Use SnackBar for error messages (non-intrusive)

### Performance
- Refresh should complete within 2-5 seconds under normal network conditions
- Don't block UI during refresh (use async/await properly)
- Cancel in-flight refresh if user navigates away (prevent memory leaks)

## References
- Flutter RefreshIndicator: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
- Flutter HapticFeedback: https://api.flutter.dev/flutter/services/HapticFeedback-class.html
- iOS Human Interface Guidelines - Pull to Refresh: https://developer.apple.com/design/human-interface-guidelines/components/content/refresh-content
- Riverpod async state management: https://riverpod.dev/docs/concepts/reading/#using-refread-to-obtain-a-value-once
