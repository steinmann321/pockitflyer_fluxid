---
id: m01-e05-t04
title: Native Map App Integration (Apple Maps URL Scheme)
epic: m01-e05
milestone: m01
status: complete
---

# Task: Native Map App Integration (Apple Maps URL Scheme)

## Context
Part of Location Services and Navigation (m01-e05) in Milestone 01 (m01).

Implements integration with Apple Maps using the iOS URL scheme to provide navigation from user's current location to flyer locations. Users tap a location button on a flyer card, and the native Maps app opens with turn-by-turn directions to the business address.

## Implementation Guide for LLM Agent

### Objective
Create map navigation service that launches Apple Maps with correct destination coordinates and address, handles all error scenarios, and provides visual feedback during external app launch.

### Steps
1. Add URL launcher dependency to pubspec.yaml
   - Add `url_launcher: ^6.3.1` (for launching external apps)
   - Run `flutter pub get`

2. Configure iOS for URL scheme handling
   - File: `pockitflyer_app/ios/Runner/Info.plist`
   - Add LSApplicationQueriesSchemes for Apple Maps:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
     <string>maps</string>
     <string>comgooglemaps</string>
   </array>
   ```
   - Note: `maps` is Apple Maps, `comgooglemaps` is Google Maps (future support)

3. Create map navigation service
   - File: `pockitflyer_app/lib/services/map_navigation_service.dart`
   - Class: `MapNavigationService`
   - Dependencies: None (uses url_launcher directly)
   - Methods:
     - `Future<bool> openInMaps(double latitude, double longitude, {String? address})` - main method
     - `Future<bool> canLaunchMaps()` - check if Maps app available
     - `Uri _buildAppleMapsUri(double latitude, double longitude, {String? address})` - URI builder
     - `String _formatAddressForUrl(String address)` - URL-encode address

4. Implement Apple Maps URL scheme
   - Apple Maps URL format: `maps://?q=<address>&ll=<lat>,<lon>`
   - Alternative format: `https://maps.apple.com/?q=<address>&ll=<lat>,<lon>` (opens Maps app on iOS)
   - Parameters:
     - `q`: Query/destination (address or location name)
     - `ll`: Latitude,Longitude (coordinates)
     - `daddr`: Destination address (alternative to `q`)
   - Use coordinate-based navigation for accuracy (address as label)

   ```dart
   Uri _buildAppleMapsUri(double latitude, double longitude, {String? address}) {
     final String query = address != null ? _formatAddressForUrl(address) : '$latitude,$longitude';

     // Use https scheme for better iOS handling
     return Uri(
       scheme: 'https',
       host: 'maps.apple.com',
       path: '/',
       queryParameters: {
         'q': query,
         'll': '$latitude,$longitude',
       },
     );
   }

   String _formatAddressForUrl(String address) {
     // URL encoding handled by Uri.queryParameters
     return address.trim();
   }
   ```

5. Implement map launch with error handling
   ```dart
   Future<bool> openInMaps(double latitude, double longitude, {String? address}) async {
     try {
       final Uri mapsUri = _buildAppleMapsUri(latitude, longitude, address: address);

       final bool canLaunch = await canLaunchUrl(mapsUri);
       if (!canLaunch) {
         throw MapNavigationException('Maps app not available');
       }

       final bool launched = await launchUrl(
         mapsUri,
         mode: LaunchMode.externalApplication, // Open in Maps app, not in-app browser
       );

       return launched;
     } on MapNavigationException catch (e) {
       // Log error, show user message
       return false;
     } catch (e) {
       // Unexpected error
       return false;
     }
   }
   ```

