---
id: m01-e02-t05
title: Image Carousel with Swipe and Dot Indicators
epic: m01-e02
milestone: m01
status: pending
---

# Task: Image Carousel with Swipe and Dot Indicators

## Context
Part of Core Feed Display and Interaction (m01-e02) in Browse and Discover Local Flyers (m01).

Replaces the single-image placeholder from m01-e02-t04 with a fully functional image carousel supporting 1-5 images, horizontal swipe gestures, and dot indicators showing current position. This enhances the flyer card by allowing multiple images per flyer.

## Implementation Guide for LLM Agent

### Objective
Build a swipeable image carousel widget that displays 1-5 images with dot indicators, smooth page transitions, and interactive buttons overlaid on the images.

### Steps
1. Create image carousel widget in `lib/features/feed/presentation/widgets/image_carousel.dart`:
   - StatefulWidget to manage current page state
   - Takes `List<String> images` parameter (1-5 URLs)
   - Use PageView.builder for horizontal swiping
   - Track current page index with PageController
   - Aspect ratio: consistent 16:9 or 4:3 (match card from m01-e02-t04)

2. Implement PageView structure:
   ```dart
   PageView.builder(
     controller: _pageController,
     onPageChanged: (index) {
       setState(() {
         _currentPage = index;
       });
     },
     itemCount: widget.images.length,
     itemBuilder: (context, index) {
       return Image.network(
         widget.images[index],
         fit: BoxFit.cover,
         loadingBuilder: (context, child, loadingProgress) {
           if (loadingProgress == null) return child;
           return Center(child: CircularProgressIndicator());
         },
         errorBuilder: (context, error, stackTrace) {
           return PlaceholderImage();
         },
       );
     },
   )
   ```

3. Create dot indicator widget in `lib/features/feed/presentation/widgets/carousel_dot_indicator.dart`:
   - Row of dots representing each image
   - Current page dot: larger, filled, accent color
   - Inactive dots: smaller, outlined or lighter color
   - Center-aligned below images
   - Spacing: 6-8px between dots
   - Dot size: active 10-12px, inactive 6-8px
   - Use AnimatedContainer for smooth transitions between active/inactive

4. Implement dot indicator builder:
   ```dart
   Row(
     mainAxisAlignment: MainAxisAlignment.center,
     children: List.generate(
       imageCount,
       (index) => AnimatedContainer(
         duration: Duration(milliseconds: 200),
         margin: EdgeInsets.symmetric(horizontal: 4),
         width: index == currentPage ? 12 : 8,
         height: index == currentPage ? 12 : 8,
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           color: index == currentPage
             ? Theme.of(context).colorScheme.primary
             : Colors.grey.withOpacity(0.4),
         ),
       ),
     ),
   )
   ```

5. Overlay interactive buttons on carousel:
   - Use Stack to position buttons on top of images
   - Position in top-right corner: Favorite, Share (placeholder), Location buttons
   - Same buttons from m01-e02-t04, same functionality
   - Add semi-transparent dark background behind icons for visibility
   - Buttons should work regardless of current image page

6. Integrate carousel into flyer card:
   - Replace `ImageSectionPlaceholder` in `flyer_card.dart` with `ImageCarousel`
   - Pass `flyer.images` list to carousel
   - Ensure carousel height matches previous placeholder (consistent card sizing)

7. Handle edge cases:
   - Single image (1 image): Show image without PageView, hide dot indicators
   - Empty images list: Show placeholder image with message
   - Failed image loading: Show error placeholder, allow retry
   - Very slow loading: Show loading indicator, timeout after 10s

8. Update mock data in `flyer_repository.dart`:
   - Modify mock flyers to include multiple images (1-5 per flyer)
   - Use varied image counts across different flyers
   - Use placeholder image URLs (e.g., picsum.photos or local assets)

9. Implement image caching optimization:
   - Use `CachedNetworkImage` package for better performance
   - Add to `pubspec.yaml`: `cached_network_image: ^3.3.0`
   - Replace Image.network with CachedNetworkImage for automatic caching
   - Configure cache duration and memory cache size

10. Add swipe physics and behavior:
    - Use PageView physics: `ClampingScrollPhysics()` or `BouncingScrollPhysics()`
    - Ensure smooth, natural swipe feel
    - Pages should snap to position (not free scroll)
    - Prevent vertical scroll interference with feed scroll

11. Create widget tests in `test/features/feed/presentation/widgets/`:
    - `image_carousel_test.dart`:
      - Test carousel renders all images
      - Test swiping changes current page
      - Test dot indicators update with page changes
      - Test single image shows no dots
      - Test empty images shows placeholder
      - Test loading state displays correctly
      - Test error state displays correctly
    - `carousel_dot_indicator_test.dart`:
      - Test correct number of dots render
      - Test active dot is styled differently
      - Test dot sizes and colors

12. Create integration tests:
    - Test carousel within flyer card in feed
    - Test swiping through images while feed is scrollable
    - Test buttons remain functional during swipe
    - Test multiple carousels in feed work independently

