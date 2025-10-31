---
id: m01-e05-t03
title: Distance Calculation Utilities and Formatting
epic: m01-e05
milestone: m01
status: complete
---

# Task: Distance Calculation Utilities and Formatting

## Context
Part of Location Services and Navigation (m01-e05) in Milestone 01 (m01).

Implements distance calculation between user location and flyer locations using the Haversine formula for great-circle distance. Provides formatted distance strings with appropriate units (meters/kilometers) for display in the UI. This task enables the core proximity-based features of PokitFlyer.

## Implementation Guide for LLM Agent

### Objective
Create distance calculation utilities that accurately compute distances between coordinates using the Haversine formula and format them for user-friendly display with automatic unit selection.

### Steps
1. Create distance calculation utility class
   - File: `pockitflyer_app/lib/utils/distance_calculator.dart`
   - Class: `DistanceCalculator`
   - Static methods (no instance needed, pure functions):
     - `double calculateDistance(double lat1, double lon1, double lat2, double lon2)` - returns distance in meters
     - `String formatDistance(double distanceInMeters)` - returns formatted string
     - `bool isNearby(double distanceInMeters, {double thresholdKm = 5.0})` - proximity check

2. Implement Haversine formula for distance calculation
   ```dart
   static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
     const double earthRadiusKm = 6371.0; // Earth's radius in kilometers

     // Convert degrees to radians
     final double lat1Rad = _degreesToRadians(lat1);
     final double lon1Rad = _degreesToRadians(lon1);
     final double lat2Rad = _degreesToRadians(lat2);
     final double lon2Rad = _degreesToRadians(lon2);

     // Haversine formula
     final double dLat = lat2Rad - lat1Rad;
     final double dLon = lon2Rad - lon1Rad;

     final double a = sin(dLat / 2) * sin(dLat / 2) +
                      cos(lat1Rad) * cos(lat2Rad) *
                      sin(dLon / 2) * sin(dLon / 2);

     final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

     final double distanceKm = earthRadiusKm * c;
     return distanceKm * 1000; // Convert to meters
   }

   static double _degreesToRadians(double degrees) {
     return degrees * pi / 180.0;
   }
   ```

3. Implement distance formatting with unit selection
   - Rules:
     - Distance < 1000m: show in meters (e.g., "250 m", "850 m")
     - Distance ≥ 1000m: show in kilometers with 1 decimal place (e.g., "1.2 km", "15.7 km")
   - Handle edge cases:
     - 0 meters: "0 m"
     - Very small distances (< 1m): "< 1 m"
     - Very large distances (≥ 10000 km): show as integers "10,234 km"
   - Internationalization considerations:
     - Use locale-aware number formatting if available
     - For now, use simple formatting with space before unit

   ```dart
   static String formatDistance(double distanceInMeters) {
     if (distanceInMeters < 1.0) {
       return "< 1 m";
     } else if (distanceInMeters < 1000.0) {
       return "${distanceInMeters.round()} m";
     } else {
       final double distanceKm = distanceInMeters / 1000.0;
       if (distanceKm >= 100.0) {
         // Large distances: show as integer km
         return "${distanceKm.round()} km";
       } else {
         // Medium distances: show with 1 decimal
         return "${distanceKm.toStringAsFixed(1)} km";
       }
     }
   }
   ```

4. Implement proximity check utility
   - Default threshold: 5 km (configurable)
   - Used for "Near Me" filter
   ```dart
   static bool isNearby(double distanceInMeters, {double thresholdKm = 5.0}) {
     final double distanceKm = distanceInMeters / 1000.0;
     return distanceKm <= thresholdKm;
   }
   ```

5. Create distance service for flyer list integration
   - File: `pockitflyer_app/lib/services/distance_service.dart`
   - Class: `DistanceService`
   - Dependencies: `LocationTrackingService` (from m01-e05-t02)
   - Methods:
     - `String? getDistanceToFlyer(double flyerLat, double flyerLon)` - returns formatted distance or null if location unavailable
     - `List<Flyer> sortByDistance(List<Flyer> flyers)` - sorts flyers by proximity
     - `List<Flyer> filterNearby(List<Flyer> flyers, {double thresholdKm = 5.0})` - filters by proximity
     - `Stream<void> get locationUpdateStream` - notifies when distances should be recalculated
   - Handle missing user location gracefully (return null for distances)

6. Integrate distance calculations with existing flyer model
   - File: `pockitflyer_app/lib/models/flyer.dart` (should exist from m01-e01/m01-e02)
   - VERIFY flyer model has `latitude` and `longitude` fields (from backend)
   - DO NOT modify flyer model structure - distances are calculated on-demand, not stored
   - Distance display logic will be in UI layer (m01-e02)

