---
id: m01-e06-t02
title: Creator Profile Navigation from Flyer Cards
epic: m01-e06
milestone: m01
status: pending
---

# Task: Creator Profile Navigation from Flyer Cards

## Context
Part of Creator Profile Viewing (m01-e06) in Browse and Discover Local Flyers (m01).

Implements navigation from flyer cards to creator profile pages. Makes the creator avatar and name on each flyer card tappable, triggering navigation to the creator's profile page. Also ensures proper back navigation that preserves the main feed state (scroll position, applied filters).

## Implementation Guide for LLM Agent

### Objective
Make creator information (avatar and name) on flyer cards tappable and implement navigation to creator profile pages with proper state preservation on back navigation.

### Steps

1. Locate the card header widget from m01-e02-t04:
   - File: `pockitflyer_app/lib/features/feed/presentation/widgets/card_header.dart`
   - This widget displays creator avatar and name
   - Currently may have placeholder navigation or no navigation

2. Implement tappable creator info in `card_header.dart`:
   - Wrap the avatar + name section in an InkWell or GestureDetector
   - Define tap target area: Row containing [Avatar, Name]
   - Exclude the Follow button from tap area (it has separate tap handler)
   - Layout structure:
     ```dart
     Row(
       children: [
         InkWell(
           onTap: () => _navigateToProfile(context, creatorId),
           child: Row(
             children: [
               CircleAvatar(...), // avatar
               SizedBox(width: 8),
               Text(creatorName), // name
             ],
           ),
         ),
         Spacer(),
         FollowButton(), // separate tap handler
       ],
     )
     ```
   - Add visual feedback: InkWell provides ripple effect on tap
   - Ensure minimum touch target size: 44×44 points for avatar + name area

3. Implement navigation function in `card_header.dart`:
   - Create method `_navigateToProfile`:
     ```dart
     void _navigateToProfile(BuildContext context, String creatorId) {
       context.go('/profile/$creatorId');
     }
     ```
   - Import go_router: `import 'package:go_router/go_router.dart';`
   - Pass creatorId as route parameter
   - Navigation should push new route onto stack (user can go back)

4. Optional: Implement hero animation for creator avatar:
   - Wrap avatar in both card_header and profile_header with Hero widget
   - Use same hero tag: `'creator-avatar-$creatorId'`
   - This creates smooth transition animation of avatar during navigation
   - In `card_header.dart`:
     ```dart
     Hero(
       tag: 'creator-avatar-$creatorId',
       child: CircleAvatar(...),
     )
     ```
   - In `profile_header.dart` (from m01-e06-t01):
     ```dart
     Hero(
       tag: 'creator-avatar-$creatorId',
       child: CircleAvatar(radius: 60, ...),
     )
     ```

5. Ensure back navigation preserves main feed state:
   - Verify go_router configuration maintains navigation stack
   - When user presses back button or swipes back, should return to feed
   - Feed state to preserve:
     - Scroll position (where user was in feed)
     - Applied filters (category, distance, etc. from m01-e03)
     - Search query (if search is active from m01-e04)
   - Test: Navigate to profile → back → verify feed is in same state
   - Use StatefulWidget for feed page with AutomaticKeepAliveClientMixin if needed to prevent rebuild

6. Implement scroll position preservation in main feed:
   - In feed page (`pockitflyer_app/lib/features/feed/presentation/pages/feed_page.dart` from m01-e02-t03)
   - Add AutomaticKeepAliveClientMixin to preserve state during navigation:
     ```dart
     class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin {
       @override
       bool get wantKeepAlive => true;

       @override
       Widget build(BuildContext context) {
         super.build(context); // Required for mixin
         return /* existing widget tree */;
       }
     }
     ```
   - This prevents feed from rebuilding when navigating away and back

7. Handle navigation errors gracefully:
   - If creatorId is null or invalid format: Log error, show snackbar, don't navigate
   - If profile route not found: go_router will handle 404, but ensure error screen exists
   - Catch any navigation exceptions:
     ```dart
     void _navigateToProfile(BuildContext context, String creatorId) {
       try {
         if (creatorId.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Invalid creator')),
           );
           return;
         }
         context.go('/profile/$creatorId');
       } catch (e) {
         // Log error
         debugPrint('Navigation error: $e');
       }
     }
     ```

