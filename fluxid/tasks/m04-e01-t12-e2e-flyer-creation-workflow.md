---
id: m04-e01-t12
epic: m04-e01
title: E2E Test Flyer Creation Workflow
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test Flyer Creation Workflow

## Objective
Create end-to-end Maestro tests for complete flyer creation and publication flow.

## Acceptance Criteria
- [ ] Test: Unauthenticated user clicks Flyern → redirected to login
- [ ] Test: Authenticated user clicks Flyern → creation screen opens
- [ ] Test: Upload 1 image → success
- [ ] Test: Upload 5 images → success
- [ ] Test: Upload 0 images → validation error
- [ ] Test: Upload 6 images → validation error
- [ ] Test: Fill all required fields → submit enabled
- [ ] Test: Missing required field → submit disabled
- [ ] Test: Invalid date range (expiration < publication) → validation error
- [ ] Test: Valid address → geocoding success
- [ ] Test: Invalid address → geocoding error message
- [ ] Test: Complete creation → flyer appears in feed
- [ ] Test: Network error during submit → error message and retry option
- [ ] Test: Optimistic update → flyer shows immediately, then persists
- [ ] All tests marked with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Authentication flow (unauthenticated redirect)
- Image upload validation (0, 1, 5, 6+ images)
- Text field validation (required, character limits)
- Category selection validation
- Address validation and geocoding
- Date validation
- Form submission success
- Form submission errors
- Optimistic UI update
- Feed integration
- Network error handling

## Files to Modify/Create
- `pockitflyer_app/maestro/flows/create_flyer_authenticated.yaml`
- `pockitflyer_app/maestro/flows/create_flyer_unauthenticated.yaml`
- `pockitflyer_app/maestro/flows/create_flyer_validation.yaml`
- `pockitflyer_app/maestro/flows/create_flyer_errors.yaml`

## Dependencies
- m04-e01-t10 (integrated creation screen)
- m04-e01-t11 (API client)
- M01 (feed display)
- M02 (authentication)
- Maestro E2E infrastructure

## Notes
- Use test data: sample images, valid/invalid addresses
- Mock geocoding service failures for error tests
- Verify flyer persistence with feed refresh
- Test image upload progress indicator
- Verify optimistic update rollback on error
- Test backend validates same fields as frontend
- Run against real backend or mock API
