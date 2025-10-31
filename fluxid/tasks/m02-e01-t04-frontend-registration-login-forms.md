---
id: m02-e01-t04
title: Frontend Registration and Login Forms
epic: m02-e01
milestone: m02
status: pending
---

# Task: Frontend Registration and Login Forms

## Context
Part of User Authentication & Account Management (m02-e01) in Milestone m02.

This task creates the Flutter UI for user registration and login, implementing form validation, API integration, and error handling. It provides the user-facing interface for account creation and authentication, connecting to the backend endpoints from m02-e01-t01 and m02-e01-t02.

## Implementation Guide for LLM Agent

### Objective
Create Flutter registration and login screens with form validation, integrate with backend API endpoints, handle success/error states, and implement navigation between authentication screens.

### Steps

1. Install required dependencies in `pockitflyer_app/pubspec.yaml`
   - Add dependencies under `dependencies:`:
     ```yaml
     dio: ^5.4.0              # HTTP client
     flutter_riverpod: ^2.5.0 # State management
     go_router: ^14.0.0       # Navigation
     flutter_secure_storage: ^9.0.0  # Secure token storage
     freezed_annotation: ^2.4.0      # Immutable models
     json_annotation: ^4.8.0         # JSON serialization
     ```
   - Add dev dependencies under `dev_dependencies:`:
     ```yaml
     build_runner: ^2.4.0
     freezed: ^2.4.0
     json_serializable: ^6.7.0
     ```
   - Run: `flutter pub get`

2. Create API client configuration in `lib/core/api/api_client.dart`
   - Import: `package:dio/dio.dart`
   - Define `ApiClient` class:
     - `static const String baseUrl = 'http://localhost:8000/api'` (development)
     - Create singleton Dio instance with `BaseOptions(baseUrl: baseUrl, connectTimeout: 5000ms, receiveTimeout: 3000ms)`
     - Add interceptor for logging (development only)
   - Export `Dio get client => _dio` for use in services

3. Create auth models in `lib/features/auth/models/auth_models.dart`
   - Use freezed and json_serializable annotations
   - Define `@freezed class RegisterRequest`:
     - Fields: `String email`, `String password`, `String passwordConfirm`
     - Add `factory RegisterRequest.fromJson(Map<String, dynamic> json)`
     - Add `Map<String, dynamic> toJson()`
   - Define `@freezed class LoginRequest`:
     - Fields: `String email`, `String password`
     - Add JSON serialization methods
   - Define `@freezed class AuthResponse`:
     - Fields: `String access`, `String refresh`, `UserData user`
     - Add JSON serialization methods
   - Define `@freezed class UserData`:
     - Fields: `int id`, `String email`, `ProfileData profile`
     - Add JSON serialization methods
   - Define `@freezed class ProfileData`:
     - Fields: `String displayName`, `String bio`
     - Add JSON serialization methods
   - Run: `flutter pub run build_runner build` to generate code

4. Create auth service in `lib/features/auth/services/auth_service.dart`
   - Import: `package:dio/dio.dart`, API client, auth models
   - Define `AuthService` class:
     - Method `Future<AuthResponse> register(RegisterRequest request)`:
       - POST to `/users/register/` with `request.toJson()`
       - On success: parse response to `AuthResponse`
       - On error: throw `DioException` with error message
     - Method `Future<AuthResponse> login(LoginRequest request)`:
       - POST to `/users/login/` with `request.toJson()`
       - On success: parse response to `AuthResponse`
       - On error: throw `DioException` with error message
     - Method `Future<AuthResponse> refreshToken(String refreshToken)`:
       - POST to `/users/token/refresh/` with `{"refresh": refreshToken}`
       - Return new `AuthResponse` with updated access token
   - Handle common errors: network errors, 400 validation, 401 unauthorized, 429 rate limit

5. Create registration screen in `lib/features/auth/screens/register_screen.dart`
   - Import: `package:flutter/material.dart`, `package:flutter_riverpod/flutter_riverpod.dart`
   - Define `RegisterScreen extends ConsumerStatefulWidget`:
     - State fields: `TextEditingController` for email, password, passwordConfirm
     - State fields: `bool _isLoading = false`, `String? _errorMessage`
     - Build form with:
       - Email TextField with email validation
       - Password TextField with obscureText, strength indicator
       - Confirm Password TextField with match validation
       - Register button (disabled while loading)
       - "Already have account? Login" link
     - Validation:
       - Email: regex `^[^@]+@[^@]+\.[^@]+$`
       - Password: min 8 chars, show strength indicator
       - Confirm: must match password
     - On submit:
       - Validate all fields
       - Set `_isLoading = true`
       - Call `AuthService.register()`
       - On success: navigate to home (auth state handled in next task)
       - On error: show error message, set `_isLoading = false`
     - Dispose controllers in `dispose()`

