---
id: m02-e01-t05
title: Frontend Auth State Management and Header UI
epic: m02-e01
milestone: m02
status: pending
---

# Task: Frontend Auth State Management and Header UI

## Context
Part of User Authentication & Account Management (m02-e01) in Milestone m02.

This task implements global authentication state management using Riverpod, secure token persistence with flutter_secure_storage, automatic token refresh, and updates the header UI to show login/logout state. It completes the authentication flow by making auth state available throughout the app and updating UI based on user login status.

## Implementation Guide for LLM Agent

### Objective
Create global auth state provider with token persistence, implement automatic token refresh before expiration, update header UI to show "Login" button when logged out and profile avatar when logged in, show/hide "Flyern" button based on auth state, and implement logout functionality.

### Steps

1. Create token storage service in `lib/core/storage/token_storage.dart`
   - Import: `package:flutter_secure_storage/flutter_secure_storage.dart`
   - Define `TokenStorage` class:
     - `static const _storage = FlutterSecureStorage()`
     - `static const String _accessKey = 'access_token'`
     - `static const String _refreshKey = 'refresh_token'`
     - Method `Future<void> saveTokens(String access, String refresh)`:
       - Write access token: `await _storage.write(key: _accessKey, value: access)`
       - Write refresh token: `await _storage.write(key: _refreshKey, value: refresh)`
     - Method `Future<String?> getAccessToken()`: read from _accessKey
     - Method `Future<String?> getRefreshToken()`: read from _refreshKey
     - Method `Future<void> clearTokens()`: delete both keys
   - This provides secure storage for sensitive tokens (encrypted on device)

2. Create auth state model in `lib/features/auth/models/auth_state.dart`
   - Use freezed annotation
   - Define `@freezed class AuthState`:
     - Union types:
       - `const factory AuthState.initial()` - app starting, checking for stored tokens
       - `const factory AuthState.authenticated(UserData user, String accessToken, String refreshToken)` - user logged in
       - `const factory AuthState.unauthenticated()` - user not logged in
     - This represents all possible auth states
   - Run: `flutter pub run build_runner build`

3. Create auth state notifier in `lib/features/auth/providers/auth_provider.dart`
   - Import: `package:flutter_riverpod/flutter_riverpod.dart`, auth models, services, storage
   - Define `class AuthNotifier extends StateNotifier<AuthState>`:
     - Constructor: `AuthNotifier() : super(const AuthState.initial()) { _init(); }`
     - Method `Future<void> _init()`:
       - Load tokens from storage: `accessToken = await TokenStorage.getAccessToken()`
       - If tokens exist: decode access token to get user data, set state to authenticated
       - If no tokens or invalid: set state to unauthenticated
     - Method `Future<void> login(String email, String password)`:
       - Call `AuthService.login(LoginRequest(email, password))`
       - On success: save tokens, set state to authenticated with user data
       - On error: rethrow for UI to handle
     - Method `Future<void> register(String email, String password, String passwordConfirm)`:
       - Call `AuthService.register(RegisterRequest(...))`
       - On success: save tokens, set state to authenticated
       - On error: rethrow
     - Method `Future<void> logout()`:
       - Clear tokens: `await TokenStorage.clearTokens()`
       - Set state to unauthenticated
     - Method `Future<void> refreshAccessToken()`:
       - Get refresh token from storage
       - Call `AuthService.refreshToken(refreshToken)`
       - Save new access token
       - Update state with new access token
   - Create provider: `final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier())`

4. Add token refresh timer in `auth_provider.dart`
   - Import: `dart:async`
   - In `AuthNotifier`:
     - Add field: `Timer? _refreshTimer`
     - Method `void _scheduleTokenRefresh()`:
       - Decode access token to get exp claim (expiration timestamp)
       - Calculate time until expiration: `expiresAt - now`
       - Schedule refresh 5 minutes before expiration: `expiresAt - 5 minutes`
       - Create timer: `_refreshTimer = Timer(duration, () => refreshAccessToken())`
     - Call `_scheduleTokenRefresh()` after login, register, and manual refresh
     - Cancel timer on logout: `_refreshTimer?.cancel()`
   - This ensures tokens are refreshed automatically before expiring

5. Update auth screens to use auth provider
   - In `lib/features/auth/screens/register_screen.dart`:
     - Replace direct `AuthService.register()` call with `ref.read(authProvider.notifier).register()`
     - Remove manual navigation on success (auth state change will trigger navigation)
   - In `lib/features/auth/screens/login_screen.dart`:
     - Replace direct `AuthService.login()` call with `ref.read(authProvider.notifier).login()`
     - Remove manual navigation on success

