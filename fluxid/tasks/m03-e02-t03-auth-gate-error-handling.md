---
id: m03-e02-t03
title: Auth Gate and Error Handling Integration
epic: m03-e02
milestone: m03
status: pending
---

# Task: Auth Gate and Error Handling Integration

## Context
Part of Creator Following (m03-e02) in Milestone 3.

Implements authentication gating for anonymous users attempting to follow creators, comprehensive error handling for network failures and self-follow attempts, and state persistence across app sessions. This ensures a smooth user experience with clear guidance for unauthenticated users and graceful degradation for errors.

## Implementation Guide for LLM Agent

### Objective
Reuse auth gate dialog from favorites (m03-e01-t03), integrate it into FollowButton, implement comprehensive error handling including self-follow prevention, and ensure follow state persists across app sessions.

### Steps
1. Reuse existing auth gate dialog component
   - Auth gate dialog already exists from m03-e01-t03: `pockitflyer_app/lib/widgets/auth_gate_dialog.dart`
   - No need to recreate - just import and use it
   - If the dialog doesn't exist yet (m03-e01 not completed), create it following the same pattern:
     - Title: "Sign in to follow creators"
     - Message: "Create an account or sign in to follow creators and stay updated on their latest flyers."
     - Primary button: "Sign In" (navigates to login screen)
     - Secondary button: "Create Account" (navigates to registration screen)
     - Tertiary button: "Not Now" (closes dialog)

2. Implement auth gate logic in FollowButton
   - Modify `pockitflyer_app/lib/widgets/follow_button.dart`
   - In `onTap` handler:
     ```dart
     Future<void> _handleTap() async {
       // Check authentication state
       final authState = Provider.of<AuthProvider>(context, listen: false);

       if (!authState.isAuthenticated) {
         // Show auth gate dialog
         final result = await showModalBottomSheet(
           context: context,
           builder: (context) => AuthGateDialog(
             title: "Sign in to follow creators",
             message: "Create an account or sign in to follow creators and stay updated on their latest flyers.",
           ),
         );

         // Handle user choice
         if (result == AuthGateResult.signIn) {
           Navigator.pushNamed(context, '/login', arguments: {
             'returnTo': '/flyers', // Return to flyer feed after login
             'message': 'Sign in to follow this creator'
           });
         } else if (result == AuthGateResult.signUp) {
           Navigator.pushNamed(context, '/register', arguments: {
             'returnTo': '/flyers',
             'message': 'Create an account to follow creators'
           });
         }
         // If "Not Now", do nothing (dialog closes)
         return;
       }

       // User is authenticated, proceed with follow
       final isFollowing = followProvider.isFollowing(widget.userId);
       await followProvider.toggleFollow(widget.userId, isFollowing, context);
     }
     ```

3. Reuse or create error handler utility
   - Error handler may already exist from m03-e01-t03: `pockitflyer_app/lib/utils/error_handler.dart`
   - If it exists, reuse it. If not, create it with:
     - `showErrorSnackBar(BuildContext context, String message, {Duration? duration})`:
       - Display SnackBar with error message
       - Red/error color scheme
       - Duration: 3 seconds (default)
       - Action button: "Dismiss"
     - `showRetrySnackBar(BuildContext context, String message, VoidCallback onRetry)`:
       - Display SnackBar with error message and retry button
       - Action button: "Retry" (calls onRetry callback)
   - Add follow-specific error messages:
     - Network timeout: "Connection timeout. Please check your internet."
     - 401 Unauthorized: "Session expired. Please sign in again."
     - 404 Not found: "User not found."
     - 400 Self-follow: "You cannot follow yourself."
     - 500 Server error: "Something went wrong. Please try again."
     - Generic: "Unable to update follow status. Please try again."

4. Enhance FollowNotifier with error handling
   - Modify `pockitflyer_app/lib/providers/follow_provider.dart`
   - Update `toggleFollow` method:
     ```dart
     Future<void> toggleFollow(int userId, bool isFollowing, BuildContext context) async {
       // Store previous state for rollback
       final previousState = Set<int>.from(followedUserIds);

       // Optimistic update
       if (isFollowing) {
         followedUserIds.remove(userId);
       } else {
         followedUserIds.add(userId);
       }
       notifyListeners();

       // API call with error handling
       try {
         bool success;
         if (isFollowing) {
           success = await _followService.unfollowUser(userId);
         } else {
           success = await _followService.followUser(userId);
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
         _rollbackAndShowError(previousState, context, "User not found.");
       } on SelfFollowException {
         _rollbackAndShowError(previousState, context, "You cannot follow yourself.");
       } catch (e) {
         _rollbackAndShowError(previousState, context, "Unable to update follow status. Please try again.");
       }
     }

     void _rollbackAndShowError(Set<int> previousState, BuildContext context, String message) {
       followedUserIds = previousState;
       notifyListeners();
       ErrorHandler.showErrorSnackBar(context, message);
     }
     ```