6. Create login screen in `lib/features/auth/screens/login_screen.dart`
   - Import: same as RegisterScreen
   - Define `LoginScreen extends ConsumerStatefulWidget`:
     - State fields: `TextEditingController` for email, password
     - State fields: `bool _isLoading = false`, `String? _errorMessage`
     - Build form with:
       - Email TextField
       - Password TextField with obscureText
       - Login button (disabled while loading)
       - "Don't have account? Register" link
     - On submit:
       - Validate email and password not empty
       - Set `_isLoading = true`
       - Call `AuthService.login()`
       - On success: navigate to home
       - On error: show error message based on status (401 = "Invalid credentials", 429 = "Too many attempts", else = generic)
     - Dispose controllers in `dispose()`

7. Create routing configuration in `lib/core/router/app_router.dart`
   - Import: `package:go_router/go_router.dart`, auth screens
   - Define `GoRouter` instance:
     - Initial route: `/login`
     - Routes:
       - `/login`: LoginScreen
       - `/register`: RegisterScreen
       - `/`: Placeholder home screen (will be replaced in m02-e01-t05)
     - Named routes for easy navigation
   - Export router for use in main app

8. Update main app in `lib/main.dart`
   - Import: `package:flutter_riverpod/flutter_riverpod.dart`, app router
   - Wrap `MyApp` with `ProviderScope`:
     ```dart
     void main() {
       runApp(const ProviderScope(child: MyApp()));
     }
     ```
   - Update `MyApp` to use router:
     ```dart
     class MyApp extends StatelessWidget {
       @override
       Widget build(BuildContext context) {
         return MaterialApp.router(
           title: 'PockitFlyer',
           routerConfig: appRouter,
           theme: ThemeData(
             primarySwatch: Colors.blue,
             inputDecorationTheme: InputDecorationTheme(
               border: OutlineInputBorder(),
             ),
           ),
         );
       }
     }
     ```

9. Create comprehensive widget tests in `test/features/auth/screens/register_screen_test.dart`
   - Test cases:
     - `test_register_form_renders`: Verify email, password, confirm fields present
     - `test_email_validation`: Empty email shows error, invalid email shows error
     - `test_password_validation`: Empty password shows error, short password shows error
     - `test_password_match_validation`: Mismatched passwords show error
     - `test_register_button_disabled_while_loading`: Tap button, verify disabled during API call
     - `test_successful_registration_navigates`: Mock AuthService, verify navigation on success
     - `test_failed_registration_shows_error`: Mock 400 error, verify error message displayed
     - `test_rate_limit_error_shows_message`: Mock 429 error, verify rate limit message
     - `test_navigation_to_login`: Tap "Login" link, verify navigation
   - Use `WidgetTester`, `pumpWidget`, `find.byType`, `find.text`
   - Mark all tests with `// @Tags(['tdd_red'])` initially

10. Create comprehensive widget tests in `test/features/auth/screens/login_screen_test.dart`
    - Test cases:
      - `test_login_form_renders`: Verify email, password fields present
      - `test_empty_fields_show_errors`: Submit empty form, verify validation errors
      - `test_login_button_disabled_while_loading`: Verify loading state
      - `test_successful_login_navigates`: Mock AuthService, verify navigation
      - `test_invalid_credentials_show_error`: Mock 401 error, verify error message
      - `test_navigation_to_register`: Tap "Register" link, verify navigation
    - Mark all tests with `// @Tags(['tdd_red'])` initially

11. Create integration tests in `test/features/auth/auth_flow_test.dart`
    - Test cases:
      - `test_registration_to_login_flow`: Register → navigate to login → login → home
      - `test_login_to_register_flow`: Login → navigate to register → register → home
    - Mock AuthService responses
    - Verify full navigation flow
    - Mark with `// @Tags(['tdd_red'])`

