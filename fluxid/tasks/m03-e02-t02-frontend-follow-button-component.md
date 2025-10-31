---
id: m03-e02-t02
title: Frontend Follow Button Component with State Management
epic: m03-e02
milestone: m03
status: pending
---

# Task: Frontend Follow Button Component with State Management

## Context
Part of Creator Following (m03-e02) in Milestone 3.

Implements the UI component for following creators with visual state management, optimistic updates, and API integration. Users tap a follow button on flyer cards (positioned near creator information) to follow/unfollow creators, with instant visual feedback and backend synchronization.

## Implementation Guide for LLM Agent

### Objective
Create follow button widget with visual state indicators (Follow/Following), optimistic UI updates, API integration, and rollback on failure.

### Steps
1. Create API service for follow operations
   - Create new file `pockitflyer_app/lib/services/follow_service.dart`
   - Define `FollowService` class:
     - Method `Future<bool> followUser(int userId)` - POST to `/api/users/{id}/follow/`
     - Method `Future<bool> unfollowUser(int userId)` - DELETE to `/api/users/{id}/follow/`
     - Method `Future<List<Follow>> getFollowing()` - GET `/api/users/me/following/`
   - Include JWT token in Authorization header for all requests
   - Handle HTTP errors: 401 (unauthorized), 404 (not found), 400 (self-follow), 500 (server error)
   - Return `true` on success, `false` on failure
   - Timeout: 5 seconds per request

2. Create Follow data model
   - Create new file `pockitflyer_app/lib/models/follow.dart`
   - Define `Follow` class:
     - Fields: `int id`, `int followeeId`, `String followeeEmail`, `String followeeName`, `DateTime createdAt`
     - Factory constructor `Follow.fromJson(Map<String, dynamic> json)`
     - Method `Map<String, dynamic> toJson()`

3. Create follow state provider/notifier
   - Create new file `pockitflyer_app/lib/providers/follow_provider.dart`
   - Use state management solution (Provider, Riverpod, Bloc - match existing pattern in codebase)
   - Define `FollowState`:
     - `Set<int> followedUserIds` - set of user IDs current user follows
     - `bool isLoading` - loading state for initial fetch
   - Define state management class (e.g., `FollowNotifier`):
     - Method `Future<void> loadFollowing()` - fetch following list from API
     - Method `Future<void> toggleFollow(int userId, bool currentState)`:
       - **Optimistic update**: immediately update `followedUserIds` in state
       - Call API (follow or unfollow based on currentState)
       - **On success**: keep optimistic state
       - **On failure**: rollback state to previous value, show error
     - Method `bool isFollowing(int userId)` - check if user is followed

4. Create FollowButton widget
   - Create new file `pockitflyer_app/lib/widgets/follow_button.dart`
   - Define `FollowButton` stateless widget:
     - Props: `int userId`, `VoidCallback? onAuthRequired` (callback for anonymous users)
     - Use follow provider to get current state
     - Render button with text:
       - **Not following state**: "Follow" button
         - Style: outlined button or primary color background
         - Text: "Follow"
         - Icon (optional): person_add icon
       - **Following state**: "Following" button
         - Style: subtle/secondary background (gray or light color)
         - Text: "Following"
         - Icon (optional): check icon
     - On tap:
       - Check if user is authenticated (check auth state from auth provider)
       - If anonymous: call `onAuthRequired()` callback (handled in t03)
       - If authenticated: call `followProvider.toggleFollow(userId, currentState)`
     - Show loading indicator during API call (optional: small spinner or disabled state)
     - Add haptic feedback on tap (iOS: light impact)
     - Size: Compact button (height: 32-36dp, padding: 8-16dp horizontal)

5. Integrate FollowButton into existing flyer cards
   - Locate existing flyer card component (search for flyer card/list widget)
   - Identify where creator information is displayed (creator name, avatar, etc.)
   - Add `FollowButton` near creator information:
     - Position: Next to creator name or avatar (horizontal layout)
     - Alignment: Right-aligned or inline with creator info
     - Spacing: 8-12dp margin from creator name
   - Pass `userId` prop from flyer's creator ID
   - Pass `onAuthRequired` callback (will be implemented in t03)
   - Ensure button doesn't interfere with other card interactions