5. Add custom exception for self-follow error
   - Create new file `pockitflyer_app/lib/exceptions/follow_exceptions.dart`
   - Define custom exceptions:
     ```dart
     class SelfFollowException implements Exception {
       final String message;
       SelfFollowException([this.message = "Cannot follow yourself"]);
     }

     class UnauthorizedException implements Exception {
       final String message;
       UnauthorizedException([this.message = "Unauthorized"]);
     }

     class NotFoundException implements Exception {
       final String message;
       NotFoundException([this.message = "Not found"]);
     }
     ```
   - Update `FollowService` to throw appropriate exceptions based on HTTP status:
     - 400 → throw `SelfFollowException()`
     - 401 → throw `UnauthorizedException()`
     - 404 → throw `NotFoundException()`
     - Timeout → throw `TimeoutException`

6. Implement state persistence across sessions
   - Use local storage (SharedPreferences) to persist follow state
   - Modify `pockitflyer_app/lib/providers/follow_provider.dart`:
     - Add `Future<void> _saveFollowsToLocal()` method:
       - Convert `followedUserIds` to JSON list
       - Save to SharedPreferences with key "followed_user_ids"
     - Add `Future<void> _loadFollowsFromLocal()` method:
       - Load from SharedPreferences
       - Parse JSON list to Set<int>
       - Set `followedUserIds` state
     - Call `_saveFollowsToLocal()` after every successful follow/unfollow
     - Call `_loadFollowsFromLocal()` in provider initialization
   - On app launch:
     - Load follows from local storage immediately (instant UI)
     - Fetch fresh follows from API in background
     - Merge/reconcile local and remote state if differences found

7. Handle return navigation after login
   - Login/registration screens should already handle this from M02 or m03-e01-t03
   - Verify they check for `returnTo` and `message` arguments
   - After successful login, navigate to `returnTo` route
   - Test flow: anonymous user → tap follow → see auth gate → sign in → return to flyer feed → follow persisted

8. Create comprehensive test suite
   - Create new file `pockitflyer_app/test/widgets/follow_button_auth_test.dart`
   - **Auth gate tests**:
     - Tapping follow button when anonymous shows auth gate dialog
     - Tapping follow button when authenticated calls API
     - Selecting "Sign In" navigates to login with correct arguments
     - Selecting "Not Now" closes dialog without navigation
   - Modify `pockitflyer_app/test/providers/follow_provider_test.dart`
   - **Error handling tests**:
     - TimeoutException triggers rollback and error message
     - UnauthorizedException triggers rollback and error message
     - NotFoundException triggers rollback and error message
     - SelfFollowException (400) triggers rollback and specific error message
     - Generic exception triggers rollback and error message
   - **Persistence tests**:
     - Follows saved to local storage after successful toggle
     - Follows loaded from local storage on initialization
     - Local and remote state reconciled on app launch
   - Create new file `pockitflyer_app/test/services/follow_service_error_test.dart`
   - **Service error tests**:
     - 400 response throws SelfFollowException
     - 401 response throws UnauthorizedException
     - 404 response throws NotFoundException
     - Timeout throws TimeoutException