### Acceptance Criteria
- [ ] Registration screen renders with email, password, confirm password fields [Test: widget test]
- [ ] Registration validates email format [Test: invalid email shows error]
- [ ] Registration validates password length (min 8 chars) [Test: short password shows error]
- [ ] Registration validates password confirmation match [Test: mismatch shows error]
- [ ] Registration form submits to backend API [Test: integration test with mock]
- [ ] Successful registration navigates to home [Test: verify navigation]
- [ ] Failed registration displays error message [Test: 400 error shows validation errors]
- [ ] Login screen renders with email, password fields [Test: widget test]
- [ ] Login validates non-empty fields [Test: empty submission shows errors]
- [ ] Login form submits to backend API [Test: integration test with mock]
- [ ] Successful login navigates to home [Test: verify navigation]
- [ ] Invalid credentials show "Invalid credentials" error [Test: 401 response]
- [ ] Rate limiting shows "Too many attempts" error [Test: 429 response]
- [ ] Navigation links work (Register ↔ Login) [Test: tap links, verify route changes]
- [ ] Tests pass with >85% coverage for auth screens

### Files to Create/Modify
- `pockitflyer_app/pubspec.yaml` - MODIFY: add dependencies
- `pockitflyer_app/lib/core/api/api_client.dart` - NEW: Dio client configuration
- `pockitflyer_app/lib/features/auth/models/auth_models.dart` - NEW: freezed models
- `pockitflyer_app/lib/features/auth/models/auth_models.freezed.dart` - GENERATED: freezed code
- `pockitflyer_app/lib/features/auth/models/auth_models.g.dart` - GENERATED: JSON serialization
- `pockitflyer_app/lib/features/auth/services/auth_service.dart` - NEW: API service
- `pockitflyer_app/lib/features/auth/screens/register_screen.dart` - NEW: registration UI
- `pockitflyer_app/lib/features/auth/screens/login_screen.dart` - NEW: login UI
- `pockitflyer_app/lib/core/router/app_router.dart` - NEW: routing configuration
- `pockitflyer_app/lib/main.dart` - MODIFY: add ProviderScope, MaterialApp.router
- `pockitflyer_app/test/features/auth/screens/register_screen_test.dart` - NEW: registration widget tests
- `pockitflyer_app/test/features/auth/screens/login_screen_test.dart` - NEW: login widget tests
- `pockitflyer_app/test/features/auth/auth_flow_test.dart` - NEW: integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Widget tests**: Screen rendering, form validation, loading states, error display, navigation
- **Integration tests**: Full registration/login flow with mocked AuthService, verify state transitions

### Definition of Done
- [ ] Code written and passes all tests (mark tests `// @Tags(['tdd_green'])` after verification)
- [ ] Forms validate input correctly
- [ ] API integration works (test with mocks)
- [ ] No console errors or warnings
- [ ] Navigation between screens works
- [ ] Changes committed with message: "feat(auth): implement registration and login forms"
- [ ] Ready for m02-e01-t05 (auth state management) to persist tokens

## Dependencies
- Requires: m02-e01-t01 (backend registration endpoint), m02-e01-t02 (backend login endpoint)
- Flutter project initialized (already present)

## Technical Notes
**Form Validation:**
- Client-side validation provides immediate feedback
- Server-side validation is authoritative (backend may reject valid-looking input)
- Always display server error messages to user

**Password Strength Indicator:**
- Simple implementation: check length, has uppercase, has number, has special char
- Show visual indicator (weak/medium/strong) below password field
- Use `LinearProgressIndicator` with color coding

**Error Handling:**
- Network errors: "Connection failed. Check your internet."
- 400 errors: Display server validation messages
- 401 errors: "Invalid email or password"
- 429 errors: "Too many attempts. Please try again later."
- 500+ errors: "Something went wrong. Please try again."

**Navigation:**
- Use `context.go('/route')` for navigation
- Use `context.push('/route')` for stacked navigation
- Named routes make navigation cleaner and testable

**Testing Strategy:**
- Widget tests: Use `testWidgets()`, pump widget tree, find elements, simulate interactions
- Mock AuthService using `mockito` or manual mocks
- Use `pumpAndSettle()` to wait for animations/async
- After implementation, run tests: `flutter test`
- Mark tests `// @Tags(['tdd_green'])` after passing

**API Integration:**
- Use `try-catch` around all Dio calls
- Check `response.statusCode` for success (200-299)
- Parse `DioException` for error details: `error.response?.data`
- Show user-friendly messages, log technical details

**Freezed Models:**
- `@freezed` generates immutable classes with `copyWith`, equality, `toString`
- `@JsonSerializable()` generates `fromJson` and `toJson`
- Run `build_runner` whenever models change

## References
- Flutter Form Validation: https://docs.flutter.dev/cookbook/forms/validation
- Dio HTTP Client: https://pub.dev/packages/dio
- Freezed: https://pub.dev/packages/freezed
- Go Router: https://pub.dev/packages/go_router
- Flutter Widget Testing: https://docs.flutter.dev/cookbook/testing/widget/introduction