6. Implement optimistic UI update with rollback
   - In `FollowNotifier.toggleFollow`:
     ```dart
     Future<void> toggleFollow(int userId, bool isFollowing) async {
       // Store previous state for rollback
       final previousState = Set<int>.from(followedUserIds);

       // Optimistic update
       if (isFollowing) {
         followedUserIds.remove(userId);
       } else {
         followedUserIds.add(userId);
       }
       notifyListeners(); // Update UI immediately

       // API call
       bool success;
       try {
         if (isFollowing) {
           success = await _followService.unfollowUser(userId);
         } else {
           success = await _followService.followUser(userId);
         }
       } catch (e) {
         success = false;
       }

       // Rollback on failure
       if (!success) {
         followedUserIds = previousState;
         notifyListeners(); // Revert UI
         _showErrorMessage("Failed to update follow status"); // Show error to user
       }
     }
     ```

7. Create comprehensive test suite
   - Create new file `pockitflyer_app/test/widgets/follow_button_test.dart`
   - **Widget tests**:
     - Renders "Follow" button when not following
     - Renders "Following" button when following
     - Tapping button toggles visual state immediately (< 100ms)
     - Shows loading indicator during API call (optional)
     - Calls onAuthRequired callback for anonymous users
     - Button is compact and properly sized
   - Create new file `pockitflyer_app/test/providers/follow_provider_test.dart`
   - **State management tests**:
     - loadFollowing() fetches and stores follows
     - toggleFollow() updates state optimistically
     - toggleFollow() rolls back on API failure
     - isFollowing() returns correct state
   - Create new file `pockitflyer_app/test/services/follow_service_test.dart`
   - **Service tests** (mock HTTP client):
     - followUser() sends correct POST request with auth header
     - unfollowUser() sends correct DELETE request
     - getFollowing() parses response correctly
     - Handles 401, 404, 400, 500 errors gracefully
     - Timeout after 5 seconds

