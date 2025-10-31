---
id: m03-e01-t02
title: Frontend Favorite Button Component with State Management
epic: m03-e01
milestone: m03
status: pending
---

# Task: Frontend Favorite Button Component with State Management

## Context
Part of Flyer Favorites (m03-e01) in Milestone 3.

Implements the UI component for favoriting flyers with visual state management, optimistic updates, and API integration. Users tap a heart icon on flyer cards to favorite/unfavorite, with instant visual feedback and backend synchronization.

## Implementation Guide for LLM Agent

### Objective
Create favorite button widget with heart icon, visual state indicators, optimistic UI updates, API integration, and rollback on failure.

### Steps
1. Create API service for favorite operations
   - Create new file `pockitflyer_app/lib/services/favorite_service.dart`
   - Define `FavoriteService` class:
     - Method `Future<bool> favoriteFlyer(int flyerId)` - POST to `/api/flyers/{id}/favorite/`
     - Method `Future<bool> unfavoriteFlyer(int flyerId)` - DELETE to `/api/flyers/{id}/favorite/`
     - Method `Future<List<Favorite>> getUserFavorites()` - GET `/api/users/me/favorites/`
   - Include JWT token in Authorization header for all requests
   - Handle HTTP errors: 401 (unauthorized), 404 (not found), 500 (server error)
   - Return `true` on success, `false` on failure
   - Timeout: 5 seconds per request

2. Create Favorite data model
   - Create new file `pockitflyer_app/lib/models/favorite.dart`
   - Define `Favorite` class:
     - Fields: `int id`, `int flyerId`, `DateTime createdAt`
     - Factory constructor `Favorite.fromJson(Map<String, dynamic> json)`
     - Method `Map<String, dynamic> toJson()`

3. Create favorite state provider/notifier
   - Create new file `pockitflyer_app/lib/providers/favorite_provider.dart`
   - Use state management solution (Provider, Riverpod, Bloc - match existing pattern in codebase)
   - Define `FavoriteState`:
     - `Set<int> favoritedFlyerIds` - set of flyer IDs user has favorited
     - `bool isLoading` - loading state for initial fetch
   - Define state management class (e.g., `FavoriteNotifier`):
     - Method `Future<void> loadFavorites()` - fetch user favorites from API
     - Method `Future<void> toggleFavorite(int flyerId, bool currentState)`:
       - **Optimistic update**: immediately update `favoritedFlyerIds` in state
       - Call API (favorite or unfavorite based on currentState)
       - **On success**: keep optimistic state
       - **On failure**: rollback state to previous value, show error
     - Method `bool isFavorited(int flyerId)` - check if flyer is favorited

4. Create FavoriteButton widget
   - Create new file `pockitflyer_app/lib/widgets/favorite_button.dart`
   - Define `FavoriteButton` stateless widget:
     - Props: `int flyerId`, `VoidCallback? onAuthRequired` (callback for anonymous users)
     - Use favorite provider to get current state
     - Render heart icon:
       - **Unfavorited state**: outline heart icon (e.g., `Icons.favorite_border`)
       - **Favorited state**: filled heart icon (e.g., `Icons.favorite`)
       - Color: unfavorited (gray/black), favorited (red/pink)
       - Size: 24-28dp (touch target at least 48x48dp)
     - On tap:
       - Check if user is authenticated (check auth state from auth provider)
       - If anonymous: call `onAuthRequired()` callback (handled in t03)
       - If authenticated: call `favoriteProvider.toggleFavorite(flyerId, currentState)`
     - Show loading indicator during API call (optional: small spinner overlay)
     - Add haptic feedback on tap (iOS: light impact)

5. Integrate FavoriteButton into existing flyer cards
   - Locate existing flyer card component (search for flyer card/list widget)
   - Add `FavoriteButton` to flyer card layout:
     - Position: top-right corner of flyer card (absolute/stack positioning)
     - z-index above card content
     - Padding: 8-12dp from edges
   - Pass `flyerId` prop from flyer data
   - Pass `onAuthRequired` callback (will be implemented in t03)

6. Implement optimistic UI update with rollback
   - In `FavoriteNotifier.toggleFavorite`:
     ```dart
     Future<void> toggleFavorite(int flyerId, bool isFavorited) async {
       // Store previous state for rollback
       final previousState = Set<int>.from(favoritedFlyerIds);

       // Optimistic update
       if (isFavorited) {
         favoritedFlyerIds.remove(flyerId);
       } else {
         favoritedFlyerIds.add(flyerId);
       }
       notifyListeners(); // Update UI immediately

       // API call
       bool success;
       try {
         if (isFavorited) {
           success = await _favoriteService.unfavoriteFlyer(flyerId);
         } else {
           success = await _favoriteService.favoriteFlyer(flyerId);
         }
       } catch (e) {
         success = false;
       }

       // Rollback on failure
       if (!success) {
         favoritedFlyerIds = previousState;
         notifyListeners(); // Revert UI
         _showErrorMessage("Failed to update favorite"); // Show error to user
       }
     }
     ```

