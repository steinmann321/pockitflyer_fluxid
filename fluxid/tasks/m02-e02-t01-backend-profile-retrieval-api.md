---
id: m02-e02-t01
epic: m02-e02
title: Create Profile Retrieval API Endpoint
status: pending
priority: high
tdd_phase: red
---

# Task: Create Profile Retrieval API Endpoint

## Objective
Implement Django REST API endpoint for retrieving user profiles with published flyers. Endpoint is public (no authentication required) so any user can view any profile.

## Acceptance Criteria
- [ ] GET `/api/users/{user_id}/profile/` endpoint returns profile data
- [ ] Response includes: user_id, name, profile_picture_url, published_flyers
- [ ] Published flyers list includes only active (not expired) flyers
- [ ] Flyers sorted by created_at descending (newest first)
- [ ] Default avatar URL returned when user has no profile picture
- [ ] Endpoint accessible without authentication (public)
- [ ] Returns 404 for non-existent user
- [ ] Profile picture URL is absolute URL (not relative path)
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Valid user ID returns complete profile with flyers
- Valid user ID with no flyers returns empty flyers list
- Valid user ID with no profile picture returns default avatar URL
- Non-existent user ID returns 404
- Expired flyers excluded from published_flyers list
- Flyers sorted correctly by date (newest first)
- Anonymous access works (no authentication required)
- Profile picture URL is absolute and properly formatted

## Files to Modify/Create
- `pockitflyer_backend/users/views.py` (ProfileRetrievalView)
- `pockitflyer_backend/users/serializers.py` (ProfileSerializer, ProfileFlyerSerializer)
- `pockitflyer_backend/users/urls.py` (profile retrieval route)
- `pockitflyer_backend/users/tests/test_profile_api.py`

## Dependencies
- m02-e01-t01 (Profile model)
- m01-e01-t02 (Flyer model)

## Notes
- Endpoint is public - no authentication required for profile viewing
- Default avatar should be served from static files or external CDN
- Published flyers include minimal fields (id, title, thumbnail, created_at)
- Consider pagination for users with many flyers (optional for MVP)
- Profile picture URLs must work with CORS for image loading
