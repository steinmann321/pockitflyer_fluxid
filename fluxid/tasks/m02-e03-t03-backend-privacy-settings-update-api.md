---
id: m02-e03-t03
epic: m02-e03
title: Create Privacy Settings Update API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Privacy Settings Update API Endpoint

## Objective
Implement Django REST API endpoint for updating the authenticated user's privacy settings. Endpoint requires authentication and only allows users to update their own settings with proper validation.

## Acceptance Criteria
- [ ] PATCH `/api/users/me/privacy-settings/` endpoint updates privacy settings
- [ ] Request body: { "allow_email_contact": true/false }
- [ ] Endpoint requires JWT authentication
- [ ] Returns 401 for unauthenticated requests
- [ ] Returns 400 for invalid data (non-boolean values, missing field)
- [ ] Only updates settings for the requesting user
- [ ] Returns updated settings in response
- [ ] Update completes within 2 seconds
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Authenticated user updates own privacy settings successfully
- Toggle allow_email_contact from True to False
- Toggle allow_email_contact from False to True
- Unauthenticated request returns 401
- Invalid data (non-boolean) returns 400 with error message
- Missing field returns 400 with error message
- Cannot update another user's privacy settings
- Concurrent updates handled correctly (last write wins or optimistic locking)

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (PrivacySettingsUpdateView or extend retrieval view)
- `pockitflyer_backend/users/serializers.py` (update PrivacySettingsSerializer if needed)
- `pockitflyer_backend/users/urls.py` (privacy settings update route if separate)
- `pockitflyer_backend/users/tests/test_privacy_settings_api.py` (add update tests)

## Dependencies
- m02-e03-t02 (Privacy settings retrieval API)

## Notes
- Use PATCH instead of PUT (partial update)
- Consider combining retrieval and update into single ViewSet
- Validation should reject non-boolean values explicitly
- Response should include updated settings for client state sync
- Consider rate limiting for privacy settings updates (prevent abuse)
