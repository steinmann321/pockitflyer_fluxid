---
id: m02-e04
title: E2E M02 Milestone Validation
milestone: m02
status: pending
---

# Epic: E2E M02 Milestone Validation

## Overview
Comprehensive end-to-end validation tests verify that M02 (User Authentication and Profile Management) delivers a complete, production-ready authentication system that works seamlessly with M01 (Anonymous Discovery). Tests validate complete user workflows including registration, login, profile management, privacy settings, and authentication state persistence. All flows are tested as real users would experience them, ensuring polished UI, robust backend integration, and proper error handling.

## Scope
- E2E test: Complete registration workflow (email signup → auto profile creation → authenticated state)
- E2E test: Complete login workflow (email login → JWT token → persistent auth)
- E2E test: Profile viewing workflow (authenticated and anonymous access)
- E2E test: Profile editing workflow (picture upload → name change → visibility across app)
- E2E test: Privacy settings workflow (access settings → toggle email permission → persistence)
- E2E test: Authentication state persistence (login → app restart → still authenticated)
- E2E test: Logout and re-login workflow
- E2E test: Header state transition (login button ↔ profile avatar)
- E2E test: Integration with M01 features (authenticated vs anonymous feed access)
- E2E test: Error handling (network failures, invalid credentials, expired tokens)
- Production readiness validation (performance, security, polish)

## Success Criteria
- [ ] User can register, get authenticated, and see profile avatar in header [E2E: registration → auto-login → avatar visible → profile accessible]
- [ ] User can log in and access authenticated features [E2E: login → token stored → authenticated state → profile access]
- [ ] Profile auto-creation on registration works correctly [E2E: register → verify empty profile exists → verify profile ID matches user ID]
- [ ] Profile editing updates are visible across entire app [E2E: edit name → verify feed shows new name → verify profile shows new name]
- [ ] Profile picture upload and display works end-to-end [E2E: upload photo → verify storage → verify display in profile → verify display in flyer cards]
- [ ] Privacy settings persist and are enforced [E2E: toggle email permission → verify saved → restart app → verify setting maintained]
- [ ] Authentication state persists across app restarts [E2E: login → force quit → relaunch → verify still authenticated → verify profile accessible]
- [ ] Logout clears authentication and returns to login state [E2E: logout → verify token cleared → verify header shows login button → verify profile not accessible]
- [ ] Token expiration is handled gracefully [E2E: simulate expired token → verify auto-logout → verify login prompt → verify re-login works]
- [ ] Anonymous users can view profiles but not edit [E2E: view profile without auth → verify public visibility → verify edit not available]
- [ ] All M01 features work correctly for authenticated users [E2E: browse feed → filter → search → view details → view creator profile]
- [ ] Error handling provides clear feedback [E2E: wrong password → clear error message, network failure → retry option, duplicate email → helpful message]
- [ ] All workflows complete within acceptable time limits [E2E: registration <5s, login <3s, profile load <2s, settings update <2s]
- [ ] UI is polished and production-ready [Manual review: visual consistency, smooth transitions, appropriate loading states, error states]
- [ ] Security validation passes [Security review: password hashing, token security, API authorization, input sanitization]

## Dependencies
- Epic m02-e01 (User Registration and Login)
- Epic m02-e02 (User Profile Management)
- Epic m02-e03 (Privacy Settings and Email Permissions)
- All M01 epics (integration testing requires M01 features)
- Maestro E2E testing framework (already in place from M01)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All E2E test scenarios are implemented and passing
- [ ] All success criteria are validated
- [ ] Performance benchmarks are met
- [ ] Security validation is complete
- [ ] UI polish is production-ready
- [ ] No regressions in M01 features
- [ ] Epic contributes to milestone deliverability
- [ ] M02 milestone validation questions can be answered "yes"

## Notes
- This epic is the final gate before marking M02 complete
- Tests must validate REAL user workflows, not just isolated features
- Maestro E2E tests should cover happy paths and critical error paths
- Performance testing should simulate realistic network conditions (3G/4G/5G/WiFi)
- Security validation should check OWASP top 10 vulnerabilities
- UI polish review should compare against production apps (Instagram, Twitter, etc.)
- Integration with M01 validates that authentication layer doesn't break discovery features
- Token expiration testing may require time manipulation or backend config changes
- Consider edge cases: airplane mode, background/foreground transitions, concurrent sessions
- All test scenarios should be automated where possible (Maestro, pytest)
- Manual validation may be required for UI polish and security review
- This epic validates the ENTIRE milestone, not just individual epics
