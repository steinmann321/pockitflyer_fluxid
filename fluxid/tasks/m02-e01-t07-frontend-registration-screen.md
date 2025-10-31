---
id: m02-e01-t07
epic: m02-e01
title: Create Registration Screen UI
status: pending
priority: high
tdd_phase: red
---

# Task: Create Registration Screen UI

## Objective
Build Flutter registration screen with email and password inputs, validation, error handling, and integration with registration API. Professional UI with loading states and clear error messages.

## Acceptance Criteria
- [ ] Registration screen with email TextFormField and password TextFormField (obscured)
- [ ] Email validation: format check, required field
- [ ] Password validation: minimum 8 characters, required field
- [ ] Submit button disabled during API call (loading state)
- [ ] Loading indicator shown during registration
- [ ] Error messages displayed for validation errors and API errors
- [ ] Success: navigate to feed screen and update authentication state
- [ ] API integration with `/api/auth/register/` endpoint
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget builds without errors
- Email validation shows error for invalid format
- Password validation shows error for < 8 characters
- Submit button triggers API call with form data
- Loading state disables submit button
- API success: navigates to feed and updates auth state
- API error 409 (duplicate email): shows appropriate error message
- API error 400 (validation): shows field-specific errors
- Network error: shows user-friendly error message

## Files to Modify/Create
- `pockitflyer_app/lib/screens/auth/registration_screen.dart`
- `pockitflyer_app/lib/services/auth_api_service.dart` (registration API call method)
- `pockitflyer_app/test/screens/auth/registration_screen_test.dart`
- `pockitflyer_app/test/services/auth_api_service_test.dart`

## Dependencies
- m02-e01-t03 (Backend registration API)
- m02-e01-t06 (AuthenticationProvider)

## Notes
- Use Flutter Form widget for validation
- Password field should have visibility toggle (optional but recommended)
- Error messages should match backend API error messages
- Consider showing password requirements hint (min 8 chars)
- Navigation: replace current route to prevent back to registration
- API service should use existing HTTP client configuration from M01
