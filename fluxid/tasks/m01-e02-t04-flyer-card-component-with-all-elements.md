---
id: m01-e02-t04
title: Flyer Card Component with All Elements
epic: m01-e02
milestone: m01
status: pending
---

# Task: Flyer Card Component with All Elements

## Context
Part of Core Feed Display and Interaction (m01-e02) in Browse and Discover Local Flyers (m01).

Creates the comprehensive flyer card component displaying all required information: creator identity, image carousel (placeholder for now - full carousel in m01-e02-t05), location with distance, title, description, validity dates, and interactive buttons. This is the primary content unit users interact with in the feed.

## Implementation Guide for LLM Agent

### Objective
Build a complete, production-ready flyer card widget displaying all flyer information with interactive elements for favorite, follow, location, and profile navigation.

### Steps
1. Create flyer card widget in `lib/features/feed/presentation/widgets/flyer_card.dart`:
   - Replace placeholder from m01-e02-t03 with full implementation
   - StatelessWidget taking `FlyerModel` as parameter
   - Use Card widget with elevation and rounded corners
   - Overall card height: ~500-600px depending on content
   - Margin between cards: 16px vertical

2. Implement card structure (top to bottom):
   ```dart
   Card(
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         CardHeader(), // creator info + follow button
         ImageCarouselPlaceholder(), // single image for now
         LocationBar(), // location + distance
         ContentSection(), // title + description + info fields
         DateRangeSection(), // validity dates
       ],
     ),
   )
   ```

3. Create card header in `lib/features/feed/presentation/widgets/card_header.dart`:
   - Row layout: [Avatar, Creator Name, Spacer, Follow Button]
   - Avatar: CircleAvatar (40x40px) with creator image or fallback initial
   - Creator name: Text widget, medium weight font
   - Follow button: OutlinedButton or IconButton with "Follow" text/icon
   - Make avatar + name tappable (GestureDetector/InkWell) → navigate to `/profile/:creatorId`
   - Padding: 12px all around

4. Create image section placeholder in `lib/features/feed/presentation/widgets/image_section_placeholder.dart`:
   - For this task: display first image only (single Image.network or Image.asset)
   - Full carousel will be implemented in m01-e02-t05
   - Aspect ratio: 16:9 or 4:3 (consistent across all cards)
   - Width: full card width
   - Add three icon buttons overlaid on top-right:
     - Favorite button (heart icon)
     - Share button (placeholder for future - no functionality)
     - Location button (map pin icon)
   - Use Stack to overlay buttons on image

5. Create location bar in `lib/features/feed/presentation/widgets/location_bar.dart`:
   - Row layout: [Location Pin Icon, Address Text, Spacer, Distance Text]
   - Pin icon: Icons.location_on
   - Address: Truncate if too long (single line with ellipsis)
   - Distance: Format as "1.2 km" or "450 m"
   - Padding: 12px horizontal, 8px vertical
   - Light background color to separate from image

6. Create content section in `lib/features/feed/presentation/widgets/card_content.dart`:
   - Title: Bold, headline style, ~18-20px font size
   - Description: Body text, 2-3 lines with ellipsis if longer (expandable in future)
   - Info fields (infoField1, infoField2): Secondary text style, lighter color
   - Padding: 12px horizontal, 8px between elements

7. Create date range section in `lib/features/feed/presentation/widgets/date_range_section.dart`:
   - Row layout: [Calendar Icon, Date Range Text]
   - Format: "Valid from DD MMM to DD MMM YYYY" or "DD MMM - DD MMM YYYY"
   - Use package `intl` for date formatting
   - Secondary text style, smaller font
   - Padding: 12px horizontal, 8px vertical

