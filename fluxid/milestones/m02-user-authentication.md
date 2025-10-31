---
id: m02
title: User Authentication and Profile Management
status: pending
---

# Milestone: User Authentication and Profile Management

## Deliverable
Users can create accounts with email registration, log in securely, and manage their public profile. The authentication system is fully integrated with JWT-based security, and users can edit their profile picture and name. Registration automatically creates an empty default profile. The header login button switches to a profile avatar when authenticated, providing access to the user's own profile page. All profile pages are publicly viewable by anyone, including anonymous users.

## Success Criteria
- [ ] Users can register new accounts using email-based authentication - complete signup UI with backend user creation and JWT token generation
- [ ] Users can log in with email and password - login UI with backend JWT authentication and session management
- [ ] Registration automatically creates an empty default profile - backend creates user profile record on signup
- [ ] Header login button switches to user's profile avatar/icon when authenticated - UI state management reflects authentication status
- [ ] Authenticated users can access their own profile page by tapping avatar in header - navigation and profile UI implementation
- [ ] Users can edit their profile picture and name - profile editing UI with backend update APIs and image storage
- [ ] All user profiles are publicly viewable by anyone (including anonymous users) - public profile pages work without authentication
- [ ] Profile displays user's profile picture, name, and published flyers - complete profile UI with backend data integration
- [ ] Complete UI implementation for authentication and profile workflows - polished signup, login, and profile screens
- [ ] Full backend JWT authentication system - Django REST Framework with JWT tokens, secure password handling
- [ ] User database models with proper validation and indexing - SQLite migrations for user and profile tables
- [ ] Email service integration for account verification (if required) - backend email service setup
- [ ] Privacy settings system with email contact permission toggle - settings UI with backend privacy model
- [ ] All flows are polished and production-ready - consumer-grade authentication experience
- [ ] Can be deployed on top of M01 - builds on discovery platform
- [ ] Authentication unlocks access to future personalization features

## Validation Questions
**Before marking this milestone complete, answer:**
- [ ] Can a real user perform complete workflows with only this milestone? (register, login, manage profile)
- [ ] Is it polished enough to ship publicly? (production-ready auth UI and security)
- [ ] Does it solve a real problem end-to-end? (secure user accounts and identity)
- [ ] Does it include both complete UI and functional backend integration? (yes - full auth stack)
- [ ] Can it run independently without waiting for other milestones? (yes - builds cleanly on M01)
- [ ] Would you personally use this if it were released today? (yes - secure account system)

## Notes
- Builds on M01 (Anonymous Discovery) - adds authentication layer
- JWT tokens provide stateless authentication for API access
- Profile system is simple: picture + name only (no bio, location, or detailed fields)
- All profiles are public by design - no private profiles
- Privacy settings control features like email contact permission
- Email service integration depends on production email provider configuration
- Authentication state must persist across app restarts (token storage)
