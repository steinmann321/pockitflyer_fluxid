import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/models/creator.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:pockitflyer_app/models/flyer_image.dart';
import 'package:pockitflyer_app/models/paginated_response.dart';

void main() {
  group('PaginatedFeedResponse', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'count': 100,
        'next': 'http://example.com/api/feed/?page=2',
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Test Flyer',
            'description': 'Test Description',
            'creator': {
              'id': 1,
              'username': 'testuser',
              'profile_picture_url': null,
            },
            'images': [
              {'url': 'http://example.com/image.jpg', 'order': 0},
            ],
            'location_address': '123 Test St',
            'latitude': 47.5,
            'longitude': 8.5,
            'distance_km': 1.5,
            'valid_from': '2024-01-01T00:00:00Z',
            'valid_until': '2024-12-31T23:59:59Z',
            'is_valid': true,
          },
        ],
      };

      final response = PaginatedFeedResponse.fromJson(json);

      expect(response.count, 100);
      expect(response.next, 'http://example.com/api/feed/?page=2');
      expect(response.previous, null);
      expect(response.results.length, 1);
      expect(response.results[0].id, 1);
      expect(response.results[0].title, 'Test Flyer');
    }, tags: ['tdd_green']);

    test('fromJson handles null next and previous', () {
      final json = {
        'count': 1,
        'next': null,
        'previous': null,
        'results': <Map<String, dynamic>>[],
      };

      final response = PaginatedFeedResponse.fromJson(json);

      expect(response.count, 1);
      expect(response.next, null);
      expect(response.previous, null);
      expect(response.results, isEmpty);
    }, tags: ['tdd_green']);

    test('fromJson handles empty results', () {
      final json = {
        'count': 0,
        'next': null,
        'previous': null,
        'results': <Map<String, dynamic>>[],
      };

      final response = PaginatedFeedResponse.fromJson(json);

      expect(response.count, 0);
      expect(response.results, isEmpty);
    }, tags: ['tdd_green']);

    test('toJson creates correct map', () {
      final flyer = Flyer(
        id: 1,
        title: 'Test Flyer',
        description: 'Test Description',
        creator: Creator(
          id: 1,
          username: 'testuser',
        ),
        images: [
          FlyerImage(url: 'http://example.com/image.jpg', order: 0),
        ],
        locationAddress: '123 Test St',
        latitude: 47.5,
        longitude: 8.5,
        distanceKm: 1.5,
        validFrom: DateTime.parse('2024-01-01T00:00:00Z'),
        validUntil: DateTime.parse('2024-12-31T23:59:59Z'),
        isValid: true,
      );

      final response = PaginatedFeedResponse(
        count: 100,
        next: 'http://example.com/api/feed/?page=2',
        previous: null,
        results: [flyer],
      );

      final json = response.toJson();

      expect(json['count'], 100);
      expect(json['next'], 'http://example.com/api/feed/?page=2');
      expect(json['previous'], null);
      expect(json['results'], isList);
      expect((json['results'] as List).length, 1);
    }, tags: ['tdd_green']);

    test('equality works correctly', () {
      final flyer = Flyer(
        id: 1,
        title: 'Test',
        description: 'Desc',
        creator: Creator(id: 1, username: 'user'),
        images: [],
        locationAddress: 'addr',
        latitude: 1.0,
        longitude: 1.0,
        validFrom: DateTime.parse('2024-01-01T00:00:00Z'),
        validUntil: DateTime.parse('2024-12-31T23:59:59Z'),
        isValid: true,
      );

      final response1 = PaginatedFeedResponse(
        count: 1,
        next: null,
        previous: null,
        results: [flyer],
      );

      final response2 = PaginatedFeedResponse(
        count: 1,
        next: null,
        previous: null,
        results: [flyer],
      );

      final response3 = PaginatedFeedResponse(
        count: 2,
        next: null,
        previous: null,
        results: [flyer],
      );

      expect(response1, equals(response2));
      expect(response1 == response3, false);
    }, tags: ['tdd_green']);
  });
}
