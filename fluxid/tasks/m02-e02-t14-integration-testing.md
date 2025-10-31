---
id: m02-e02-t14
epic: m02-e02
title: Profile System Integration Testing
status: pending
priority: medium
tdd_phase: red
---

# Task: Profile System Integration Testing

## Objective
Implement comprehensive integration tests verifying profile system works correctly across backend, frontend, and external services (Pillow, image storage).

## Acceptance Criteria
- [ ] Integration test: Full profile creation, update, and retrieval flow
- [ ] Integration test: Image upload with Pillow processing
- [ ] Integration test: Profile picture displayed in feed
- [ ] Integration test: Profile picture displayed in profile screen
- [ ] Integration test: Profile picture displayed in header
- [ ] Integration test: Circuit breaker pattern for Pillow failures
- [ ] Integration test: Profile changes reflected across all UI locations
- [ ] Integration test: Anonymous vs. authenticated access to profiles
- [ ] All tests marked with appropriate TDD markers after passing

## Test Coverage Requirements
- Backend + Frontend: Create profile → upload picture → view in feed
- Backend + Frontend: Update name → verify reflected in all UI
- Backend + Frontend: Anonymous user views public profile
- Backend: Circuit breaker triggers on Pillow failure
- Backend: Retry logic with exponential backoff works
- Backend: Old images cleaned up when new one uploaded
- Frontend: Image caching works across screens
- Frontend: Default avatar displayed when no picture
- Cross-system: Changes propagate within 1 second

## Files to Modify/Create
- `pockitflyer_backend/users/tests/test_profile_integration.py`
- `pockitflyer_backend/users/tests/test_image_upload_integration.py`
- `pockitflyer_app/integration_test/profile_integration_test.dart`

## Dependencies
- All other m02-e02 tasks (integration testing is final verification)
- m01-e05-t01 (E2E test infrastructure)

## Notes
- Integration tests verify multiple layers working together
- Use real image files (not mocks) for Pillow testing
- Test circuit breaker with intentional Pillow failures
- Verify profile changes propagate to all UI locations
- Tests should be slower than unit tests (acceptable tradeoff)
- Consider Docker setup for consistent test environment