### Acceptance Criteria
- [ ] FollowButton renders "Follow" when not following [Test: widget renders with isFollowing=false]
- [ ] FollowButton renders "Following" when following [Test: widget renders with isFollowing=true]
- [ ] Tapping button updates UI within 100ms (optimistic) [Test: measure time from tap to visual change]
- [ ] Successful API call persists follow state [Test: mock API success, verify state maintained]
- [ ] Failed API call rolls back UI to previous state [Test: mock API failure, verify state reverts]
- [ ] Anonymous users trigger onAuthRequired callback [Test: tap button without auth, verify callback called]
- [ ] Authenticated users call follow API [Test: tap button with auth, verify API method called]
- [ ] Button integrated into flyer cards near creator info [Test: flyer card contains FollowButton near creator name/avatar]
- [ ] Haptic feedback on tap (iOS) [Test: verify haptic feedback triggered]
- [ ] Button is compact and doesn't interfere with card layout [Test: visual inspection, height 32-36dp]
- [ ] All tests pass with >85% coverage [Run: flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/services/follow_service.dart` - NEW: API service for follow operations
- `pockitflyer_app/lib/models/follow.dart` - NEW: Follow data model
- `pockitflyer_app/lib/providers/follow_provider.dart` - NEW: State management for follows
- `pockitflyer_app/lib/widgets/follow_button.dart` - NEW: Follow button widget
- `pockitflyer_app/lib/widgets/flyer_card.dart` - MODIFY: integrate FollowButton near creator info (adjust path to actual flyer card widget)
- `pockitflyer_app/test/widgets/follow_button_test.dart` - NEW: widget tests
- `pockitflyer_app/test/providers/follow_provider_test.dart` - NEW: state management tests
- `pockitflyer_app/test/services/follow_service_test.dart` - NEW: service tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - FollowService API methods with mocked HTTP client
  - Follow model JSON serialization/deserialization
  - FollowNotifier state transitions with mocked service
- **Widget tests**:
  - FollowButton visual states (Follow/Following text)
  - FollowButton tap interactions
  - FollowButton with authenticated/anonymous users
  - Button sizing and layout
- **Integration tests**:
  - Full follow flow: tap → optimistic update → API call → success/failure
  - Rollback on failure scenario
  - State persistence across widget rebuilds

### Definition of Done
- [ ] Code written and passes all tests (>85% coverage)
- [ ] FollowButton integrated into flyer cards near creator info
- [ ] Optimistic UI updates work correctly
- [ ] Rollback on failure tested and working
- [ ] Visual states (Follow/Following) render correctly
- [ ] Button is compact and well-positioned
- [ ] Code follows Flutter/Dart conventions
- [ ] No console errors or warnings
- [ ] Changes committed with reference to task ID (m03-e02-t02)
- [ ] Ready for auth gate integration (m03-e02-t03)

## Dependencies
- Requires: m03-e02-t01 (Backend API endpoints must exist)
- Requires: M02 (User authentication) - auth state provider must exist
- Requires: M01 (Browse flyers) - flyer cards must display creator information
- Blocks: m03-e02-t03 (Auth gate integration)

## Technical Notes
**State Management**:
- Match existing state management pattern in codebase (Provider, Riverpod, Bloc, etc.)
- Use `Set<int>` for followedUserIds for O(1) lookup performance
- State should be accessible globally (singleton or provider at app root)

**Optimistic UI Pattern**:
- CRITICAL: Update UI BEFORE API call for instant feedback (< 100ms target)
- Store previous state before optimistic update for rollback
- On failure: revert to previous state AND show error message to user
- Performance target: Visual feedback < 100ms, Rollback < 200ms

**Visual Design**:
- Not following state:
  - Text: "Follow"
  - Style: Primary color or outlined button
  - Optional icon: Icons.person_add
- Following state:
  - Text: "Following"
  - Style: Subtle/secondary background (gray, light blue)
  - Optional icon: Icons.check
- Size: Compact (height 32-36dp, horizontal padding 8-16dp)
- Ensure button is visually distinct but not overwhelming
- Add subtle animation on state change (optional: scale or fade)

**Positioning on Flyer Cards**:
- Position near creator information (name, avatar, etc.)
- Use Row or Flex layout to align with creator info
- Right-align button or place inline after creator name
- Ensure adequate spacing (8-12dp margin)
- Don't obstruct other interactive elements (like favorite button, card tap)

**API Integration**:
- Extract JWT token from auth state/provider
- Include in Authorization header: `Bearer {token}`
- Handle 401 Unauthorized: trigger logout or token refresh
- Handle 400 Bad Request (self-follow): show error "Cannot follow yourself"
- Handle network errors: show user-friendly error message
- Timeout: 5 seconds per request to prevent hanging

**Haptic Feedback**:
- Use `HapticFeedback.lightImpact()` on tap (iOS)
- Improves tactile experience for users

**Error Handling**:
- Show SnackBar or Toast for errors (non-blocking)
- Don't prevent user from continuing to browse
- Consider retry mechanism for network failures (optional)

**Differences from Favorites (m03-e01-t02)**:
- Button instead of icon (text: "Follow"/"Following" vs heart icon)
- Positioned near creator info instead of top-right corner
- User-User relationship instead of User-Flyer
- Self-follow prevention error handling (400 error)

**Self-Follow Prevention**:
- Backend prevents self-follows (returns 400)
- Frontend should handle this gracefully: show error message
- Consider hiding follow button on user's own content (optional UI enhancement)

## References
- Flutter State Management: https://docs.flutter.dev/data-and-backend/state-mgmt
- Flutter HapticFeedback: https://api.flutter.dev/flutter/services/HapticFeedback-class.html
- Optimistic UI Pattern: https://www.apollographql.com/docs/react/performance/optimistic-ui/
- Material Design Buttons: https://m3.material.io/components/buttons
