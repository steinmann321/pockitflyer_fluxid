import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/models/creator.dart';
import 'package:pockitflyer_app/models/flyer.dart';
import 'package:pockitflyer_app/models/flyer_image.dart';

void main() {
  group('Flyer Model Tests', () {
    test('creates Flyer with all fields', () {
      final flyer = Flyer(
        id: 1,
        title: 'Test Flyer',
        description: 'Test Description',
        creator: Creator(id: 1, username: 'user', profilePictureUrl: null),
        images: [
          FlyerImage(url: 'image1.jpg', order: 0),
          FlyerImage(url: 'image2.jpg', order: 1),
        ],
        locationAddress: 'Address',
        latitude: 0.0,
        longitude: 0.0,
        distanceKm: 1.0,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      expect(flyer.id, 1);
      expect(flyer.title, 'Test Flyer');
      expect(flyer.description, 'Test Description');
      expect(flyer.creator.username, 'user');
      expect(flyer.images.length, 2);
      expect(flyer.locationAddress, 'Address');
      expect(flyer.isValid, true);
    }, tags: ['tdd_green']);

    test('creates Flyer with empty images list', () {
      final flyer = Flyer(
        id: 2,
        title: 'No Images Flyer',
        description: 'Description',
        creator: Creator(id: 2, username: 'user2', profilePictureUrl: null),
        images: [],
        locationAddress: 'Addr',
        latitude: 0,
        longitude: 0,
        distanceKm: null,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      expect(flyer.images, isEmpty);
    }, tags: ['tdd_green']);

    test('creates Flyer with single image', () {
      final flyer = Flyer(
        id: 3,
        title: 'Single Image Flyer',
        description: 'Description',
        creator: Creator(id: 3, username: 'user3', profilePictureUrl: null),
        images: [FlyerImage(url: 'single.jpg', order: 0)],
        locationAddress: 'Addr',
        latitude: 0,
        longitude: 0,
        distanceKm: 5.0,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      expect(flyer.images.length, 1);
      expect(flyer.images.first.url, 'single.jpg');
    }, tags: ['tdd_green']);

    test('creates Flyer from JSON', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'description': 'Desc',
        'creator': {'id': 1, 'username': 'user', 'profile_picture_url': null},
        'images': [
          {'url': 'img.jpg', 'order': 0}
        ],
        'location_address': 'Addr',
        'latitude': 0.0,
        'longitude': 0.0,
        'distance_km': 1.0,
        'valid_from': '2025-01-01T00:00:00.000',
        'valid_until': '2025-12-31T00:00:00.000',
        'is_valid': true
      };
      final flyer = Flyer.fromJson(json);

      expect(flyer.id, 1);
      expect(flyer.title, 'Test');
      expect(flyer.creator.username, 'user');
      expect(flyer.images.length, 1);
    }, tags: ['tdd_green']);

    test('converts Flyer to JSON', () {
      final flyer = Flyer(
        id: 1,
        title: 'T',
        description: 'D',
        creator: Creator(id: 1, username: 'u', profilePictureUrl: null),
        images: [FlyerImage(url: 'i.jpg', order: 0)],
        locationAddress: 'A',
        latitude: 0,
        longitude: 0,
        distanceKm: null,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );
      final json = flyer.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'T');
      expect(json['creator'] is Map, isTrue);
      expect(json['images'] is List, isTrue);
    }, tags: ['tdd_green']);

    test('equality works correctly', () {
      final f1 = Flyer(
        id: 1,
        title: 'T',
        description: 'D',
        creator: Creator(id: 1, username: 'u', profilePictureUrl: null),
        images: [],
        locationAddress: 'A',
        latitude: 0,
        longitude: 0,
        distanceKm: null,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );
      final f2 = Flyer(
        id: 1,
        title: 'T',
        description: 'D',
        creator: Creator(id: 1, username: 'u', profilePictureUrl: null),
        images: [],
        locationAddress: 'A',
        latitude: 0,
        longitude: 0,
        distanceKm: null,
        validFrom: DateTime(2025, 1, 1),
        validUntil: DateTime(2025, 12, 31),
        isValid: true,
      );

      expect(f1 == f2, isTrue);
      expect(f1.hashCode, f2.hashCode);
    }, tags: ['tdd_green']);
  });
}
