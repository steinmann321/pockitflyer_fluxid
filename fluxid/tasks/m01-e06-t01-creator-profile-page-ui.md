---
id: m01-e06-t01
title: Creator Profile Page UI Layout
epic: m01-e06
milestone: m01
status: pending
---

# Task: Creator Profile Page UI Layout

## Context
Part of Creator Profile Viewing (m01-e06) in Browse and Discover Local Flyers (m01).

Creates the public creator profile page UI that displays creator information (avatar, name, bio) and a scrollable feed of all their active flyers. This page reuses the FlyerCard component from the main feed for consistency and implements the same infinite scroll pattern if the creator has many flyers.

## Implementation Guide for LLM Agent

### Objective
Build a complete creator profile page with header section (avatar, name, bio) and scrollable feed of creator's flyers using the existing FlyerCard component.

### Steps

1. Create profile page widget in `pockitflyer_app/lib/features/profile/presentation/pages/creator_profile_page.dart`:
   - StatefulWidget (needs to manage scroll state)
   - Accept `creatorId` as required parameter (passed from route)
   - Scaffold with AppBar and body
   - AppBar: Back button (auto), title "Creator Profile"

2. Create profile header widget in `pockitflyer_app/lib/features/profile/presentation/widgets/profile_header.dart`:
   - Takes creator data as parameter (name, avatar_url, bio)
   - Layout structure:
     ```dart
     Column(
       children: [
         CircleAvatar(radius: 60), // Large avatar (120x120)
         SizedBox(height: 16),
         Text(creatorName, style: headline4/headline5), // Large, bold
         SizedBox(height: 8),
         Text(bio, style: bodyText2, textAlign: center), // Optional bio
         SizedBox(height: 24),
       ]
     )
     ```
   - Center-aligned content
   - Padding: 24px horizontal, 32px vertical
   - Avatar: Show creator image if available, else show initial letter
   - Bio: Show only if non-empty, max 3 lines with ellipsis
   - Background: Light background color to distinguish from feed

3. Create creator flyers feed widget in `pockitflyer_app/lib/features/profile/presentation/widgets/creator_flyers_feed.dart`:
   - Scrollable list of flyers by this creator
   - Reuse FlyerCard component from `pockitflyer_app/lib/features/feed/presentation/widgets/flyer_card.dart`
   - Implement infinite scroll pattern (similar to main feed from m01-e02-t03)
   - Loading indicator while fetching more flyers
   - Pull-to-refresh to reload flyers
   - Empty state: "No active flyers" with icon if creator has no current flyers

4. Implement profile page body layout in `creator_profile_page.dart`:
   - Use CustomScrollView with SliverList for optimal performance
   - Layout structure:
     ```dart
     CustomScrollView(
       slivers: [
         SliverToBoxAdapter(child: ProfileHeader()),
         SliverList(
           delegate: SliverChildBuilderDelegate(
             (context, index) => FlyerCard(flyer: flyers[index]),
             childCount: flyers.length,
           ),
         ),
         if (isLoadingMore) SliverToBoxAdapter(child: LoadingIndicator()),
       ],
     )
     ```
   - Scroll controller to detect when user reaches bottom (trigger load more)
   - RefreshIndicator for pull-to-refresh

5. Create loading state widget in `pockitflyer_app/lib/features/profile/presentation/widgets/profile_loading.dart`:
   - Skeleton UI showing:
     - Circle placeholder for avatar
     - Rectangular placeholders for name and bio
     - Multiple FlyerCard skeletons below
   - Use shimmer effect (package: shimmer ^3.0.0) for better UX
   - Display while profile data is being fetched

6. Create error state widget in `pockitflyer_app/lib/features/profile/presentation/widgets/profile_error.dart`:
   - Takes error type and message as parameters
   - Different layouts for different errors:
     - **Creator not found (404)**: "Creator not found" message, button "Return to Feed"
     - **Network error**: "Connection error" message, "Retry" button
     - **Timeout**: "Request timed out" message, "Retry" button
     - **General error**: Generic message, "Retry" button
   - Center-aligned content with icon, message, and action button
   - Button actions: retry fetch OR navigate back to feed

7. Create empty state widget in `pockitflyer_app/lib/features/profile/presentation/widgets/profile_empty_state.dart`:
   - Display when creator has zero active flyers
   - Show icon (e.g., Icons.image_not_supported or custom illustration)
   - Message: "No active flyers" or "This creator hasn't posted any flyers yet"
   - Optional: "Check back later" subtext
   - Center-aligned with padding

8. Add profile route to go_router in `pockitflyer_app/lib/core/routing/app_router.dart`:
   - Route path: `/profile/:creatorId`
   - Route builder: Returns CreatorProfilePage with creatorId parameter
   - Example:
     ```dart
     GoRoute(
       path: '/profile/:creatorId',
       builder: (context, state) {
         final creatorId = state.pathParameters['creatorId']!;
         return CreatorProfilePage(creatorId: creatorId);
       },
     )
     ```

