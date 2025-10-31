---
id: m01-e03-t07
epic: m01-e03
title: E2E Test - Flyer Detail Viewing and Map Navigation
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Flyer Detail Viewing and Map Navigation

## Objective
Create comprehensive end-to-end tests using Maestro to validate the complete user flow of viewing flyer details and navigating to map location, covering all success criteria from the epic.

## Acceptance Criteria
- [ ] Test: Tap flyer card in feed → detail screen opens
- [ ] Test: Image carousel swipe (1 image, 5 images, rapid swipes, boundaries)
- [ ] Test: Pagination indicator updates with swipes
- [ ] Test: All flyer information displayed correctly
- [ ] Test: Long description wraps properly
- [ ] Test: Distance formatted correctly (meters vs kilometers)
- [ ] Test: Valid until date displayed
- [ ] Test: Tap location → iOS Maps opens (verify URL launch attempt)
- [ ] Test: Image loading states (first load, cached load)
- [ ] Test: Image error handling (network failure, invalid URL)
- [ ] Test: Navigation back to feed preserves scroll position
- [ ] All tests tagged with `@pytest.mark.tdd_green` (if applicable) or equivalent for Maestro

## Test Coverage Requirements
- Happy path: feed → detail → carousel → map launch → back to feed
- Single image flyer (no pagination needed)
- Multiple images (2, 3, 5 images)
- Swipe gestures at boundaries (first/last image)
- Rapid swipe handling
- Text content edge cases (very long description, short description)
- Distance display variations (<1km, >1km, very far)
- Network conditions (first load, cached load, offline with cache)
- Error states (404 flyer, failed image load)
- Map deep link success (Maps app launch verified)

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/m01_e03_view_flyer_detail.yaml`
- `pockitflyer_app/maestro/flows/m01_e03_image_carousel.yaml`
- `pockitflyer_app/maestro/flows/m01_e03_map_navigation.yaml`
- Backend fixtures: `pockitflyer_backend/flyers/fixtures/m01_e03_test_flyers.json`

## Dependencies
- All other m01-e03 tasks must be complete
- Maestro E2E framework (already in project)
- Backend API must be running for E2E tests
- Test fixtures with known flyer data

## Notes
- Maestro flows reference existing m01-e01 infrastructure
- Test data: create flyers with 1, 3, and 5 images for carousel testing
- Map launch verification: Maestro can detect URL launch intent (iOS specific)
- Image caching tests may need network simulation (Maestro network conditions)
- Consider splitting into multiple Maestro flows for maintainability
- Success criteria from epic map directly to test cases
- Run E2E tests as part of pre-push hooks (comprehensive validation)
