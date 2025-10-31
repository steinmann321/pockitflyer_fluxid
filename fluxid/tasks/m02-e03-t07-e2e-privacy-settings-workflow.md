---
id: m02-e03-t07
epic: m02-e03
title: E2E Test Privacy Settings Workflow
status: pending
priority: medium
tdd_phase: red
---

# Task: E2E Test Privacy Settings Workflow

## Objective
Create comprehensive E2E tests for complete privacy settings workflow using Maestro. Tests should validate navigation, toggle interaction, persistence, and API integration from user perspective.

## Acceptance Criteria
- [ ] E2E test: Navigate from profile to privacy settings
- [ ] E2E test: Toggle email permission on → off → verify state
- [ ] E2E test: Toggle email permission off → on → verify state
- [ ] E2E test: Verify privacy settings persist across app restart
- [ ] E2E test: Verify default privacy settings for new user
- [ ] E2E test: Error handling when API unavailable
- [ ] All tests pass consistently on iOS simulator
- [ ] Tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete workflow: profile → settings → toggle → back → verify
- Settings persistence: change setting, quit app, relaunch, verify persisted
- New user flow: register → navigate to settings → verify default (on)
- Toggle interaction: visual feedback, state update, API call
- Error scenarios: network failure, server error, unauthorized
- Performance: settings load within 2 seconds, update completes within 2 seconds

## Files to Modify/Create
- `pockitflyer_app/.maestro/flows/privacy_settings_navigation.yaml`
- `pockitflyer_app/.maestro/flows/privacy_settings_toggle.yaml`
- `pockitflyer_app/.maestro/flows/privacy_settings_persistence.yaml`
- `pockitflyer_app/.maestro/flows/privacy_settings_defaults.yaml`
- `pockitflyer_app/.maestro/flows/privacy_settings_error_handling.yaml`

## Dependencies
- m02-e03-t06 (Navigation from profile)
- m02-e03-t05 (Privacy settings screen)
- m02-e03-t04 (State management)

## Notes
- Use Maestro assertions to verify toggle state visually
- Test data setup: create test users with different privacy settings
- App restart test: use Maestro's restart command
- Consider using Maestro variables for user credentials
- Tests should clean up (reset privacy settings) after completion
- Run tests against local backend with test database
