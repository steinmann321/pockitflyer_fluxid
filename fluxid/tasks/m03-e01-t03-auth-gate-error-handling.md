---
id: m03-e01-t03
title: Auth Gate and Error Handling Integration
epic: m03-e01
milestone: m03
status: pending
---

# Task: Auth Gate and Error Handling Integration

## Context
Part of Flyer Favorites (m03-e01) in Milestone 3.

Implements authentication gating for anonymous users attempting to favorite flyers, comprehensive error handling for network failures, and state persistence across app sessions. This ensures a smooth user experience with clear guidance for unauthenticated users and graceful degradation for errors.

## Implementation Guide for LLM Agent

### Objective
Create auth gate dialog for anonymous users, implement comprehensive error handling with user feedback, and ensure favorite state persists across app sessions.

### Steps
1. Create auth gate dialog component
   - Create new file `pockitflyer_app/lib/widgets/auth_gate_dialog.dart`
   - Define `AuthGateDialog` stateless widget:
     - Title: "Sign in to save favorites"
     - Message: "Create an account or sign in to save flyers you love and access them anytime."
     - Primary button: "Sign In" (navigates to login screen)
     - Secondary button: "Create Account" (navigates to registration screen)
     - Tertiary button: "Not Now" (closes dialog)
   - Style: Material Design bottom sheet or centered dialog (match app design)
   - Return navigation result to indicate user choice

2. Implement auth gate logic in FavoriteButton
   - Modify `pockitflyer_app/lib/widgets/favorite_button.dart`
   - In `onTap` handler:
     ```dart
     Future<void> _handleTap() async {
       // Check authentication state
       final authState = Provider.of<AuthProvider>(context, listen: false);

       if (!authState.isAuthenticated) {
         // Show auth gate dialog
         final result = await showModalBottomSheet(
           context: context,
           builder: (context) => AuthGateDialog(),
         );

         // Handle user choice
         if (result == AuthGateResult.signIn) {
           Navigator.pushNamed(context, '/login', arguments: {
             'returnTo': '/flyers', // Return to flyer feed after login
             'message': 'Sign in to save this flyer'
           });
         } else if (result == AuthGateResult.signUp) {
           Navigator.pushNamed(context, '/register', arguments: {
             'returnTo': '/flyers',
             'message': 'Create an account to save flyers'
           });
         }
         // If "Not Now", do nothing (dialog closes)
         return;
       }

       // User is authenticated, proceed with favorite
       final isFavorited = favoriteProvider.isFavorited(widget.flyerId);
       await favoriteProvider.toggleFavorite(widget.flyerId, isFavorited);
     }
     ```

3. Implement error feedback system
   - Create new file `pockitflyer_app/lib/utils/error_handler.dart`
   - Define `ErrorHandler` class with static methods:
     - `showErrorSnackBar(BuildContext context, String message, {Duration? duration})`:
       - Display SnackBar with error message
       - Red/error color scheme
       - Duration: 3 seconds (default)
       - Action button: "Dismiss"
     - `showRetrySnackBar(BuildContext context, String message, VoidCallback onRetry)`:
       - Display SnackBar with error message and retry button
       - Action button: "Retry" (calls onRetry callback)
   - Define user-friendly error messages:
     - Network timeout: "Connection timeout. Please check your internet."
     - 401 Unauthorized: "Session expired. Please sign in again."
     - 404 Not found: "Flyer not found."
     - 500 Server error: "Something went wrong. Please try again."
     - Generic: "Unable to update favorite. Please try again."

4. Enhance FavoriteNotifier with error handling
   - Modify `pockitflyer_app/lib/providers/favorite_provider.dart`
   - Update `toggleFavorite` method:
     ```dart
     Future<void> toggleFavorite(int flyerId, bool isFavorited, BuildContext context) async {
       // Store previous state for rollback
       final previousState = Set<int>.from(favoritedFlyerIds);

       // Optimistic update
       if (isFavorited) {
         favoritedFlyerIds.remove(flyerId);
       } else {
         favoritedFlyerIds.add(flyerId);
       }
       notifyListeners();

       // API call with error handling
       try {
         bool success;
         if (isFavorited) {
           success = await _favoriteService.unfavoriteFlyer(flyerId);
         } else {
           success = await _favoriteService.favoriteFlyer(flyerId);
         }

         if (!success) {
           throw Exception("API returned false");
         }
       } on TimeoutException {
         _rollbackAndShowError(previousState, context, "Connection timeout. Please check your internet.");
       } on UnauthorizedException {
         _rollbackAndShowError(previousState, context, "Session expired. Please sign in again.");
         // Optionally trigger logout
       } on NotFoundException {
         _rollbackAndShowError(previousState, context, "Flyer not found.");
       } catch (e) {
         _rollbackAndShowError(previousState, context, "Unable to update favorite. Please try again.");
       }
     }

     void _rollbackAndShowError(Set<int> previousState, BuildContext context, String message) {
       favoritedFlyerIds = previousState;
       notifyListeners();
       ErrorHandler.showErrorSnackBar(context, message);
     }
     ```

