---
id: m03-e02-t10
epic: m03-e02
title: Prevent Self-Follow UI and Backend
status: pending
priority: medium
tdd_phase: red
---

# Task: Prevent Self-Follow UI and Backend

## Objective
Ensure users cannot follow themselves by hiding follow button on own profile and enforcing backend validation. Test both frontend UI hiding and backend API rejection.

## Acceptance Criteria
- [ ] FollowButton hidden on own profile page (creator.id == currentUser.id)
- [ ] Backend API rejects self-follow attempts with 400 Bad Request
- [ ] Backend validation occurs at model level (Follow.clean())
- [ ] API returns clear error message: "Cannot follow yourself"
- [ ] Frontend does not attempt self-follow API call (button hidden)
- [ ] All tests marked with `@pytest.mark.tdd_green` (backend) and `tags: ['tdd_green']` (frontend) after passing

## Test Coverage Requirements
- Backend: POST /api/follows/ with follower_id == followed_id returns 400
- Backend: Follow model validation raises ValidationError on self-follow
- Frontend: Own profile screen does not render FollowButton
- Frontend: FlyerCard for own flyer does not render FollowButton
- E2E: Navigating to own profile shows no follow button

## Files to Modify/Create
- `pockitflyer_backend/users/models.py` (update Follow.clean() validation)
- `pockitflyer_backend/users/tests/test_models.py` (add self-follow validation test)
- `pockitflyer_backend/users/tests/test_api.py` (add self-follow API test)
- `pockitflyer_app/lib/screens/creator_profile_screen.dart` (hide button logic)
- `pockitflyer_app/test/screens/creator_profile_screen_test.dart` (test button hiding)

## Dependencies
- m03-e02-t01 (Follow model must exist)
- m03-e02-t02 (Follow API must exist)
- m03-e02-t06 (Follow button integration complete)

## Notes
- Frontend hiding is primary UX - users should never see follow button on own profile
- Backend validation is defensive - prevents direct API abuse
- Validation error message should be user-friendly
- Consider edge case: viewing own profile while not authenticated (no button anyway)