8. Implement interactive button logic:
   - **Favorite button**:
     - State: not favorited (default for this task - actual state from Riverpod in m03)
     - OnPressed: Show snackbar "Login to save favorites" (placeholder)
     - Icon: Icons.favorite_border (unfilled) / Icons.favorite (filled)
   - **Follow button**:
     - State: not following (default for this task)
     - OnPressed: Show snackbar "Login to follow creators" (placeholder)
     - Text: "Follow" / "Following"
   - **Location button**:
     - OnPressed: Open native map app with flyer location
     - Use `url_launcher` package: `launchUrl(Uri.parse('https://maps.apple.com/?q=latitude,longitude'))`
     - Handle errors if map app not available
   - **Profile navigation** (avatar + name):
     - OnTap: Navigate to `/profile/:creatorId` using go_router
     - Use InkWell for ripple effect

9. Add helper utilities in `lib/features/feed/presentation/utils/`:
   - `distance_formatter.dart`: Format distance (meters → "450 m", kilometers → "1.2 km")
   - `date_formatter.dart`: Format date range for display

10. Update `pubspec.yaml`:
    - Add `intl: ^0.19.0` for date formatting
    - Add `url_launcher: ^6.3.0` for map integration
    - Run `flutter pub get`

11. Handle edge cases in card display:
    - Missing creator avatar: Show initial letter of name in CircleAvatar
    - Very long text: Truncate with ellipsis, ensure no overflow
    - Missing info fields: Hide if null/empty
    - Distance is null: Don't show distance (only address)
    - Invalid dates: Show error text or hide section

12. Create widget tests in `test/features/feed/presentation/widgets/`:
    - `flyer_card_test.dart`: Test card renders all elements with valid data
    - `card_header_test.dart`: Test creator info displays, follow button renders, tap navigates to profile
    - `location_bar_test.dart`: Test address and distance display, formatting
    - `card_content_test.dart`: Test title, description, info fields display
    - `date_range_section_test.dart`: Test date formatting and display
    - Test edge cases: missing avatar, null distance, very long text, null info fields

13. Create widget tests for interactions:
    - Test favorite button tap shows snackbar
    - Test follow button tap shows snackbar
    - Test location button tap launches URL
    - Test profile tap navigates to profile route

14. Visual testing and polish:
    - Run app and verify card design on different screen sizes
    - Check text truncation works correctly
    - Verify all interactive elements have proper touch targets (44x44 min)
    - Ensure card spacing and padding is consistent
    - Test dark mode compatibility (if theme supports it)