5. Implement state persistence across sessions
   - Use local storage (SharedPreferences) to persist favorite state
   - Modify `pockitflyer_app/lib/providers/favorite_provider.dart`:
     - Add `Future<void> _saveFavoritesToLocal()` method:
       - Convert `favoritedFlyerIds` to JSON list
       - Save to SharedPreferences with key "favorited_flyer_ids"
     - Add `Future<void> _loadFavoritesFromLocal()` method:
       - Load from SharedPreferences
       - Parse JSON list to Set<int>
       - Set `favoritedFlyerIds` state
     - Call `_saveFavoritesToLocal()` after every successful favorite/unfavorite
     - Call `_loadFavoritesFromLocal()` in provider initialization
   - On app launch:
     - Load favorites from local storage immediately (instant UI)
     - Fetch fresh favorites from API in background
     - Merge/reconcile local and remote state if differences found

6. Handle return navigation after login
   - Modify login/registration screens (if not already implemented):
     - Check for `returnTo` and `message` arguments
     - Display message to user if provided
     - After successful login, navigate to `returnTo` route
   - Test flow: anonymous user → tap favorite → see auth gate → sign in → return to flyer feed → favorite persisted

7. Create comprehensive test suite
   - Create new file `pockitflyer_app/test/widgets/auth_gate_dialog_test.dart`
   - **Widget tests**:
     - Dialog renders with correct title and message
     - "Sign In" button navigates to login
     - "Create Account" button navigates to registration
     - "Not Now" button closes dialog
   - Modify `pockitflyer_app/test/widgets/favorite_button_test.dart`
   - **Auth gate tests**:
     - Tapping favorite button when anonymous shows auth gate dialog
     - Tapping favorite button when authenticated calls API
     - Selecting "Sign In" navigates to login with correct arguments
     - Selecting "Not Now" closes dialog without navigation
   - Modify `pockitflyer_app/test/providers/favorite_provider_test.dart`
   - **Error handling tests**:
     - TimeoutException triggers rollback and error message
     - UnauthorizedException triggers rollback and error message
     - NotFoundException triggers rollback and error message
     - Generic exception triggers rollback and error message
   - **Persistence tests**:
     - Favorites saved to local storage after successful toggle
     - Favorites loaded from local storage on initialization
     - Local and remote state reconciled on app launch

