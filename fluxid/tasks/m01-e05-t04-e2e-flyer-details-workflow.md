---
id: m01-e05-t04
epic: m01-e05
title: E2E Test - Complete Flyer Details Workflow (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Complete Flyer Details Workflow (No Mocks)

## Objective
Validate complete flyer details and location viewing workflow end-to-end using real Django backend with real image storage, real coordinates, and real iOS Maps deep linking without mocks.

## Acceptance Criteria
- [ ] Maestro flow: `m01_e05_flyer_details_complete.yaml`
- [ ] Test steps:
  1. Start real Django backend with E2E test data
  2. Launch iOS app and navigate to feed
  3. Tap on flyer card
  4. Assert: flyer detail screen loads
  5. Verify all detail fields displayed correctly:
     - Creator name (matches database)
     - All images loaded from backend storage (1-5 images)
     - Title and description (exact match to database)
     - Address (formatted correctly)
     - Distance (accurate within 100m)
     - Validity dates (formatted correctly)
     - Category badge
  6. Swipe image carousel left/right
  7. Assert: all images load and display correctly (no broken images)
  8. Verify image order matches backend data
  9. Tap location/address button
  10. Assert: iOS Maps app launches (deep link works)
  11. Verify: Maps opens with correct coordinates (extract from URL scheme)
  12. Return to app (background/foreground test)
  13. Assert: flyer detail screen preserved (no data loss)
  14. Navigate back to feed
  15. Assert: feed scroll position preserved
- [ ] Real service validations:
  - Backend API returns flyer detail JSON with all fields
  - Images served from real storage (backend media files or cloud storage)
  - Image URLs valid and accessible from iOS app
  - Coordinates match backend geocoded data
  - iOS Maps deep link uses correct URL scheme with accurate coordinates
- [ ] Performance under realistic conditions:
  - Flyer detail screen loads in <1 second
  - Images load progressively (thumbnail first, high-res second)
  - Image carousel swipe smooth (60fps)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete vertical slice: tap flyer → load details → view images → open Maps
- All flyer detail field accuracy (no mock data mismatches)
- Image carousel with 1, 3, and 5 images (test various counts)
- Image loading and caching (second view faster)
- Coordinate accuracy (verify Maps deep link coordinates)
- Deep link to iOS Maps (URL scheme validation)
- Background/foreground app lifecycle
- Navigation state preservation
- Error states: missing images, invalid coordinates, Maps not installed
- Accessibility: VoiceOver support, image alt text

## Files to Modify/Create
- `maestro/flows/m01-e05/flyer_details_complete_workflow.yaml`
- `maestro/flows/m01-e05/flyer_details_image_carousel.yaml`
- `maestro/flows/m01-e05/flyer_details_maps_deeplink.yaml`
- `maestro/flows/m01-e05/flyer_details_error_states.yaml`
- `pockitflyer_backend/scripts/verify_image_urls.py` (validate all test images accessible)

## Dependencies
- m01-e05-t01 (E2E test data infrastructure with real images)
- m01-e03-t01 through m01-e03-t06 (all flyer details implementation)
- m01-e03-t07 (basic E2E flyer details flow, which this extends)

## Notes
**Critical: NO MOCKS**
- Real Django backend serving flyer detail API
- Real image storage (backend media files or cloud storage URLs)
- Real iOS app making actual HTTP requests for details and images
- Real iOS Maps deep linking (actual URL scheme, not mocked)
- Real coordinates from geopy geocoding

**Image Handling**:
- Test data must include flyers with 1, 3, and 5 images
- Images stored in backend media directory or cloud storage (S3, etc.)
- Image URLs absolute and accessible from iOS simulator
- Test progressive loading: thumbnail → high-res
- Test image caching: second view should load faster (measure time)

**Image Carousel Testing**:
- Swipe gestures left/right
- Indicator dots show current image
- Edge behavior: can't swipe past first/last image
- Image zoom/pinch (if implemented)

**iOS Maps Deep Link Validation**:
- URL scheme: `maps://` or `http://maps.apple.com/`
- Coordinates in URL match flyer backend data
- Extract coordinates from deep link URL in test
- Assert coordinates match expected (within 0.0001 degree tolerance)
- Handle case: Maps app not installed (show error, don't crash)

**Performance Validation**:
- Detail screen load: <1 second from tap to full display
- Image loading: thumbnail <500ms, high-res <2 seconds
- Carousel swipe: smooth 60fps (no stuttering)
- Measure and log timings in test results

**Error States**:
1. Missing image (backend returns 404) - should show placeholder
2. Invalid coordinates (null/empty) - should disable Maps button
3. Network error during load - should show retry button
4. Maps app not installed - should show "Maps not available" message

**App Lifecycle Testing**:
1. Open flyer detail screen
2. Tap Maps button (app backgrounds)
3. Return to app from background
4. Assert: detail screen still visible, data intact
5. No re-fetch from backend (cached data used)

**Accessibility Testing**:
- VoiceOver reads all flyer detail fields correctly
- Images have descriptive alt text
- Carousel swipe accessible via VoiceOver gestures
- Maps button labeled clearly for screen readers