9. Handle edge cases and responsive design:
   - Very long creator names: Truncate with ellipsis if needed
   - Missing avatar: Show initial letter in CircleAvatar
   - Missing bio: Don't show bio section at all (reduce empty space)
   - Large number of flyers: Pagination (load 20 at a time, load more on scroll)
   - Screen sizes: Test on various iPhone sizes (SE, standard, Plus/Max)
   - Safe area: Ensure content respects safe areas (notch, home indicator)

10. Create profile page state management placeholder (will be implemented in m01-e06-t03):
    - For this task: Use hardcoded mock data for creator info and flyers list
    - Create mock data in `pockitflyer_app/lib/features/profile/data/mock_profile_data.dart`:
      - Mock creator: id, name, avatar_url, bio
      - Mock flyers: List of 3-5 flyer objects matching FlyerModel structure
    - ProfilePage displays mock data initially
    - Add TODO comments indicating where Riverpod providers will be integrated

11. Update pubspec.yaml:
    - Add `shimmer: ^3.0.0` for loading skeleton UI
    - Run `flutter pub get`

12. Create widget tests in `pockitflyer_app/test/features/profile/presentation/`:
    - `pages/creator_profile_page_test.dart`:
      - Test page renders with mock data
      - Test AppBar title and back button present
      - Test ProfileHeader displays in page
      - Test FlyerCards render in scrollable list
    - `widgets/profile_header_test.dart`:
      - Test header displays avatar, name, bio
      - Test avatar fallback with initial letter
      - Test bio hidden when null/empty
      - Test text truncation for long names
    - `widgets/creator_flyers_feed_test.dart`:
      - Test flyers list renders FlyerCard components
      - Test empty state shown when no flyers
      - Test loading indicator shown during load more
    - `widgets/profile_loading_test.dart`:
      - Test skeleton UI renders correctly
    - `widgets/profile_error_test.dart`:
      - Test different error types display correct messages
      - Test retry button present and tappable
      - Test return to feed button for 404
    - `widgets/profile_empty_state_test.dart`:
      - Test empty state message and icon display

13. Visual testing and polish:
    - Run app and navigate to profile page manually
    - Verify layout looks good on iPhone SE (smallest), iPhone 14 Pro (standard), iPhone 14 Pro Max (largest)
    - Check spacing and padding consistency
    - Verify scroll behavior is smooth
    - Test pull-to-refresh gesture
    - Verify loading skeleton matches final layout structure
    - Test error states by simulating network failures

### Acceptance Criteria
- [ ] Profile page displays creator header with avatar, name, and bio [Test: widget test with mock data]
- [ ] Profile page shows scrollable feed of creator's flyers using FlyerCard [Test: render 5 flyers, verify all displayed]
- [ ] All FlyerCard features work on profile (carousel, location button, favorite) [Test: tap interactions work]
- [ ] Loading state shows skeleton UI while fetching data [Test: widget renders ProfileLoading]
- [ ] Error states display appropriate messages and actions [Test: test all error types - 404, network, timeout]
- [ ] Empty state shows when creator has no flyers [Test: mock creator with empty flyers list]
- [ ] Profile route `/profile/:creatorId` works correctly [Test: navigate to route, verify creatorId passed]
- [ ] Pull-to-refresh reloads flyers (placeholder for now) [Test: trigger refresh gesture]
- [ ] Infinite scroll loads more flyers when reaching bottom [Test: scroll to bottom, verify load more triggered]
- [ ] Avatar fallback shows initial letter when image unavailable [Test: mock creator without avatar_url]
- [ ] Long creator names truncate properly without overflow [Test: very long name]
- [ ] Bio section hidden when bio is null/empty [Test: mock creator without bio]
- [ ] Layout is responsive on different screen sizes [Test: visual testing on various iPhones]
- [ ] Widget tests pass with >85% coverage [Test: `flutter test --coverage`]

### Files to Create/Modify
- `pockitflyer_app/lib/features/profile/presentation/pages/creator_profile_page.dart` - NEW: main profile page
- `pockitflyer_app/lib/features/profile/presentation/widgets/profile_header.dart` - NEW: creator info header
- `pockitflyer_app/lib/features/profile/presentation/widgets/creator_flyers_feed.dart` - NEW: scrollable flyers list
- `pockitflyer_app/lib/features/profile/presentation/widgets/profile_loading.dart` - NEW: loading skeleton UI
- `pockitflyer_app/lib/features/profile/presentation/widgets/profile_error.dart` - NEW: error state display
- `pockitflyer_app/lib/features/profile/presentation/widgets/profile_empty_state.dart` - NEW: empty state display
- `pockitflyer_app/lib/features/profile/data/mock_profile_data.dart` - NEW: mock data for testing UI
- `pockitflyer_app/lib/core/routing/app_router.dart` - MODIFY: add /profile/:creatorId route
- `pockitflyer_app/pubspec.yaml` - MODIFY: add shimmer dependency
- `pockitflyer_app/test/features/profile/presentation/pages/creator_profile_page_test.dart` - NEW: page tests
- `pockitflyer_app/test/features/profile/presentation/widgets/profile_header_test.dart` - NEW: header tests
- `pockitflyer_app/test/features/profile/presentation/widgets/creator_flyers_feed_test.dart` - NEW: feed tests
- `pockitflyer_app/test/features/profile/presentation/widgets/profile_loading_test.dart` - NEW: loading tests
- `pockitflyer_app/test/features/profile/presentation/widgets/profile_error_test.dart` - NEW: error tests
- `pockitflyer_app/test/features/profile/presentation/widgets/profile_empty_state_test.dart` - NEW: empty state tests

