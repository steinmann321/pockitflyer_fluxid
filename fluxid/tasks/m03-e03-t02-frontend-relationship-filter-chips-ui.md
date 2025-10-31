---
id: m03-e03-t02
title: Frontend Relationship Filter Chips and UI Integration
epic: m03-e03
milestone: m03
status: pending
---

# Task: Frontend Relationship Filter Chips and UI Integration

## Context
Part of Relationship Filtering (m03-e03) in Social engagement features (m03).

Implements "Favorites" and "Following" filter chip UI components and integrates them into the existing relationship filter bar (from m01). These chips allow users to filter the feed to show only favorited flyers or flyers from followed creators. Includes authentication gating, visual state management, empty states, and loading states.

## Implementation Guide for LLM Agent

### Objective
Create "Favorites" and "Following" filter chip widgets, integrate them into the relationship filter bar, implement tap handlers with auth gating, and display appropriate empty/loading states.

### Steps
1. **Create Favorites filter chip widget**
   - File: `pockitflyer_app/lib/widgets/favorites_filter_chip.dart` (create new)
   - Create stateless widget that displays "Favorites" text with heart icon
   - Accept props: `isActive` (bool), `onTap` (callback), `isAuthenticated` (bool)
   - Show active state styling when `isActive = true` (e.g., filled background, bold text)
   - Show inactive state styling when `isActive = false` (e.g., outlined, normal text)
   - Disable chip visually if not authenticated (gray out or add lock icon)
   - Use Flutter Material Design `FilterChip` or `ChoiceChip` as base component

2. **Create Following filter chip widget**
   - File: `pockitflyer_app/lib/widgets/following_filter_chip.dart` (create new)
   - Create stateless widget that displays "Following" text with person icon
   - Accept same props as favorites chip: `isActive`, `onTap`, `isAuthenticated`
   - Match styling patterns from favorites chip for consistency
   - Show active/inactive states identically to favorites chip

3. **Integrate chips into relationship filter bar**
   - File: Find existing relationship filter bar component (from m01, likely in `pockitflyer_app/lib/widgets/` or `pockitflyer_app/lib/screens/`)
   - If filter bar doesn't exist, create: `pockitflyer_app/lib/widgets/relationship_filter_bar.dart`
   - Add Favorites and Following chips to the horizontal scrollable row
   - Position chips BEFORE existing category tag filter chips (relationship filters are primary)
   - Maintain existing category filter chips functionality
   - Ensure horizontal scrolling works with additional chips

4. **Implement authentication gating logic**
   - When unauthenticated user taps Favorites or Following chip:
   - Show authentication prompt dialog: "Sign in to use this feature"
   - Include "Sign In" button that navigates to login screen
   - Include "Cancel" button to dismiss dialog
   - Do NOT apply filter for unauthenticated users
   - When authenticated user taps: proceed with filter activation (handled in t03)

5. **Implement empty state display**
   - File: `pockitflyer_app/lib/widgets/empty_feed_state.dart` (create or modify)
   - When Favorites filter is active and user has zero favorites:
   - Display empty state message: "You haven't favorited any flyers yet. Tap the heart icon on flyers you want to save."
   - Include illustration or icon (heart icon)
   - When Following filter is active and user follows zero creators:
   - Display: "You're not following any creators yet. Tap the follow button on flyers from creators you want to follow."
   - Include illustration or icon (person icon)
   - When combined filters yield no results:
   - Display: "No flyers match your selected filters. Try adjusting your filter selection."

6. **Implement loading state display**
   - File: Find or create feed loading component
   - When filter changes and feed is fetching:
   - Show skeleton loading state (shimmer cards or loading spinner)
   - Replace feed content with skeleton until fetch completes
   - Target: display loading state within 100ms of filter tap

7. **Create comprehensive widget tests**
   - File: `pockitflyer_app/test/widgets/favorites_filter_chip_test.dart` (create new)
   - Test: Favorites chip renders with correct text and icon
   - Test: Active state shows filled background
   - Test: Inactive state shows outlined background
   - Test: Tap triggers onTap callback
   - Test: Unauthenticated state shows disabled styling

   - File: `pockitflyer_app/test/widgets/following_filter_chip_test.dart` (create new)
   - Test: Following chip renders with correct text and icon
   - Test: Active/inactive states match favorites chip patterns
   - Test: Tap triggers onTap callback

   - File: `pockitflyer_app/test/widgets/relationship_filter_bar_test.dart` (create new)
   - Test: Filter bar renders both relationship chips
   - Test: Chips appear before category chips
   - Test: Horizontal scrolling works with all chips