8. Add visual feedback for tappable elements:
   - InkWell automatically provides ripple effect on tap
   - Consider subtle color change on pressed state
   - Ensure cursor changes to pointer on hover (web/desktop if applicable)
   - Test haptic feedback on iOS (may be automatic with InkWell)

9. Update widget tests in `pockitflyer_app/test/features/feed/presentation/widgets/card_header_test.dart`:
   - Test creator avatar + name tap triggers navigation:
     - Mock go_router navigation
     - Simulate tap on InkWell
     - Verify `context.go('/profile/$creatorId')` called with correct ID
   - Test follow button tap does NOT trigger profile navigation:
     - Tap follow button
     - Verify profile navigation NOT called
   - Test invalid creatorId handling:
     - Pass empty or null creatorId
     - Verify error handling (snackbar or no navigation)
   - Test hero animation tags are present:
     - Verify Hero widget wraps avatar
     - Verify tag matches expected format

10. Create integration test for navigation flow:
    - File: `pockitflyer_app/test/features/feed/integration/profile_navigation_test.dart`
    - Test full navigation flow:
      - Start on main feed page
      - Tap creator info on flyer card
      - Verify navigation to profile page
      - Verify correct creatorId passed
      - Press back button
      - Verify return to main feed
      - Verify feed scroll position preserved
    - Use `pumpAndSettle()` to wait for navigation animations
    - Mock API responses for feed and profile data

11. Test state preservation on back navigation:
    - Scroll feed to middle position
    - Note current scroll offset
    - Navigate to profile
    - Return to feed
    - Verify scroll offset maintained
    - Apply filter in feed
    - Navigate to profile
    - Return to feed
    - Verify filter still applied

12. Visual and interaction testing:
    - Run app on device/simulator
    - Tap various creator avatars and names
    - Verify navigation works consistently
    - Verify hero animation is smooth (if implemented)
    - Verify ripple effect on tap
    - Test rapid taps (ensure no duplicate navigation)
    - Test back button and swipe gesture
    - Verify feed state preserved after navigation

### Acceptance Criteria
- [ ] Tapping creator avatar on flyer card navigates to profile [Test: tap avatar, verify route changes]
- [ ] Tapping creator name on flyer card navigates to profile [Test: tap name, verify route changes]
- [ ] Tapping follow button does NOT navigate to profile [Test: tap follow button, verify navigation not triggered]
- [ ] Navigation passes correct creatorId to profile page [Test: verify route parameter]
- [ ] InkWell provides visual feedback (ripple) on tap [Test: visual inspection]
- [ ] Back button returns to main feed [Test: navigate to profile, press back, verify on feed]
- [ ] Swipe back gesture returns to main feed (iOS) [Test: swipe from left edge]
- [ ] Main feed scroll position preserved after navigation [Test: scroll to position, navigate away, return, verify position]
- [ ] Applied filters preserved after navigation [Test: apply filter, navigate to profile, return, verify filter active]
- [ ] Search query preserved after navigation [Test: search term, navigate away, return, verify search active]
- [ ] Hero animation transitions avatar smoothly (if implemented) [Test: visual inspection of animation]
- [ ] Invalid creatorId handled without crash [Test: empty/null creatorId, verify error handling]
- [ ] Minimum touch target size met (44×44) [Test: measure tap area]
- [ ] Widget tests pass with >85% coverage [Test: `flutter test --coverage`]
- [ ] Integration tests pass [Test: full navigation flow]

### Files to Create/Modify
- `pockitflyer_app/lib/features/feed/presentation/widgets/card_header.dart` - MODIFY: add InkWell and navigation logic
- `pockitflyer_app/lib/features/feed/presentation/pages/feed_page.dart` - MODIFY: add AutomaticKeepAliveClientMixin for state preservation
- `pockitflyer_app/lib/features/profile/presentation/widgets/profile_header.dart` - MODIFY: add Hero widget for avatar animation (optional)
- `pockitflyer_app/test/features/feed/presentation/widgets/card_header_test.dart` - MODIFY: add navigation tests
- `pockitflyer_app/test/features/feed/integration/profile_navigation_test.dart` - NEW: integration test for navigation flow

