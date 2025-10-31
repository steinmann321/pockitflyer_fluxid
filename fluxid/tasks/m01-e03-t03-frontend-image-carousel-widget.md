---
id: m01-e03-t03
epic: m01-e03
title: Build Image Carousel Widget with Pagination
status: pending
priority: high
tdd_phase: red
---

# Task: Build Image Carousel Widget with Pagination

## Objective
Create a reusable Flutter widget for displaying flyer image carousels with swipe gestures, pagination indicators, and support for 1-5 images with proper loading states and error handling.

## Acceptance Criteria
- [ ] Widget accepts list of image URLs (1-5 images)
- [ ] Horizontal swipe gesture to navigate between images
- [ ] Page indicator shows current position (dots or similar)
- [ ] Smooth transitions between images
- [ ] Images maintain aspect ratio and fill available space
- [ ] Loading state shows placeholder/skeleton while image loads
- [ ] Error state shows fallback image for failed loads
- [ ] Handles single image (no swipe, no indicator needed)
- [ ] Supports lazy loading (don't load all images immediately)
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Widget renders with single image (no pagination)
- Widget renders with multiple images (2-5)
- Swipe gesture changes current page
- Page indicator updates with swipes
- Boundary behavior (can't swipe past first/last)
- Loading state displayed during image fetch
- Error state displayed on failed image load
- Aspect ratio preservation (portrait, landscape, square)
- Rapid swipe handling (no jank)
- Widget rebuilds correctly when image list changes

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/flyer_image_carousel.dart`
- `pockitflyer_app/test/widgets/flyer_image_carousel_test.dart`

## Dependencies
- Flutter's PageView widget (built-in)
- Image caching package (cached_network_image or similar)

## Notes
- Use PageView.builder for efficient rendering
- Page indicator can use simple dots (• for current, ○ for others)
- Consider using `cached_network_image` package for loading states and caching
- Aspect ratio: use AspectRatio or BoxFit.cover to maintain image quality
- Single image case: hide page indicator, disable swipe
- Accessibility: provide image count for screen readers