7. Create comprehensive test suite
   - Create new file `pockitflyer_app/test/widgets/favorite_button_test.dart`
   - **Widget tests**:
     - Renders outline heart when not favorited
     - Renders filled heart when favorited
     - Tapping button toggles visual state immediately (< 100ms)
     - Shows loading indicator during API call (optional)
     - Calls onAuthRequired callback for anonymous users
   - Create new file `pockitflyer_app/test/providers/favorite_provider_test.dart`
   - **State management tests**:
     - loadFavorites() fetches and stores favorites
     - toggleFavorite() updates state optimistically
     - toggleFavorite() rolls back on API failure
     - isFavorited() returns correct state
   - Create new file `pockitflyer_app/test/services/favorite_service_test.dart`
   - **Service tests** (mock HTTP client):
     - favoriteFlyer() sends correct POST request with auth header
     - unfavoriteFlyer() sends correct DELETE request
     - getUserFavorites() parses response correctly
     - Handles 401, 404, 500 errors gracefully
     - Timeout after 5 seconds

### Acceptance Criteria
- [ ] FavoriteButton renders outline heart when not favorited [Test: widget renders with isFavorited=false]
- [ ] FavoriteButton renders filled heart when favorited [Test: widget renders with isFavorited=true]
- [ ] Tapping button updates UI within 100ms (optimistic) [Test: measure time from tap to visual change]
- [ ] Successful API call persists favorite state [Test: mock API success, verify state maintained]
- [ ] Failed API call rolls back UI to previous state [Test: mock API failure, verify state reverts]
- [ ] Anonymous users trigger onAuthRequired callback [Test: tap button without auth, verify callback called]
- [ ] Authenticated users call favorite API [Test: tap button with auth, verify API method called]
- [ ] Button integrated into flyer cards [Test: flyer card contains FavoriteButton in top-right]
- [ ] Haptic feedback on tap (iOS) [Test: verify haptic feedback triggered]
- [ ] All tests pass with >85% coverage [Run: flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/services/favorite_service.dart` - NEW: API service for favorite operations
- `pockitflyer_app/lib/models/favorite.dart` - NEW: Favorite data model
- `pockitflyer_app/lib/providers/favorite_provider.dart` - NEW: State management for favorites
- `pockitflyer_app/lib/widgets/favorite_button.dart` - NEW: Favorite button widget
- `pockitflyer_app/lib/widgets/flyer_card.dart` - MODIFY: integrate FavoriteButton (adjust path to actual flyer card widget)
- `pockitflyer_app/test/widgets/favorite_button_test.dart` - NEW: widget tests
- `pockitflyer_app/test/providers/favorite_provider_test.dart` - NEW: state management tests
- `pockitflyer_app/test/services/favorite_service_test.dart` - NEW: service tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - FavoriteService API methods with mocked HTTP client
  - Favorite model JSON serialization/deserialization
  - FavoriteNotifier state transitions with mocked service
- **Widget tests**:
  - FavoriteButton visual states (filled/unfilled heart)
  - FavoriteButton tap interactions
  - FavoriteButton with authenticated/anonymous users
- **Integration tests**:
  - Full favorite flow: tap → optimistic update → API call → success/failure
  - Rollback on failure scenario
  - State persistence across widget rebuilds

### Definition of Done
- [ ] Code written and passes all tests (>85% coverage)
- [ ] FavoriteButton integrated into flyer cards
- [ ] Optimistic UI updates work correctly
- [ ] Rollback on failure tested and working
- [ ] Visual states (heart icons) render correctly
- [ ] Code follows Flutter/Dart conventions
- [ ] No console errors or warnings
- [ ] Changes committed with reference to task ID (m03-e01-t02)
- [ ] Ready for auth gate integration (m03-e01-t03)

## Dependencies
- Requires: m03-e01-t01 (Backend API endpoints must exist)
- Requires: M02 (User authentication) - auth state provider must exist
- Blocks: m03-e01-t03 (Auth gate integration)

## Technical Notes
**State Management**:
- Match existing state management pattern in codebase (Provider, Riverpod, Bloc, etc.)
- Use `Set<int>` for favoritedFlyerIds for O(1) lookup performance
- State should be accessible globally (singleton or provider at app root)

**Optimistic UI Pattern**:
- CRITICAL: Update UI BEFORE API call for instant feedback (< 100ms target)
- Store previous state before optimistic update for rollback
- On failure: revert to previous state AND show error message to user
- Performance target: Visual feedback < 100ms, Rollback < 200ms

**Visual Design**:
- Use Flutter's built-in Icons (Icons.favorite, Icons.favorite_border)
- Unfavorited: outline heart, gray/black color
- Favorited: filled heart, red/pink color (#E91E63 or similar)
- Ensure touch target is at least 48x48dp for accessibility
- Add subtle animation on state change (optional: scale or fade)

**API Integration**:
- Extract JWT token from auth state/provider
- Include in Authorization header: `Bearer {token}`
- Handle 401 Unauthorized: trigger logout or token refresh
- Handle network errors: show user-friendly error message
- Timeout: 5 seconds per request to prevent hanging

**Positioning on Flyer Cards**:
- Use Stack widget to overlay button on card
- Position in top-right corner with padding
- Ensure button doesn't interfere with other card interactions
- Add semi-transparent background (optional) for better visibility

**Haptic Feedback**:
- Use `HapticFeedback.lightImpact()` on tap (iOS)
- Improves tactile experience for users

**Error Handling**:
- Show SnackBar or Toast for errors (non-blocking)
- Don't prevent user from continuing to browse
- Consider retry mechanism for network failures (optional)

## References
- Flutter State Management: https://docs.flutter.dev/data-and-backend/state-mgmt
- Flutter Icons: https://api.flutter.dev/flutter/material/Icons-class.html
- Flutter HapticFeedback: https://api.flutter.dev/flutter/services/HapticFeedback-class.html
- Optimistic UI Pattern: https://www.apollographql.com/docs/react/performance/optimistic-ui/