6. Create header widget with auth-aware UI in `lib/core/widgets/app_header.dart`
   - Import: Riverpod, auth provider
   - Define `AppHeader extends ConsumerWidget`:
     - Build AppBar with:
       - Title: "PockitFlyer"
       - Actions (right side):
         - Watch auth state: `final authState = ref.watch(authProvider)`
         - If `authState is Authenticated`:
           - Show CircleAvatar with user initials (first letter of email)
           - Show IconButton for logout (calls `ref.read(authProvider.notifier).logout()`)
         - If `authState is Unauthenticated`:
           - Show TextButton "Login" (navigates to `/login`)
       - Show "Flyern" button (FloatingActionButton or prominent button) only if authenticated
     - Handle logout confirmation: show AlertDialog before logout

7. Create placeholder home screen in `lib/features/home/screens/home_screen.dart`
   - Import: AppHeader
   - Define `HomeScreen extends StatelessWidget`:
     - Build Scaffold with:
       - `appBar: AppHeader()`
       - Body: placeholder content (e.g., "Home Screen - Coming Soon")
       - FloatingActionButton "Flyern" (visible only when authenticated, checked in AppHeader)
   - This screen will be expanded in future epics

8. Update router to handle auth state in `lib/core/router/app_router.dart`
   - Add redirect logic:
     - If route is `/` and user is unauthenticated: redirect to `/login`
     - If route is `/login` or `/register` and user is authenticated: redirect to `/`
   - Use `redirect: (context, state)` callback in GoRouter
   - Watch auth provider to trigger rebuilds on auth state changes

9. Update main.dart to initialize auth state
   - Ensure `ProviderScope` wraps the entire app (already done in m02-e01-t04)
   - Auth provider `_init()` will run automatically on app start
   - No additional initialization needed

10. Create comprehensive tests in `test/features/auth/providers/auth_provider_test.dart`
    - Test cases:
      - `test_initial_state_is_initial`: Verify state starts as `AuthState.initial()`
      - `test_init_with_no_tokens_sets_unauthenticated`: Mock storage returns null, verify unauthenticated
      - `test_init_with_valid_tokens_sets_authenticated`: Mock storage returns tokens, verify authenticated with user data
      - `test_login_success_saves_tokens_and_sets_authenticated`: Mock AuthService.login, verify state and storage
      - `test_login_failure_keeps_unauthenticated`: Mock login error, verify state unchanged
      - `test_register_success_saves_tokens_and_sets_authenticated`: Mock register, verify state
      - `test_logout_clears_tokens_and_sets_unauthenticated`: Call logout, verify storage cleared and state
      - `test_refresh_token_updates_access_token`: Mock refresh, verify new token saved and state updated
      - `test_refresh_timer_scheduled_after_login`: Verify timer created after login
      - `test_refresh_timer_cancelled_on_logout`: Verify timer cancelled
    - Use `ProviderContainer` for testing providers
    - Mock `AuthService` and `TokenStorage`
    - Mark all tests with `// @Tags(['tdd_red'])`

11. Create widget tests in `test/core/widgets/app_header_test.dart`
    - Test cases:
      - `test_header_shows_login_button_when_unauthenticated`: Mock unauthenticated state, verify "Login" button present
      - `test_header_shows_avatar_when_authenticated`: Mock authenticated state, verify CircleAvatar with initials
      - `test_login_button_navigates_to_login_screen`: Tap login, verify navigation
      - `test_logout_button_shows_confirmation`: Tap logout icon, verify AlertDialog
      - `test_logout_confirmation_calls_logout`: Confirm logout, verify provider.logout() called
      - `test_flyern_button_visible_when_authenticated`: Verify button present
      - `test_flyern_button_hidden_when_unauthenticated`: Verify button absent
    - Use `ProviderScope` to override `authProvider` in tests
    - Mark with `// @Tags(['tdd_red'])`

12. Create integration test in `test/features/auth/full_auth_flow_test.dart`
    - Test full flow:
      - App starts → initial state → checks storage → unauthenticated
      - User registers → authenticated → header shows avatar
      - User logs out → unauthenticated → header shows login button
      - User logs in → authenticated → header updates
      - Token refresh scheduled → simulated timer → token refreshed
    - Mock AuthService and TokenStorage
    - Mark with `// @Tags(['tdd_red'])`

### Acceptance Criteria
- [ ] Auth state persists across app restarts (tokens stored securely) [Test: close/reopen app, verify still authenticated]
- [ ] Login success updates header to show profile avatar [Test: login, verify CircleAvatar visible]
- [ ] Logout updates header to show "Login" button [Test: logout, verify button visible]
- [ ] "Flyern" button visible only when authenticated [Test: check button presence in both states]
- [ ] Profile avatar shows user initials (first letter of email) [Test: user@example.com → "U"]
- [ ] Access token refreshes automatically before expiration [Test: mock timer, verify refresh called]
- [ ] Logout clears tokens from secure storage [Test: logout, verify storage.getAccessToken() returns null]
- [ ] Login screen redirects to home on success [Test: login, verify navigation]
- [ ] Home screen redirects to login when unauthenticated [Test: navigate to `/`, verify redirected to `/login`]
- [ ] Logout shows confirmation dialog [Test: tap logout, verify AlertDialog]
- [ ] Tests pass with >85% coverage for auth state management