### Acceptance Criteria
- [ ] Anonymous users see auth gate dialog when tapping follow button [Test: tap follow without auth, verify dialog shown]
- [ ] Auth gate dialog has "Sign In", "Create Account", "Not Now" options [Test: render dialog, verify all buttons present]
- [ ] "Sign In" navigates to login with return route [Test: tap sign in, verify navigation with arguments]
- [ ] "Create Account" navigates to registration with return route [Test: tap create account, verify navigation]
- [ ] "Not Now" closes dialog without action [Test: tap not now, verify dialog dismissed]
- [ ] Network timeout shows user-friendly error and rolls back UI [Test: mock timeout, verify error message and state rollback]
- [ ] 401 Unauthorized shows error and rolls back UI [Test: mock 401, verify error message]
- [ ] 404 Not found shows error and rolls back UI [Test: mock 404, verify error message]
- [ ] 400 Self-follow shows specific error and rolls back UI [Test: mock 400, verify "Cannot follow yourself" message]
- [ ] Generic errors show fallback message and roll back UI [Test: mock unknown error, verify fallback message]
- [ ] Follows persist across app sessions [Test: follow user, restart app, verify still following]
- [ ] Local storage syncs with API on app launch [Test: modify local storage, launch app, verify API fetch reconciles state]
- [ ] Return navigation works after login [Test: auth gate → login → return to flyer feed]
- [ ] All tests pass with >85% coverage [Run: flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/widgets/auth_gate_dialog.dart` - REUSE from m03-e01-t03 (or create if doesn't exist)
- `pockitflyer_app/lib/widgets/follow_button.dart` - MODIFY: integrate auth gate logic
- `pockitflyer_app/lib/utils/error_handler.dart` - REUSE from m03-e01-t03 (or create if doesn't exist)
- `pockitflyer_app/lib/exceptions/follow_exceptions.dart` - NEW: custom exceptions for follow errors
- `pockitflyer_app/lib/providers/follow_provider.dart` - MODIFY: error handling and persistence
- `pockitflyer_app/lib/services/follow_service.dart` - MODIFY: throw custom exceptions based on HTTP status
- `pockitflyer_app/lib/screens/login_screen.dart` - VERIFY: handle return navigation (may already exist from M02)
- `pockitflyer_app/lib/screens/register_screen.dart` - VERIFY: handle return navigation (may already exist from M02)
- `pockitflyer_app/test/widgets/follow_button_auth_test.dart` - NEW: auth gate tests
- `pockitflyer_app/test/providers/follow_provider_test.dart` - MODIFY: add error handling and persistence tests
- `pockitflyer_app/test/services/follow_service_error_test.dart` - NEW: service error tests
- `pubspec.yaml` - MODIFY: add `shared_preferences` dependency if not present (may already exist from m03-e01-t03)

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - ErrorHandler methods with mocked context
  - FollowNotifier error handling with mocked service
  - Custom exception throwing in FollowService
  - Local storage persistence (save/load)
- **Widget tests**:
  - AuthGateDialog rendering and interactions (may already exist from m03-e01-t03)
  - FollowButton with authenticated/anonymous users
  - Error SnackBar display
- **Integration tests**:
  - Full auth gate flow: anonymous user → dialog → navigation
  - Full error flow: API failure → rollback → error message
  - Self-follow error flow: 400 → rollback → specific error message
  - Full persistence flow: follow → save → restart → load

### Definition of Done
- [ ] Code written and passes all tests (>85% coverage)
- [ ] Auth gate dialog integrated (reused from m03-e01-t03)
- [ ] Error handling covers all scenarios (timeout, 401, 404, 400 self-follow, generic)
- [ ] Self-follow error handled with specific message
- [ ] Follows persist across app sessions
- [ ] Return navigation after login works
- [ ] User-friendly error messages displayed
- [ ] Code follows Flutter/Dart conventions
- [ ] No console errors or warnings
- [ ] Changes committed with reference to task ID (m03-e02-t03)
- [ ] Epic m03-e02 complete and ready for validation

## Dependencies
- Requires: m03-e02-t01 (Backend API endpoints)
- Requires: m03-e02-t02 (Frontend follow button)
- Requires: M02 (User authentication) - auth state provider, login/registration screens must exist
- Optional: m03-e01-t03 (Favorites auth gate) - can reuse auth gate dialog and error handler if completed

## Technical Notes
**Reuse from Favorites (m03-e01-t03)**:
- Auth gate dialog component (same pattern, different messaging)
- Error handler utility (same implementation)
- Local storage persistence pattern (same approach)
- Return navigation pattern (same flow)

**Auth State Detection**:
- Use existing auth state provider from M02
- Check `isAuthenticated` property before follow operations
- Typical implementation: `final authState = Provider.of<AuthProvider>(context, listen: false);`

**Self-Follow Prevention**:
- Backend returns 400 status with error message
- Frontend catches 400, throws `SelfFollowException`
- Display specific error: "You cannot follow yourself"
- Rollback optimistic UI update
- Consider hiding follow button on user's own content (optional UI enhancement in future)

**Navigation with Arguments**:
- Use `Navigator.pushNamed(context, route, arguments: {...})`
- Login/registration screens should check for `arguments` on route
- After successful auth, navigate to `returnTo` route with `Navigator.pushReplacementNamed`

**Error Message UX**:
- Use SnackBar for non-critical errors (doesn't block UI)
- Keep messages short and actionable
- Avoid technical jargon (e.g., "500 error" → "Something went wrong")
- Provide retry option when appropriate
- Self-follow error should be clear: "You cannot follow yourself"

**State Persistence**:
- Use `shared_preferences` package for local storage
- Store follows as JSON list: `["123", "456", "789"]` (string user IDs)
- Load local state synchronously on app launch for instant UI
- Fetch from API asynchronously in background
- Reconcile differences: API is source of truth, update local if mismatch

**Reconciliation Strategy**:
- On app launch: load local → show UI → fetch API → compare → update if different
- If API returns different follows: update local storage and UI
- Handle edge case: user followed offline, then goes online (requires conflict resolution)

**Performance Considerations**:
- Auth gate check: synchronous, no API call (< 10ms)
- Local storage load: synchronous, fast (< 50ms)
- API sync in background: don't block UI

**Accessibility**:
- Ensure dialog is screen-reader accessible
- Provide clear labels for buttons
- Error messages should be announced to screen readers

**Differences from Favorites (m03-e01-t03)**:
- Different dialog messaging (follow creators vs save flyers)
- Additional error type: 400 Self-follow
- Different local storage key: "followed_user_ids" vs "favorited_flyer_ids"
- Different error message context (users vs flyers)

## References
- Flutter SharedPreferences: https://pub.dev/packages/shared_preferences
- Flutter SnackBar: https://api.flutter.dev/flutter/material/SnackBar-class.html
- Flutter Navigator Arguments: https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
- Material Design Dialogs: https://m3.material.io/components/dialogs
- Dart Custom Exceptions: https://dart.dev/guides/language/language-tour#exceptions
