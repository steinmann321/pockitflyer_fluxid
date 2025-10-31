---
id: m02-e03-t04
epic: m02-e03
title: Implement Privacy Settings State Management
status: pending
priority: high
tdd_phase: red
---

# Task: Implement Privacy Settings State Management

## Objective
Create Flutter state management for privacy settings using provider pattern or similar. State should handle loading, updating, and persisting privacy settings with proper error handling.

## Acceptance Criteria
- [ ] PrivacySettingsProvider/PrivacySettingsNotifier class with state management
- [ ] Load privacy settings from API on user authentication
- [ ] Update privacy settings locally and sync to API
- [ ] Optimistic UI updates with rollback on error
- [ ] Error handling for API failures
- [ ] State persists across widget rebuilds
- [ ] Clear state on logout
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Load privacy settings successfully
- Handle API errors during load (network error, 401, 500)
- Update privacy settings locally before API call (optimistic update)
- Rollback on API update failure
- Sync state with API response after successful update
- Clear state on logout
- State persists across widget rebuilds (provider pattern)
- Concurrent update requests handled correctly

## Files to Modify/Create
- `pockitflyer_app/lib/providers/privacy_settings_provider.dart`
- `pockitflyer_app/lib/models/privacy_settings.dart` (data model)
- `pockitflyer_app/lib/services/privacy_settings_api_service.dart` (API client)
- `pockitflyer_app/test/providers/privacy_settings_provider_test.dart`
- `pockitflyer_app/test/services/privacy_settings_api_service_test.dart`

## Dependencies
- m02-e03-t03 (Backend privacy settings API)
- m02-e01-t06 (Authentication state management)

## Notes
- Use existing provider pattern from authentication
- Privacy settings loaded lazily when user visits settings screen
- Optimistic updates improve perceived performance
- Rollback strategy: revert to previous value on error, show error message
- Consider caching privacy settings in memory (no need for local storage beyond token)
