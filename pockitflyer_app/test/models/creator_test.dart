import 'package:flutter_test/flutter_test.dart';
import 'package:pockitflyer_app/models/creator.dart';

void main() {
  group('Creator Model Tests', () {
    test('creates Creator with all fields', () {
      final creator = Creator(
        id: 1,
        username: 'testuser',
        profilePictureUrl: 'https://example.com/avatar.jpg',
      );

      expect(creator.id, 1);
      expect(creator.username, 'testuser');
      expect(creator.profilePictureUrl, 'https://example.com/avatar.jpg');
    }, tags: ['tdd_green']);

    test('creates Creator with null profilePictureUrl', () {
      final creator = Creator(
        id: 2,
        username: 'anotheruser',
        profilePictureUrl: null,
      );

      expect(creator.id, 2);
      expect(creator.username, 'anotheruser');
      expect(creator.profilePictureUrl, isNull);
    }, tags: ['tdd_green']);

    test('creates Creator from JSON with all fields', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'profile_picture_url': 'https://example.com/avatar.jpg',
      };
      final creator = Creator.fromJson(json);

      expect(creator.id, 1);
      expect(creator.username, 'testuser');
      expect(creator.profilePictureUrl, 'https://example.com/avatar.jpg');
    }, tags: ['tdd_green']);

    test('creates Creator from JSON with null profilePictureUrl', () {
      final json = {
        'id': 2,
        'username': 'user2',
        'profile_picture_url': null,
      };
      final creator = Creator.fromJson(json);

      expect(creator.id, 2);
      expect(creator.username, 'user2');
      expect(creator.profilePictureUrl, isNull);
    }, tags: ['tdd_green']);

    test('converts Creator to JSON with all fields', () {
      final creator = Creator(
        id: 1,
        username: 'testuser',
        profilePictureUrl: 'https://example.com/avatar.jpg',
      );
      final json = creator.toJson();

      expect(json['id'], 1);
      expect(json['username'], 'testuser');
      expect(json['profile_picture_url'], 'https://example.com/avatar.jpg');
    }, tags: ['tdd_green']);

    test('converts Creator to JSON with null profilePictureUrl', () {
      final creator = Creator(
        id: 2,
        username: 'user2',
        profilePictureUrl: null,
      );
      final json = creator.toJson();

      expect(json['id'], 2);
      expect(json['username'], 'user2');
      expect(json['profile_picture_url'], isNull);
    }, tags: ['tdd_green']);

    test('equality operator returns true for identical creators', () {
      final creator1 = Creator(id: 1, username: 'test', profilePictureUrl: 'pic.jpg');
      final creator2 = Creator(id: 1, username: 'test', profilePictureUrl: 'pic.jpg');

      expect(creator1 == creator2, isTrue);
      expect(creator1.hashCode, creator2.hashCode);
    }, tags: ['tdd_green']);

    test('equality operator returns false for different creators', () {
      final creator1 = Creator(id: 1, username: 'test', profilePictureUrl: null);
      final creator2 = Creator(id: 2, username: 'test', profilePictureUrl: null);

      expect(creator1 == creator2, isFalse);
    }, tags: ['tdd_green']);
  });
}