### Testing Requirements
- **Unit tests**: Mock data structure validation, edge case handling (null values, empty strings)
- **Widget tests**: All profile widgets in isolation (header, feed, loading, error, empty), full page composition with mock data, scroll behavior and interactions (pull-to-refresh, infinite scroll triggers), responsive layout on different screen sizes
- **Integration tests**: Full profile page with navigation (route parameter passing, back navigation), FlyerCard interactions within profile context

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter best practices and project conventions
- [ ] No console errors or warnings
- [ ] No layout overflow errors with various data lengths
- [ ] All states properly handled (loading, error, empty, success)
- [ ] Visual hierarchy and spacing consistent with main feed
- [ ] Comments added for complex layout decisions
- [ ] TODO comments added for Riverpod integration points (m01-e06-t03)
- [ ] Changes committed with reference to task ID (m01-e06-t01)
- [ ] Ready for navigation integration (m01-e06-t02) and state management (m01-e06-t03)

## Dependencies
- Requires: m01-e02-t04 (FlyerCard component), m01-e02-t03 (infinite scroll pattern), m01-e02-t01 (app structure and routing)
- Blocks: m01-e06-t02 (navigation from flyer cards), m01-e06-t03 (backend integration and state management)

## Technical Notes

### UI Design Principles
- **Consistency**: Reuse FlyerCard component exactly as in main feed - same spacing, same interactions
- **Visual hierarchy**: Profile header should clearly separate from flyer feed (use background color or divider)
- **Scrolling**: Use CustomScrollView + Slivers for optimal performance with large lists
- **Loading skeleton**: Match the structure of actual content (avatar circle → name/bio rectangles → flyer cards)

### Profile Header Layout
- Large avatar (120x120) for visual prominence
- Center-aligned for focus on creator identity
- Bio is optional - only show if present to avoid empty space
- Consider max-width for bio text on larger screens (improve readability)

### Infinite Scroll Pattern
- Same implementation as main feed (m01-e02-t03)
- ScrollController listens for scroll position
- When user scrolls to ~80% of content, trigger load more
- Show loading indicator at bottom while fetching
- Append new flyers to existing list

### Error Handling Strategy
- **404 (Creator not found)**: Offer "Return to Feed" - user may have invalid URL
- **Network errors**: Offer "Retry" - temporary issue, allow retry
- **Timeouts**: Offer "Retry" - backend may be slow
- **Generic errors**: Offer "Retry" and consider logging for debugging

### Mock Data Structure (for UI testing)
This task uses mock data for UI development. Backend integration happens in m01-e06-t03.
```dart
final mockCreator = {
  'id': 'creator-123',
  'display_name': 'John Doe',
  'avatar_url': 'https://example.com/avatar.jpg',
  'bio': 'Local business owner sharing deals and events',
};

final mockFlyers = [
  // List of FlyerModel objects matching structure from m01-e02-t03
];
```

### Routing with go_router
- Path parameter: `:creatorId` extracts creator ID from URL
- Access in widget: `state.pathParameters['creatorId']`
- Navigation: `context.go('/profile/$creatorId')`
- Back navigation: `context.pop()` or AppBar back button (automatic)

### Responsive Design Considerations
- iPhone SE (375×667): Compact, ensure content doesn't overflow
- iPhone 14 Pro (393×852): Standard reference size
- iPhone 14 Pro Max (430×932): Larger, ensure layout scales well
- Use MediaQuery for adaptive sizing if needed
- Test in both portrait and landscape (if supported)

### Performance Considerations
- Use const constructors where possible
- Implement AutomaticKeepAliveClientMixin if scroll position should persist during navigation
- Lazy load flyers list (don't load all at once)
- Cache images with Flutter's default image cache

## References
- Flutter CustomScrollView: https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html
- Flutter Sliver widgets: https://docs.flutter.dev/ui/layout/scrolling/slivers
- go_router path parameters: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
- shimmer package: https://pub.dev/packages/shimmer
- Flutter RefreshIndicator: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
- ScrollController: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
