import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/models/location.dart';

void main() {
  group('Location Model Tests', () {
    test('creates Location with all fields', () {
      final location = Location(
        address: '123 Main St, City',
        lat: 37.7749,
        lng: -122.4194,
        distanceKm: 1.5,
      );

      expect(location.address, '123 Main St, City');
      expect(location.lat, 37.7749);
      expect(location.lng, -122.4194);
      expect(location.distanceKm, 1.5);
    }, tags: ['tdd_green']);

    test('creates Location from JSON with distance', () {
      final json = {
        'address': 'Test Address',
        'lat': 10.0,
        'lng': 20.0,
        'distance_km': 3.5,
      };
      final location = Location.fromJson(json);

      expect(location.address, 'Test Address');
      expect(location.lat, 10.0);
      expect(location.lng, 20.0);
      expect(location.distanceKm, 3.5);
    }, tags: ['tdd_green']);

    test('creates Location from JSON with null distance', () {
      final json = {
        'address': 'Test',
        'lat': 0.0,
        'lng': 0.0,
        'distance_km': null,
      };
      final location = Location.fromJson(json);

      expect(location.distanceKm, isNull);
    }, tags: ['tdd_green']);

    test('converts Location to JSON', () {
      final location = Location(
        address: 'Addr',
        lat: 1.0,
        lng: 2.0,
        distanceKm: 0.5,
      );
      final json = location.toJson();

      expect(json['address'], 'Addr');
      expect(json['lat'], 1.0);
      expect(json['lng'], 2.0);
      expect(json['distance_km'], 0.5);
    }, tags: ['tdd_green']);

    test('equality works correctly', () {
      final loc1 = Location(address: 'A', lat: 1, lng: 2, distanceKm: 3);
      final loc2 = Location(address: 'A', lat: 1, lng: 2, distanceKm: 3);
      final loc3 = Location(address: 'B', lat: 1, lng: 2, distanceKm: 3);

      expect(loc1 == loc2, isTrue);
      expect(loc1.hashCode, loc2.hashCode);
      expect(loc1 == loc3, isFalse);
    }, tags: ['tdd_green']);
  });
}
