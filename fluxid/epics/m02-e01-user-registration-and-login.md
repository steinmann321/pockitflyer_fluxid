---
id: m02-e01
title: User Registration and Login
milestone: m02
status: pending
---

# Epic: User Registration and Login

## Overview
Users can create new accounts with email-based registration and log in securely using email and password. The system implements JWT-based authentication with secure password handling, token generation, and session management. The header login button dynamically switches to the user's profile avatar when authenticated. Registration automatically creates an empty default profile. All authentication flows are polished and production-ready with complete backend integration.

## Scope
- Registration UI with email and password input
- Login UI with email and password input
- Django REST API endpoints for registration and login
- JWT token generation and management on backend
- Secure password hashing (bcrypt/pbkdf2)
- User database model with proper validation and indexing
- Profile database model with automatic creation on registration
- Token storage in app for persistent authentication
- Authentication state management in frontend
- Header UI switches from login button to profile avatar based on auth state
- Input validation and error handling for registration and login
- Backend user creation with email uniqueness validation
- Session persistence across app restarts

## Success Criteria
- [ ] Users can register with email and password [Test: valid input, invalid email format, weak password, duplicate email, network errors]
- [ ] Registration creates user account and default empty profile [Test: verify user record, verify profile record, check profile defaults]
- [ ] Users can log in with registered email and password [Test: correct credentials, wrong password, non-existent email, case sensitivity]
- [ ] JWT tokens are generated and stored securely [Test: token format, token expiration, token storage mechanism, secure storage]
- [ ] Passwords are hashed securely before storage [Test: verify hash algorithm, verify plaintext never stored, hash uniqueness]
- [ ] Header shows login button when not authenticated [Test: fresh install, logged out state, token expiration]
- [ ] Header shows profile avatar when authenticated [Test: post-login, post-registration, app restart with valid token]
- [ ] Authentication state persists across app restarts [Test: login, force quit, relaunch, verify authenticated state]
- [ ] Token expiration is handled gracefully [Test: expired token shows login button, re-login works, no crashes]
- [ ] Input validation provides clear error messages [Test: empty fields, invalid formats, network errors, server errors]
- [ ] Backend validates email uniqueness [Test: duplicate registration attempt, case-insensitive email check]
- [ ] API responses include proper error codes and messages [Test: 400 for validation, 401 for auth failure, 409 for conflict, 500 for server errors]
- [ ] Registration and login flows complete within 3 seconds on standard network [Test: 3G/4G/5G/WiFi conditions]

## Dependencies
- No dependencies on other M02 epics (foundational for milestone)
- Builds on M01 (Anonymous Discovery) - adds authentication layer
- External: Django REST Framework for API
- External: djangorestframework-simplejwt for JWT tokens

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- JWT tokens provide stateless authentication for API access
- Token storage must use iOS Keychain for security
- Default profile contains only user ID - picture and name are null/empty until edited
- Email is the unique identifier for users (no username)
- Password requirements: minimum 8 characters (other requirements TBD)
- Token expiration: 24 hours (configurable)
- Refresh token mechanism may be added in future milestone if needed
- Backend must enforce email uniqueness at database level (unique constraint)
- All auth endpoints require HTTPS in production
- Consider email verification flow (optional for MVP - can be added later)