### Files to Create/Modify
- `pockitflyer_app/lib/core/storage/token_storage.dart` - NEW: secure token storage
- `pockitflyer_app/lib/features/auth/models/auth_state.dart` - NEW: auth state model
- `pockitflyer_app/lib/features/auth/models/auth_state.freezed.dart` - GENERATED: freezed code
- `pockitflyer_app/lib/features/auth/providers/auth_provider.dart` - NEW: auth state notifier
- `pockitflyer_app/lib/core/widgets/app_header.dart` - NEW: header with auth UI
- `pockitflyer_app/lib/features/home/screens/home_screen.dart` - NEW: placeholder home
- `pockitflyer_app/lib/core/router/app_router.dart` - MODIFY: add auth-aware redirects
- `pockitflyer_app/lib/features/auth/screens/register_screen.dart` - MODIFY: use auth provider
- `pockitflyer_app/lib/features/auth/screens/login_screen.dart` - MODIFY: use auth provider
- `pockitflyer_app/test/features/auth/providers/auth_provider_test.dart` - NEW: provider tests
- `pockitflyer_app/test/core/widgets/app_header_test.dart` - NEW: header widget tests
- `pockitflyer_app/test/features/auth/full_auth_flow_test.dart` - NEW: integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**: Auth state transitions, token storage operations, token refresh logic
- **Widget tests**: Header rendering based on auth state, button visibility, navigation
- **Integration tests**: Full auth flow (register → authenticated → logout → unauthenticated → login)

### Definition of Done
- [ ] Code written and passes all tests (mark tests `// @Tags(['tdd_green'])` after verification)
- [ ] Auth state persists across sessions
- [ ] Header UI updates based on auth state
- [ ] Token refresh works automatically
- [ ] No console errors or warnings
- [ ] Changes committed with message: "feat(auth): implement auth state management and header UI"
- [ ] Epic m02-e01 complete and ready for user review

## Dependencies
- Requires: m02-e01-t04 (registration/login forms, auth models, API service)
- flutter_secure_storage, flutter_riverpod installed (from m02-e01-t04)

## Technical Notes
**Secure Storage:**
- `flutter_secure_storage` uses Keychain on iOS, KeyStore on Android
- Data encrypted at rest, not accessible by other apps
- Perfect for sensitive tokens

**JWT Decoding:**
- Use `dart:convert` and `base64` to decode JWT payload (no signature verification needed on client)
- Format: `header.payload.signature` (split by '.', base64 decode payload)
- Extract claims: `exp` (expiration timestamp), `user_id`, `email`

**Token Refresh Strategy:**
- Refresh 5 minutes before expiration (safe buffer)
- Use Timer (not periodic) - schedule next refresh after each refresh
- Cancel timer on logout to prevent memory leaks

**Auth State Pattern:**
- Union types with freezed: `when()` method for exhaustive pattern matching
- Prevents null checks, makes state transitions explicit
- Example:
  ```dart
  authState.when(
    initial: () => CircularProgressIndicator(),
    authenticated: (user, _, __) => Text(user.email),
    unauthenticated: () => Text("Please login"),
  )
  ```

**Router Redirects:**
- `redirect` callback runs on every route change
- Return new path to redirect, return null to allow navigation
- Watch providers in redirect to react to auth changes

**Testing Strategy:**
- Use `ProviderContainer` for provider testing: `container.read(authProvider)`
- Override providers in tests: `ProviderScope(overrides: [authProvider.overrideWith(...)])`
- Use `pumpAndSettle()` to wait for async state updates
- After implementation, run tests: `flutter test`
- Mark tests `// @Tags(['tdd_green'])` after passing

**Error Handling:**
- If token refresh fails (e.g., refresh token expired): log user out automatically
- Show notification: "Session expired. Please login again."
- Clear tokens and redirect to login

**Future Enhancements (not in this task):**
- Profile avatar image (currently just initials)
- User settings screen
- Password change functionality
- These will be added in future epics as needed

## References
- Flutter Secure Storage: https://pub.dev/packages/flutter_secure_storage
- Riverpod State Notifier: https://riverpod.dev/docs/concepts/providers/#statenotifierprovider
- Go Router Redirect: https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html
- JWT Decoding in Dart: https://pub.dev/packages/dart_jsonwebtoken