6. Create custom exception for map navigation errors
   - File: `pockitflyer_app/lib/exceptions/map_navigation_exception.dart`
   - Class: `MapNavigationException extends Exception`
   - Include error message and optional error code
   - Error types:
     - Maps app not available (shouldn't happen on iOS)
     - Invalid coordinates (lat/lon out of range)
     - Launch failed (URL malformed)

7. Create map navigation button widget
   - File: `pockitflyer_app/lib/widgets/map_navigation_button.dart`
   - Widget: `MapNavigationButton`
   - Parameters:
     - `double latitude`
     - `double longitude`
     - `String? address`
     - `VoidCallback? onPressed` (optional override)
     - `Widget? child` (optional custom button content)
   - Default appearance: iOS-style icon button (location pin or navigation arrow)
   - Shows loading indicator while launching
   - Shows error feedback if launch fails
   - Integrates with `MapNavigationService`

8. Implement visual feedback during launch
   - Show loading indicator (spinner) while launching external app
   - Brief delay (100-200ms) to provide feedback before app switches
   - Error handling:
     - If launch fails: show Snackbar/Toast with error message
     - If Maps unavailable: show dialog with "Install Maps app" message (rare on iOS)

9. Create comprehensive test suite
   - File: `pockitflyer_app/test/services/map_navigation_service_test.dart`
   - Unit tests for MapNavigationService:
     - Test: `_buildAppleMapsUri` creates correct URL with coordinates only
     - Test: `_buildAppleMapsUri` creates correct URL with address and coordinates
     - Test: `_formatAddressForUrl` handles special characters
     - Test: `openInMaps` returns true when launch successful
     - Test: `openInMaps` returns false when Maps unavailable
     - Test: `openInMaps` handles invalid coordinates (lat >90, lon >180)
     - Test: `canLaunchMaps` returns true on iOS
   - Mock `url_launcher` package

   - File: `pockitflyer_app/test/widgets/map_navigation_button_test.dart`
   - Widget tests for MapNavigationButton:
     - Test: Button renders with correct icon
     - Test: Tapping button calls `openInMaps` with correct parameters
     - Test: Loading indicator shows while launching
     - Test: Error message displays on launch failure
     - Test: Custom button content renders correctly
   - Mock MapNavigationService

10. Add navigation button to flyer card UI
    - File: `pockitflyer_app/lib/widgets/flyer_card.dart` (should exist from m01-e02)
    - VERIFY flyer card component exists with flyer data
    - ADD MapNavigationButton to flyer card
    - Position: Near address/location information (typically top-right or bottom-right)
    - Pass flyer's latitude, longitude, and address to button
    - Handle missing coordinates gracefully (hide button if no location data)

### Acceptance Criteria
- [ ] Tapping location button opens Apple Maps app [Test: tap button on flyer card]
- [ ] Maps opens with correct destination coordinates [Test: verify lat/lon in Maps]
- [ ] Maps shows address as destination label [Test: verify address displayed in Maps]
- [ ] Invalid coordinates handled gracefully [Test: lat=999, lon=999 → error, no crash]
- [ ] Maps unavailable handled gracefully [Test: mock canLaunch false → error message]
- [ ] Loading indicator shows during launch [Test: verify spinner appears briefly]
- [ ] Error feedback shown on failure [Test: mock launch failure → see error message]
- [ ] URL encoding handles special characters in address [Test: address with spaces, commas, symbols]
- [ ] Button hidden if flyer has no location data [Test: flyer without lat/lon → no button]
- [ ] Tests pass with ≥85% coverage [Test: run flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/pubspec.yaml` - ADD: url_launcher dependency
- `pockitflyer_app/ios/Runner/Info.plist` - ADD: LSApplicationQueriesSchemes for maps
- `pockitflyer_app/lib/services/map_navigation_service.dart` - NEW: navigation service
- `pockitflyer_app/lib/exceptions/map_navigation_exception.dart` - NEW: custom exception
- `pockitflyer_app/lib/widgets/map_navigation_button.dart` - NEW: button widget
- `pockitflyer_app/lib/widgets/flyer_card.dart` - MODIFY: add navigation button (if exists from m01-e02)
- `pockitflyer_app/test/services/map_navigation_service_test.dart` - NEW: service tests
- `pockitflyer_app/test/widgets/map_navigation_button_test.dart` - NEW: widget tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - MapNavigationService.openInMaps with mocked url_launcher
  - URI building with various address formats
  - URL encoding for special characters
  - Error handling for invalid coordinates, launch failures
  - MapNavigationException creation and handling

- **Widget tests**:
  - MapNavigationButton rendering
  - Button press triggers openInMaps with correct parameters
  - Loading state displays spinner
  - Error state displays error message
  - Button hidden when no coordinates provided

- **Integration tests**:
  - Full navigation flow: button tap → service call → URL launch (mocked)
  - Flyer card with navigation button integration
  - Error handling across widget and service layers

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (TDD markers, minimal docs)
- [ ] No console errors or warnings
- [ ] Info.plist configured for URL schemes
- [ ] Maps launches with correct destination
- [ ] All error scenarios handled gracefully
- [ ] Visual feedback implemented (loading, errors)
- [ ] Changes committed with reference to task ID (m01-e05-t04)
- [ ] Epic m01-e05 complete (all location services functional)

## Dependencies
- Requires: m01-e01 (Flyer model with latitude/longitude/address fields)
- Requires: m01-e02 (Flyer card UI to integrate navigation button)
- Requires: m01-e05-t03 (coordinates available from flyer data)

## Technical Notes
**Apple Maps URL Schemes**:
- Modern format: `https://maps.apple.com/?q=...&ll=...` (preferred, works on all iOS versions)
- Legacy format: `maps://?q=...&ll=...` (older, still works)
- Using `https` scheme provides better fallback if Maps not installed (opens in browser, which redirects to Maps)

**URL Parameters**:
- `q`: Query string (address or location name) - shows as destination label
- `ll`: Latitude,Longitude - actual navigation destination
- `daddr`: Alternative to `q`, more explicit for destinations
- `saddr`: Source address (user's current location by default)
- `dirflg`: Direction flags (d=driving, w=walking, r=transit) - not needed, Maps handles this

**Coordinate Validation**:
- Latitude: -90 to +90 (negative = south, positive = north)
- Longitude: -180 to +180 (negative = west, positive = east)
- Backend should provide valid coordinates, but validate defensively

**Launch Modes** (url_launcher):
- `LaunchMode.externalApplication`: Opens in Maps app (REQUIRED for navigation)
- `LaunchMode.platformDefault`: May open in-app browser (NOT suitable)
- `LaunchMode.inAppWebView`: Opens in-app (NOT suitable for navigation)

**iOS Specific Behavior**:
- Maps app always available on iOS (no need to handle "not installed" case in production)
- LSApplicationQueriesSchemes required since iOS 9 for URL scheme querying
- User may have disabled Maps app (rare, but handle gracefully)

**Error Handling Strategy**:
- Invalid coordinates: Validate before launch, show error message
- Maps unavailable: Show error dialog (shouldn't happen on iOS)
- Launch failed: Show generic error, log details for debugging
- No coordinates on flyer: Hide navigation button entirely

**User Experience**:
- Button should be visually distinct (icon: location pin, navigation arrow, or "Directions")
- Loading feedback important: app switches to Maps, feels unresponsive without indicator
- Error feedback: Toast/Snackbar for transient errors, Dialog for critical errors

**Future Enhancements** (not in this task):
- Support for Google Maps (if user prefers)
- In-app map view (using map widget instead of external app)
- Navigation options (driving, walking, transit)
- Save favorite locations

## References
- Apple Maps URL Scheme: https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
- url_launcher package: https://pub.dev/packages/url_launcher
- iOS LSApplicationQueriesSchemes: https://developer.apple.com/documentation/uikit/uiapplication/1622952-canopenurl
- Coordinate validation: https://en.wikipedia.org/wiki/Geographic_coordinate_system