### Acceptance Criteria
- [ ] Anonymous users see auth gate dialog when tapping favorite button [Test: tap favorite without auth, verify dialog shown]
- [ ] Auth gate dialog has "Sign In", "Create Account", "Not Now" options [Test: render dialog, verify all buttons present]
- [ ] "Sign In" navigates to login with return route [Test: tap sign in, verify navigation with arguments]
- [ ] "Create Account" navigates to registration with return route [Test: tap create account, verify navigation]
- [ ] "Not Now" closes dialog without action [Test: tap not now, verify dialog dismissed]
- [ ] Network timeout shows user-friendly error and rolls back UI [Test: mock timeout, verify error message and state rollback]
- [ ] 401 Unauthorized shows error and rolls back UI [Test: mock 401, verify error message]
- [ ] 404 Not found shows error and rolls back UI [Test: mock 404, verify error message]
- [ ] Generic errors show fallback message and roll back UI [Test: mock unknown error, verify fallback message]
- [ ] Favorites persist across app sessions [Test: favorite flyer, restart app, verify still favorited]
- [ ] Local storage syncs with API on app launch [Test: modify local storage, launch app, verify API fetch reconciles state]
- [ ] Return navigation works after login [Test: auth gate → login → return to flyer feed]
- [ ] All tests pass with >85% coverage [Run: flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/widgets/auth_gate_dialog.dart` - NEW: auth gate dialog component
- `pockitflyer_app/lib/widgets/favorite_button.dart` - MODIFY: integrate auth gate logic
- `pockitflyer_app/lib/utils/error_handler.dart` - NEW: error feedback utilities
- `pockitflyer_app/lib/providers/favorite_provider.dart` - MODIFY: error handling and persistence
- `pockitflyer_app/lib/screens/login_screen.dart` - MODIFY: handle return navigation (adjust path to actual login screen)
- `pockitflyer_app/lib/screens/register_screen.dart` - MODIFY: handle return navigation (adjust path to actual registration screen)
- `pockitflyer_app/test/widgets/auth_gate_dialog_test.dart` - NEW: auth gate dialog tests
- `pockitflyer_app/test/widgets/favorite_button_test.dart` - MODIFY: add auth gate tests
- `pockitflyer_app/test/providers/favorite_provider_test.dart` - MODIFY: add error handling and persistence tests
- `pubspec.yaml` - MODIFY: add `shared_preferences` dependency if not present

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - ErrorHandler methods with mocked context
  - FavoriteNotifier error handling with mocked service
  - Local storage persistence (save/load)
- **Widget tests**:
  - AuthGateDialog rendering and interactions
  - FavoriteButton with authenticated/anonymous users
  - Error SnackBar display
- **Integration tests**:
  - Full auth gate flow: anonymous user → dialog → navigation
  - Full error flow: API failure → rollback → error message
  - Full persistence flow: favorite → save → restart → load

### Definition of Done
- [ ] Code written and passes all tests (>85% coverage)
- [ ] Auth gate dialog implemented and functional
- [ ] Error handling covers all scenarios (timeout, 401, 404, generic)
- [ ] Favorites persist across app sessions
- [ ] Return navigation after login works
- [ ] User-friendly error messages displayed
- [ ] Code follows Flutter/Dart conventions
- [ ] No console errors or warnings
- [ ] Changes committed with reference to task ID (m03-e01-t03)
- [ ] Epic m03-e01 complete and ready for validation

## Dependencies
- Requires: m03-e01-t01 (Backend API endpoints)
- Requires: m03-e01-t02 (Frontend favorite button)
- Requires: M02 (User authentication) - auth state provider, login/registration screens must exist

## Technical Notes
**Auth State Detection**:
- Use existing auth state provider from M02
- Check `isAuthenticated` property before favorite operations
- Typical implementation: `final authState = Provider.of<AuthProvider>(context, listen: false);`

**Navigation with Arguments**:
- Use `Navigator.pushNamed(context, route, arguments: {...})`
- Login/registration screens should check for `arguments` on route
- After successful auth, navigate to `returnTo` route with `Navigator.pushReplacementNamed`

**Error Message UX**:
- Use SnackBar for non-critical errors (doesn't block UI)
- Keep messages short and actionable
- Avoid technical jargon (e.g., "500 error" → "Something went wrong")
- Provide retry option when appropriate

**State Persistence**:
- Use `shared_preferences` package for local storage
- Store favorites as JSON list: `["123", "456", "789"]` (string IDs)
- Load local state synchronously on app launch for instant UI
- Fetch from API asynchronously in background
- Reconcile differences: API is source of truth, update local if mismatch

**Reconciliation Strategy**:
- On app launch: load local → show UI → fetch API → compare → update if different
- If API returns different favorites: update local storage and UI
- Handle edge case: user favorited offline, then goes online (requires conflict resolution)

**Performance Considerations**:
- Auth gate check: synchronous, no API call (< 10ms)
- Local storage load: synchronous, fast (< 50ms)
- API sync in background: don't block UI

**Accessibility**:
- Ensure dialog is screen-reader accessible
- Provide clear labels for buttons
- Error messages should be announced to screen readers

**Offline Behavior** (optional enhancement):
- Queue favorite operations when offline
- Sync when connection restored
- Show indicator when operating in offline mode

## References
- Flutter SharedPreferences: https://pub.dev/packages/shared_preferences
- Flutter SnackBar: https://api.flutter.dev/flutter/material/SnackBar-class.html
- Flutter Navigator Arguments: https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
- Material Design Dialogs: https://m3.material.io/components/dialogs
