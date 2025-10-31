---
id: m02-e01-t08
epic: m02-e01
title: Create Login Screen UI
status: pending
priority: high
tdd_phase: red
---

# Task: Create Login Screen UI

## Objective
Build Flutter login screen with email and password inputs, validation, error handling, and integration with login API. Professional UI with loading states and clear error messages.

## Acceptance Criteria
- [ ] Login screen with email TextFormField and password TextFormField (obscured)
- [ ] Email validation: required field
- [ ] Password validation: required field
- [ ] Submit button disabled during API call (loading state)
- [ ] Loading indicator shown during login
- [ ] Error messages displayed for validation errors and API errors
- [ ] Success: navigate to feed screen and update authentication state
- [ ] API integration with `/api/auth/login/` endpoint
- [ ] Link to registration screen for new users
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget builds without errors
- Submit button triggers API call with form data
- Loading state disables submit button
- API success: navigates to feed and updates auth state
- API error 401 (invalid credentials): shows appropriate error message
- API error 400 (missing fields): shows field-specific errors
- Network error: shows user-friendly error message
- Registration link navigates to registration screen

## Files to Modify/Create
- `pockitflyer_app/lib/screens/auth/login_screen.dart`
- `pockitflyer_app/lib/services/auth_api_service.dart` (add login API call method)
- `pockitflyer_app/test/screens/auth/login_screen_test.dart`

## Dependencies
- m02-e01-t04 (Backend login API)
- m02-e01-t06 (AuthenticationProvider)
- m02-e01-t07 (Registration screen for navigation link)

## Notes
- Similar UI pattern to registration screen for consistency
- Password field should have visibility toggle (optional but recommended)
- Error message for 401: "Invalid email or password" (generic for security)
- Navigation: replace current route to prevent back to login
- "Sign up" link should be prominent for new users
- Consider "Forgot password?" link for future milestone (optional for M02)