### Testing Requirements
- **Unit tests**: Navigation function with various inputs (valid ID, empty ID, null), error handling logic
- **Widget tests**: Tap gesture detection on avatar and name, navigation triggered with correct parameters, follow button isolated from profile navigation, hero tag presence
- **Integration tests**: Full navigation flow (feed → profile → back), state preservation (scroll position, filters, search), back navigation behavior (button and gesture)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter navigation best practices
- [ ] No console errors or warnings
- [ ] Visual feedback on tap is clear and responsive
- [ ] Navigation animations are smooth (no jank)
- [ ] Back navigation preserves all feed state correctly
- [ ] Touch targets meet iOS Human Interface Guidelines (44×44 min)
- [ ] Comments added for navigation logic and state preservation
- [ ] Changes committed with reference to task ID (m01-e06-t02)
- [ ] Ready for backend integration (m01-e06-t03)

## Dependencies
- Requires: m01-e02-t04 (card_header widget), m01-e02-t03 (feed page), m01-e06-t01 (profile page UI), m01-e02-t01 (app routing setup)
- Blocks: m01-e06-t03 (backend integration can now use navigation)

## Technical Notes

### Navigation with go_router
- `context.go()` replaces current route (not usually desired for this use case)
- `context.push()` pushes new route onto stack (user can go back) - use this for profile navigation
- Actually for this use case, `context.push()` is better than `context.go()`:
  ```dart
  context.push('/profile/$creatorId');
  ```
- Route parameter extraction in profile page: `state.pathParameters['creatorId']`

### State Preservation Strategies
**AutomaticKeepAliveClientMixin**:
- Prevents widget tree from being disposed when navigating away
- Maintains scroll position, controller states, local state
- Must call `super.build(context)` in build method
- Use for pages that should preserve state during navigation

**Alternative: PageStorage**:
- Automatically preserves scroll position with PageStorageKey
- Less invasive than KeepAlive
- May not preserve all state (filters, search)

For this task: Use AutomaticKeepAliveClientMixin to ensure complete state preservation.

### Hero Animation (Optional but Recommended)
Hero animations provide smooth visual continuity during navigation:
- Shared element transitions from source to destination
- Same `tag` required on both Hero widgets
- Animates size, position, and shape automatically
- Improves perceived performance and UX

Implementation is simple (wrap with Hero widget) and adds significant polish.

### Touch Target Sizing
iOS Human Interface Guidelines recommend 44×44 points minimum:
- If avatar + name area is smaller, add padding
- InkWell should cover entire tap area
- Test on actual device (simulator may not reflect real touch precision)

### Preventing Duplicate Navigation
Rapid taps can trigger multiple navigation calls:
- Use throttling or debouncing if necessary
- go_router typically handles duplicate pushes gracefully
- Test by rapidly tapping creator info
- If duplicates occur, add flag to prevent navigation while in progress

### Integration with Filter and Search State
Feed state includes:
- Scroll position (ScrollController offset)
- Applied filters (category, distance from m01-e03)
- Active search query (from m01-e04)

AutomaticKeepAliveClientMixin preserves all local state automatically. Verify with tests.

### Error Handling
- Invalid creatorId: Don't navigate, show user feedback
- Route not found: go_router handles with error screen
- Network errors: Handled by profile page (m01-e06-t01 and m01-e06-t03), not navigation logic

### Visual Feedback Best Practices
- InkWell ripple should match app theme
- Consider customizing splash color: `splashColor: Theme.of(context).primaryColor.withOpacity(0.1)`
- Ensure ripple is visible on both light and dark themes
- Ripple should not obscure avatar or name during animation

## References
- go_router navigation: https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html
- Flutter Hero animations: https://docs.flutter.dev/ui/animations/hero-animations
- AutomaticKeepAliveClientMixin: https://api.flutter.dev/flutter/widgets/AutomaticKeepAliveClientMixin-mixin.html
- InkWell widget: https://api.flutter.dev/flutter/material/InkWell-class.html
- iOS Human Interface Guidelines (Touch targets): https://developer.apple.com/design/human-interface-guidelines/layout
- PageStorage: https://api.flutter.dev/flutter/widgets/PageStorage-class.html