8. **Create integration tests for authentication gating**
   - File: `pockitflyer_app/test/integration/filter_auth_gating_test.dart` (create new)
   - Test: Unauthenticated tap shows auth dialog
   - Test: Dialog has "Sign In" and "Cancel" buttons
   - Test: "Sign In" navigates to login screen
   - Test: "Cancel" dismisses dialog without action
   - Test: Authenticated tap proceeds without dialog (verify callback invoked)

### Acceptance Criteria
- [ ] Favorites filter chip renders in relationship filter bar [Test: widget test finds chip with "Favorites" text]
- [ ] Following filter chip renders in relationship filter bar [Test: widget test finds chip with "Following" text]
- [ ] Chips show active state when selected [Test: set isActive=true, verify filled background styling]
- [ ] Chips show inactive state when not selected [Test: set isActive=false, verify outlined styling]
- [ ] Unauthenticated tap shows auth dialog [Test: tap chip while not authenticated, verify dialog appears]
- [ ] Auth dialog has "Sign In" and "Cancel" buttons [Test: verify dialog content]
- [ ] "Sign In" button navigates to login screen [Test: tap button, verify navigation]
- [ ] Authenticated tap does not show dialog [Test: tap while authenticated, verify no dialog]
- [ ] Empty state displays for zero favorites [Test: active filter with empty favorites list]
- [ ] Empty state displays for zero following [Test: active filter with empty following list]
- [ ] Loading state displays during fetch [Test: trigger filter change, verify skeleton appears immediately]
- [ ] Tests pass with >85% coverage [Test: run Flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/widgets/favorites_filter_chip.dart` - NEW: Favorites chip widget
- `pockitflyer_app/lib/widgets/following_filter_chip.dart` - NEW: Following chip widget
- `pockitflyer_app/lib/widgets/relationship_filter_bar.dart` - MODIFY or NEW: integrate chips into filter bar
- `pockitflyer_app/lib/widgets/empty_feed_state.dart` - MODIFY or NEW: empty state messaging
- `pockitflyer_app/lib/widgets/feed_loading_state.dart` - MODIFY or NEW: loading skeleton
- `pockitflyer_app/test/widgets/favorites_filter_chip_test.dart` - NEW: Favorites chip tests
- `pockitflyer_app/test/widgets/following_filter_chip_test.dart` - NEW: Following chip tests
- `pockitflyer_app/test/widgets/relationship_filter_bar_test.dart` - NEW: Filter bar integration tests
- `pockitflyer_app/test/integration/filter_auth_gating_test.dart` - NEW: Auth gating tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Widget test**: Individual chip components, test rendering, state changes, tap handlers, styling variations
- **Integration test**: Filter bar with chips, test horizontal scrolling, chip positioning, authentication gating dialog flow, empty state displays, loading state transitions

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Flutter widget patterns, Material Design)
- [ ] No console errors or warnings
- [ ] UI matches design specifications (active/inactive states, empty states)
- [ ] Changes committed with reference to task ID: `m03-e03-t02`
- [ ] Ready for state management integration (m03-e03-t03)

## Dependencies
- **Requires**: M01 (Browse flyers) - Existing feed UI and filter bar infrastructure
- **Requires**: M02 (User authentication) - Auth context for determining user authentication state
- **Requires**: m03-e03-t01 (Backend endpoints) - Endpoints must exist for filter functionality
- **Blocks**: m03-e03-t03 (Filter combination logic) - UI components must exist before wiring state

## Technical Notes
- **Flutter FilterChip**: Use Material Design `FilterChip` or `ChoiceChip` for consistent styling
- **Authentication context**: Access auth state via Provider, Riverpod, or similar state management (check existing pattern in m02)
- **Empty states**: Follow existing empty state patterns in the codebase for consistency
- **Loading states**: Use skeleton screens (shimmer effect) rather than spinners for better perceived performance
- **Styling**: Match existing chip styling from category filters for visual consistency
- **Horizontal scrolling**: Ensure filter bar uses `SingleChildScrollView` with `Axis.horizontal`
- **Icons**: Use Material Icons: `Icons.favorite` for Favorites, `Icons.person` for Following

## References
- Flutter FilterChip documentation: https://api.flutter.dev/flutter/material/FilterChip-class.html
- Material Design chips: https://m3.material.io/components/chips/overview
- Epic empty state messages: `/Users/jakob.steinmann/vscodeprojects/pockitflyer_fluxid/fluxid/epics/m03-e03-relationship-filtering.md` (lines 75-78)
- Epic technical considerations: `/Users/jakob.steinmann/vscodeprojects/pockitflyer_fluxid/fluxid/epics/m03-e03-relationship-filtering.md` (lines 62-84)