7. Create comprehensive test suite
   - File: `pockitflyer_app/test/utils/distance_calculator_test.dart`
   - Unit tests for DistanceCalculator:
     - Test: Same location returns 0 meters [Test: (0,0) to (0,0)]
     - Test: Short distance accuracy <1% error [Test: NYC to nearby point, verify ±1%]
     - Test: Long distance accuracy <1% error [Test: NYC to London, verify known distance]
     - Test: Equator distance calculation [Test: (0,0) to (0,1), verify ~111 km]
     - Test: Polar distance calculation [Test: (89,0) to (89,1), verify shorter distance]
     - Test: International date line crossing [Test: (0,-179) to (0,179)]
     - Test: North/South hemisphere [Test: (45,0) to (-45,0)]
     - Test: formatDistance shows meters for <1000m [Test: 0, 1, 500, 999]
     - Test: formatDistance shows km for ≥1000m [Test: 1000, 1500, 10000, 100000]
     - Test: formatDistance boundary conditions [Test: 999m → "999 m", 1000m → "1.0 km"]
     - Test: formatDistance very small distances [Test: 0.5m → "< 1 m"]
     - Test: formatDistance large distances [Test: 123456m → "123 km"]
     - Test: isNearby with default threshold [Test: 4.9km → true, 5.1km → false]
     - Test: isNearby with custom threshold [Test: custom 10km threshold]

   - File: `pockitflyer_app/test/services/distance_service_test.dart`
   - Unit tests for DistanceService:
     - Test: getDistanceToFlyer returns formatted string when location available
     - Test: getDistanceToFlyer returns null when location unavailable
     - Test: sortByDistance orders flyers by proximity (closest first)
     - Test: filterNearby returns only flyers within threshold
     - Test: locationUpdateStream emits when user location changes
   - Mock LocationTrackingService

### Acceptance Criteria
- [ ] Distance calculation accuracy within <1% error for various coordinates [Test: known distances, compare results]
- [ ] Distance formatting shows meters for <1000m [Test: 250m → "250 m", 850m → "850 m"]
- [ ] Distance formatting shows km for ≥1000m [Test: 1200m → "1.2 km", 15700m → "15.7 km"]
- [ ] Boundary conditions handled correctly [Test: 999m → "999 m", 1000m → "1.0 km"]
- [ ] Very small distances formatted as "< 1 m" [Test: 0.5m → "< 1 m"]
- [ ] Large distances formatted without decimals [Test: 123456m → "123 km"]
- [ ] Same location returns 0m distance [Test: identical coordinates]
- [ ] International date line crossing handled [Test: (0,-179) to (0,179)]
- [ ] Proximity check returns correct boolean [Test: 4.9km → true, 5.1km → false for 5km threshold]
- [ ] Tests pass with ≥85% coverage [Test: run flutter test with coverage]

### Files to Create/Modify
- `pockitflyer_app/lib/utils/distance_calculator.dart` - NEW: distance calculation and formatting
- `pockitflyer_app/lib/services/distance_service.dart` - NEW: flyer distance service
- `pockitflyer_app/test/utils/distance_calculator_test.dart` - NEW: calculator tests
- `pockitflyer_app/test/services/distance_service_test.dart` - NEW: service tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - DistanceCalculator.calculateDistance with known coordinate pairs (verify accuracy <1%)
  - DistanceCalculator.formatDistance with all edge cases (meters, km, boundaries, very small, very large)
  - DistanceCalculator.isNearby with default and custom thresholds
  - Edge cases: same location, equator, poles, date line, hemispheres
  - DistanceService methods with mocked LocationTrackingService

- **Integration tests**:
  - Full distance calculation workflow: get user location → calculate distances → format
  - Sort flyers by distance with varying user locations
  - Filter nearby flyers with different thresholds
  - Distance updates when user location changes

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (TDD markers, minimal docs)
- [ ] No console errors or warnings
- [ ] Distance calculation accuracy validated (<1% error)
- [ ] All formatting edge cases handled correctly
- [ ] Proximity filtering works as expected
- [ ] Changes committed with reference to task ID (m01-e05-t03)
- [ ] Ready for UI integration (m01-e02 will consume) and map navigation (m01-e05-t04)

## Dependencies
- Requires: m01-e05-t02 (LocationTrackingService for user coordinates)
- Requires: m01-e01 (Flyer model with latitude/longitude fields from backend)
- Blocks: m01-e02 (feed display will show distances on flyer cards)
- Blocks: m01-e05-t04 (map navigation uses coordinates)

## Technical Notes
**Haversine Formula Accuracy**:
- Assumes Earth is a perfect sphere (6371 km radius)
- Actual Earth is an oblate spheroid, causing ~0.3% error
- Error increases for very long distances (>1000 km)
- Acceptable for flyer proximity use case (<100 km typical)

**Alternative: Vincenty Formula**:
- More accurate (considers Earth's ellipsoid shape)
- Much more complex computation
- Overkill for this use case
- Haversine is standard for "good enough" distance calculation

**Distance Units**:
- Backend stores coordinates in decimal degrees (standard)
- Calculations return meters (SI unit)
- Display converts to km for readability
- No imperial units (miles) for MVP

**Performance Considerations**:
- Distance calculation is O(1) per flyer
- For 1000 flyers: ~1ms on modern phones
- No need for optimization or caching
- Recalculate on-demand when user location changes

**Precision**:
- Double precision sufficient for ~1mm accuracy at equator
- Coordinate precision from backend (typically 6-8 decimal places)
- Display precision: meters (integer) or km (1 decimal)

**Edge Cases**:
- Antipodal points (opposite sides of Earth): formula still works
- International date line: longitude wraps at ±180°, formula handles correctly
- Poles: latitude ±90°, formula handles correctly (distance approaches 0)

**Testing Strategy**:
- Use known distances between famous cities (e.g., NYC to London = 5,585 km)
- Verify calculated distance within 1% of known value
- Test boundary conditions (0m, 999m, 1000m, very large distances)
- Test special locations (equator, poles, date line)

## References
- Haversine Formula: https://en.wikipedia.org/wiki/Haversine_formula
- Great-circle distance: https://en.wikipedia.org/wiki/Great-circle_distance
- Vincenty Formula (alternative): https://en.wikipedia.org/wiki/Vincenty%27s_formulae
- Earth radius: https://en.wikipedia.org/wiki/Earth_radius
- Coordinate precision: https://en.wikipedia.org/wiki/Decimal_degrees