13. Performance testing and optimization:
    - Verify smooth 60fps swiping (no jank)
    - Test with multiple carousels in feed (10+ cards)
    - Check memory usage with image caching
    - Ensure feed scroll not affected by carousel swipes

14. Visual testing and polish:
    - Test on various iOS device sizes (SE, 14, Pro Max)
    - Verify dot indicators are clearly visible on light/dark images
    - Check button visibility on various image backgrounds
    - Test swipe gesture feels natural and responsive

### Acceptance Criteria
- [ ] Carousel displays 1-5 images per flyer [Test: create mock flyers with different image counts]
- [ ] Swipe gesture navigates between images smoothly [Test: swipe left/right, observe page change]
- [ ] Dot indicators show current image position [Test: swipe through images, verify active dot changes]
- [ ] Active dot is visually distinct from inactive dots [Test: visual inspection]
- [ ] Single image flyer shows no dot indicators [Test: flyer with 1 image]
- [ ] Interactive buttons (favorite, location) remain functional during swipe [Test: tap buttons while swiping]
- [ ] Image loading shows progress indicator [Test: slow network simulation]
- [ ] Failed image loading shows error placeholder [Test: invalid image URL]
- [ ] Carousel swipe doesn't interfere with feed scroll [Test: swipe horizontally in carousel, scroll vertically in feed]
- [ ] Performance is smooth with multiple carousels in feed [Test: scroll through feed with 10+ cards]
- [ ] Images are cached for faster subsequent loads [Test: scroll up/down, observe faster image loading]
- [ ] Widget tests pass with >85% coverage [Test: `flutter test --coverage`]

### Files to Create/Modify
- `pockitflyer_app/lib/features/feed/presentation/widgets/image_carousel.dart` - NEW: carousel widget
- `pockitflyer_app/lib/features/feed/presentation/widgets/carousel_dot_indicator.dart` - NEW: dot indicator widget
- `pockitflyer_app/lib/features/feed/presentation/widgets/flyer_card.dart` - MODIFY: replace placeholder with carousel
- `pockitflyer_app/lib/features/feed/data/repositories/flyer_repository.dart` - MODIFY: update mock data with multiple images
- `pockitflyer_app/pubspec.yaml` - MODIFY: add cached_network_image dependency
- `pockitflyer_app/test/features/feed/presentation/widgets/image_carousel_test.dart` - NEW: carousel tests
- `pockitflyer_app/test/features/feed/presentation/widgets/carousel_dot_indicator_test.dart` - NEW: dot indicator tests
- `pockitflyer_app/test/features/feed/presentation/widgets/flyer_card_test.dart` - MODIFY: update tests for carousel integration

### Testing Requirements
- **Unit tests**: Not applicable (no business logic)
- **Widget tests**: Carousel in isolation (render images, swipe behavior, page changes, dot indicator sync), dot indicator (render correct count, active state), edge cases (single image, empty images, loading, error)
- **Integration tests**: Carousel within flyer card within feed (swipe doesn't interfere with scroll), multiple carousels work independently, buttons remain functional during swipe

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter widget composition and performance best practices
- [ ] No console errors or warnings
- [ ] Swipe gesture is smooth and responsive (60fps)
- [ ] Image caching is working correctly
- [ ] Comments added for PageView configuration and state management
- [ ] Changes committed with reference to task ID (m01-e02-t05)
- [ ] Ready for backend API integration (m01-e01 backend will provide real image URLs)

## Dependencies
- Requires: m01-e02-t01 (app structure), m01-e02-t03 (feed and models), m01-e02-t04 (flyer card)
- Blocks: None (completes core feed display epic)

## Technical Notes
- **PageView**: Use PageView.builder for efficient rendering (only builds visible pages)
- **PageController**: Initialize with `viewportFraction: 1.0` for full-width pages
- **Image caching**: CachedNetworkImage provides automatic caching, placeholder, and error handling
- **Aspect ratio**: Use AspectRatio widget to maintain consistent image dimensions
- **Physics**: ClampingScrollPhysics prevents over-scroll on iOS, BouncingScrollPhysics allows bounce effect
- **State management**: Use StatefulWidget for page tracking (simple local state, no need for Riverpod)
- **Touch area**: Ensure swipe gesture detection covers full image area
- **Dot indicators**: Position absolutely over images (bottom center) or below images (separate section)
- **Performance**: Limit cached images in memory (configure CachedNetworkImage maxMemoryCacheSize)
- **Placeholder images**: Use https://picsum.photos for testing or add local assets

## References
- PageView widget: https://api.flutter.dev/flutter/widgets/PageView-class.html
- PageController: https://api.flutter.dev/flutter/widgets/PageController-class.html
- CachedNetworkImage: https://pub.dev/packages/cached_network_image
- AnimatedContainer: https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html
- Stack positioning: https://api.flutter.dev/flutter/widgets/Stack-class.html
- Image loading best practices: https://docs.flutter.dev/cookbook/images/cached-images
