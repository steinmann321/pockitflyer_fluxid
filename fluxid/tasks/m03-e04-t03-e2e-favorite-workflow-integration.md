---
id: m03-e04-t03
epic: m03-e04
title: E2E Test - Complete Favorite Workflow Integration
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Favorite Workflow Integration

## Objective
Validate complete end-to-end favorite workflow including user registration/login, favoriting multiple flyers, filtering by favorites, unfavoriting, and cross-session persistence with real backend integration.

## Acceptance Criteria
- [ ] Maestro flow: `m03_e04_favorite_complete_workflow.yaml`
- [ ] Test steps:
  1. Launch app (fresh install)
  2. Navigate to feed as anonymous user
  3. Tap favorite button (verify auth prompt)
  4. Proceed to registration screen
  5. Complete registration (new test user)
  6. Return to feed (authenticated)
  7. Verify favorite button now enabled
  8. Favorite first flyer (category: Events)
  9. Verify button changes to filled heart (optimistic update)
  10. Wait for backend sync (2 seconds)
  11. Favorite second flyer (category: Nightlife)
  12. Favorite third flyer (category: Service)
  13. Favorite fourth flyer (category: Events)
  14. Favorite fifth flyer (category: Nightlife)
  15. Navigate to flyer detail for first favorited flyer
  16. Verify favorite button shows filled heart (state persists)
  17. Return to feed
  18. Tap "Favorites" filter button
  19. Verify filter activates (visual indication)
  20. Verify feed shows exactly 5 flyers (all favorited)
  21. Verify all 5 flyers have filled heart icons
  22. Scroll through all favorited flyers
  23. Unfavorite third flyer
  24. Verify flyer disappears from favorites feed immediately
  25. Tap "All" filter to return to full feed
  26. Verify unfavorited flyer visible with empty heart
  27. Force quit app
  28. Relaunch app
  29. Verify user still authenticated
  30. Navigate to Favorites filter
  31. Verify 4 favorited flyers visible (third still unfavorited)
  32. Pull-to-refresh
  33. Verify favorites feed updates from backend
- [ ] Backend validation:
  - 5 favorite records created in database
  - 1 favorite record deleted (unfavorite action)
  - Final state: 4 favorites persisted in database
  - All favorites linked to correct user and flyers
- [ ] Performance validation:
  - Favorite action responds within 200ms (optimistic update)
  - Backend sync completes within 2 seconds
  - Favorites filter loads within 2 seconds
  - Pull-to-refresh completes within 2 seconds
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Anonymous to authenticated transition via registration
- Multiple favorites across different categories
- Optimistic update UI (immediate button state change)
- Backend persistence (favorite records in database)
- State synchronization across navigation (feed ↔ detail)
- Filter activation and deactivation
- Unfavorite action (immediate UI update, backend delete)
- Cross-session persistence (app restart)
- Pull-to-refresh on favorites feed
- All 5 favorited flyers visible in filtered feed
- Correct flyer count after unfavorite

## Files to Modify/Create
- `maestro/flows/m03-e04/favorite_complete_workflow.yaml`
- `maestro/flows/m03-e04/favorite_registration_flow.yaml`
- `maestro/flows/m03-e04/favorite_multi_category.yaml`

## Dependencies
- m03-e04-t01 (M03 E2E test data infrastructure)
- m03-e04-t02 (Anonymous engagement workflow)
- m03-e01 (Complete Favorite Flyers epic)
- m03-e03 (Feed filters epic)
- m02-e01 (User registration and login)

## Notes
**Registration Flow Integration**:
- Test should create a NEW user account (not reuse existing test users)
- Email: `test_m03_e04_favorite_<timestamp>@pockitflyer.test`
- Password: Standard test password
- After registration, user should be automatically authenticated

**Multi-Category Favorites**:
- Favorite at least 1 flyer from each category (Events, Nightlife, Service)
- Verifies favorites filter works across all categories
- Verifies no category-specific filtering bugs

**Optimistic Update Validation**:
- Button state change must be immediate (<100ms perceived)
- No waiting for backend response before UI update
- If backend fails, UI should rollback (covered in error scenario tests)

**Backend Persistence Validation**:
- Use Django management command or API call to verify database state
- Query favorites table for user: expect 5 favorites initially, 4 after unfavorite
- Verify flyer IDs match favorited flyers in UI

**Cross-Session Persistence**:
- Force quit app (simulate user closing app)
- Relaunch app (cold start)
- Verify authentication token persisted (no login required)
- Verify favorites state persisted (favorites filter shows 4 flyers)

**Pull-to-Refresh**:
- While on Favorites filter, pull down to refresh
- Verify loading indicator appears
- Verify feed updates from backend (same 4 favorites)
- If backend data changed (flyer deleted, etc.), verify UI reflects change

**Performance Assertions**:
- Use Maestro `waitForAnimationToEnd` with timeout assertions
- Measure time from button tap to state change (<200ms)
- Measure time from filter tap to feed load (<2s)
- Fail test if performance thresholds not met

**Cleanup**:
- After test completion, delete test user and favorites
- Ensure no test data pollution in database
- Use `cleanup_m03_e2e_data` command or API call
