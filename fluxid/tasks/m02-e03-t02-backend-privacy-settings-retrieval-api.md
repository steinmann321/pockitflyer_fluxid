---
id: m02-e03-t02
epic: m02-e03
title: Create Privacy Settings Retrieval API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Privacy Settings Retrieval API Endpoint

## Objective
Implement Django REST API endpoint for retrieving the authenticated user's privacy settings. Endpoint requires authentication and only returns settings for the requesting user.

## Acceptance Criteria
- [ ] GET `/api/users/me/privacy-settings/` endpoint returns privacy settings
- [ ] Response includes: allow_email_contact
- [ ] Endpoint requires JWT authentication
- [ ] Returns 401 for unauthenticated requests
- [ ] Only returns settings for the requesting user (cannot view others' settings)
- [ ] Returns 404 if privacy settings don't exist (shouldn't happen with signal)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Authenticated user retrieves own privacy settings successfully
- Unauthenticated request returns 401
- Default settings retrieved correctly for new user
- Privacy settings with allow_email_contact=True retrieved correctly
- Privacy settings with allow_email_contact=False retrieved correctly
- Cannot access another user's privacy settings

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (PrivacySettingsRetrievalView)
- `pockitflyer_backend/users/serializers.py` (PrivacySettingsSerializer)
- `pockitflyer_backend/users/urls.py` (privacy settings retrieval route)
- `pockitflyer_backend/users/tests/test_privacy_settings_api.py`

## Dependencies
- m02-e03-t01 (PrivacySettings model)
- m02-e01-t02 (JWT authentication)

## Notes
- Endpoint is private - authentication required
- Use `/me/` pattern to indicate "current user" endpoint
- Serializer should be simple (single boolean field)
- Consider caching privacy settings if performance becomes issue