### Acceptance Criteria
- [ ] Flyer card displays all required elements [Test: widget test verifies all child widgets present]
- [ ] Creator avatar and name are tappable and navigate to profile [Test: tap gesture triggers route navigation]
- [ ] Favorite button shows correct icon and displays snackbar on tap [Test: tap button, see snackbar]
- [ ] Follow button shows correct text and displays snackbar on tap [Test: tap button, see snackbar]
- [ ] Location button opens native map app with correct coordinates [Test: tap button, verify URL launch]
- [ ] Location bar displays address and formatted distance [Test: various distances: 450m, 1.2km, 15km]
- [ ] Date range displays correctly formatted dates [Test: various date ranges]
- [ ] Title and description display without overflow [Test: very long text truncates with ellipsis]
- [ ] Missing optional fields (avatar, distance, info fields) handled gracefully [Test: null values don't cause errors]
- [ ] Card has proper spacing and visual hierarchy [Test: visual inspection on various screens]
- [ ] All interactive elements have ≥44x44 touch targets [Test: measure bounds]
- [ ] Widget tests pass with >85% coverage [Test: `flutter test --coverage`]

### Files to Create/Modify
- `pockitflyer_app/lib/features/feed/presentation/widgets/flyer_card.dart` - MODIFY: replace placeholder with full implementation
- `pockitflyer_app/lib/features/feed/presentation/widgets/card_header.dart` - NEW: creator info section
- `pockitflyer_app/lib/features/feed/presentation/widgets/image_section_placeholder.dart` - NEW: image display (single image)
- `pockitflyer_app/lib/features/feed/presentation/widgets/location_bar.dart` - NEW: location and distance
- `pockitflyer_app/lib/features/feed/presentation/widgets/card_content.dart` - NEW: title, description, info fields
- `pockitflyer_app/lib/features/feed/presentation/widgets/date_range_section.dart` - NEW: validity dates
- `pockitflyer_app/lib/features/feed/presentation/utils/distance_formatter.dart` - NEW: distance formatting utility
- `pockitflyer_app/lib/features/feed/presentation/utils/date_formatter.dart` - NEW: date formatting utility
- `pockitflyer_app/pubspec.yaml` - MODIFY: add intl and url_launcher dependencies
- `pockitflyer_app/test/features/feed/presentation/widgets/flyer_card_test.dart` - NEW: full card tests
- `pockitflyer_app/test/features/feed/presentation/widgets/card_header_test.dart` - NEW: header tests
- `pockitflyer_app/test/features/feed/presentation/widgets/location_bar_test.dart` - NEW: location tests
- `pockitflyer_app/test/features/feed/presentation/widgets/card_content_test.dart` - NEW: content tests
- `pockitflyer_app/test/features/feed/presentation/widgets/date_range_section_test.dart` - NEW: date tests
- `pockitflyer_app/test/features/feed/presentation/utils/distance_formatter_test.dart` - NEW: formatter tests
- `pockitflyer_app/test/features/feed/presentation/utils/date_formatter_test.dart` - NEW: formatter tests

### Testing Requirements
- **Unit tests**: Distance formatter (meters/km conversion, edge cases), date formatter (various date ranges, edge cases)
- **Widget tests**: Each card component in isolation (header, location bar, content, dates), full card composition with various data scenarios (complete data, missing optionals, edge cases), interaction tests (taps trigger correct actions)
- **Integration tests**: Card in feed context with navigation (tap profile navigates, tap location launches URL), full interaction flow

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter widget composition best practices
- [ ] No console errors or warnings
- [ ] No layout overflow errors with various data lengths
- [ ] All interactive elements provide visual feedback (ripple effects, state changes)
- [ ] Comments added for complex layout logic and formatting decisions
- [ ] Changes committed with reference to task ID (m01-e02-t04)
- [ ] Ready for image carousel implementation (m01-e02-t05)

## Dependencies
- Requires: m01-e02-t01 (app structure), m01-e02-t02 (header), m01-e02-t03 (feed and models)
- Blocks: m01-e02-t05 (image carousel will replace placeholder)

## Technical Notes
- **Card design**: Use Material Design Card with elevation 2-4, rounded corners (8-12px radius)
- **Image aspect ratio**: Keep consistent across all cards for visual harmony (recommend 16:9 or 4:3)
- **Text truncation**: Use `maxLines` and `overflow: TextOverflow.ellipsis` to prevent overflow
- **Distance formatting**: Display meters for <1000m, kilometers for ≥1000m, 1 decimal place for km
- **Date formatting**: Use `intl` package's DateFormat for localized date display
- **Map integration**: Use Apple Maps on iOS (`https://maps.apple.com/?q=lat,long`), configure url_launcher for iOS in Info.plist
- **Touch targets**: Wrap small buttons in Padding to achieve 44x44 minimum
- **Navigation**: Use go_router's `context.go('/profile/$creatorId')`
- **Snackbars**: Use ScaffoldMessenger.of(context).showSnackBar for placeholder messages
- **Null safety**: Handle null/empty fields gracefully with null-aware operators and conditional rendering

## References
- Material Card: https://api.flutter.dev/flutter/material/Card-class.html
- url_launcher package: https://pub.dev/packages/url_launcher
- intl package: https://pub.dev/packages/intl
- Text overflow handling: https://api.flutter.dev/flutter/painting/TextOverflow-class.html
- Apple Maps URL scheme: https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
