import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pockitflyer_app/services/location_service.dart';

class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

void main() {
  group('LocationService Permission Tests', () {
    late LocationService locationService;
    late MockGeolocatorPlatform mockGeolocator;

    setUp(() {
      mockGeolocator = MockGeolocatorPlatform();
      locationService = LocationService(geolocator: mockGeolocator);
    });

    test('requestPermission returns granted when user grants permission',
        () async {
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      final result = await locationService.requestPermission();

      expect(result, PermissionStatus.granted);
      verify(() => mockGeolocator.requestPermission()).called(1);
    }, tags: ['tdd_green']);

    test('requestPermission returns denied when user denies permission',
        () async {
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final result = await locationService.requestPermission();

      expect(result, PermissionStatus.denied);
      verify(() => mockGeolocator.requestPermission()).called(1);
    }, tags: ['tdd_green']);

    test(
        'requestPermission returns denied when user denies permission forever',
        () async {
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      final result = await locationService.requestPermission();

      expect(result, PermissionStatus.denied);
      verify(() => mockGeolocator.requestPermission()).called(1);
    }, tags: ['tdd_green']);

    test('requestPermission returns granted when always permission granted',
        () async {
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.always);

      final result = await locationService.requestPermission();

      expect(result, PermissionStatus.granted);
      verify(() => mockGeolocator.requestPermission()).called(1);
    }, tags: ['tdd_green']);

    test(
        'requestPermission returns notDetermined when unable to determine permission',
        () async {
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.unableToDetermine);

      final result = await locationService.requestPermission();

      expect(result, PermissionStatus.notDetermined);
      verify(() => mockGeolocator.requestPermission()).called(1);
    }, tags: ['tdd_green']);

    test('requestPermission returns notDetermined on error', () async {
      when(() => mockGeolocator.requestPermission())
          .thenThrow(Exception('Location service error'));

      final result = await locationService.requestPermission();

      expect(result, PermissionStatus.notDetermined);
      verify(() => mockGeolocator.requestPermission()).called(1);
    }, tags: ['tdd_green']);

    test('getPermissionStatus returns notDetermined initially', () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final result = await locationService.getPermissionStatus();

      expect(result, PermissionStatus.notDetermined);
      verify(() => mockGeolocator.checkPermission()).called(1);
    }, tags: ['tdd_green']);

    test('getPermissionStatus returns granted when permission is granted',
        () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      final result = await locationService.getPermissionStatus();

      expect(result, PermissionStatus.granted);
      verify(() => mockGeolocator.checkPermission()).called(1);
    }, tags: ['tdd_green']);

    test('getPermissionStatus returns granted for always permission', () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);

      final result = await locationService.getPermissionStatus();

      expect(result, PermissionStatus.granted);
      verify(() => mockGeolocator.checkPermission()).called(1);
    }, tags: ['tdd_green']);

    test('getPermissionStatus returns disabled when location services are off',
        () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final result = await locationService.getPermissionStatus();

      expect(result, PermissionStatus.disabled);
      verify(() => mockGeolocator.isLocationServiceEnabled()).called(1);
    }, tags: ['tdd_green']);
  });

  group('LocationService Location Retrieval Tests', () {
    late LocationService locationService;
    late MockGeolocatorPlatform mockGeolocator;

    setUp(() {
      mockGeolocator = MockGeolocatorPlatform();
      locationService = LocationService(geolocator: mockGeolocator);
    });

    test('getLocation returns position when permission is granted', () async {
      final expectedPosition = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(
        () => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => expectedPosition);

      final result = await locationService.getLocation();

      expect(result.latitude, 37.7749);
      expect(result.longitude, -122.4194);
      verify(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'))).called(1);
    }, tags: ['tdd_green']);

    test('getLocation returns default location when permission is denied',
        () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final result = await locationService.getLocation();

      expect(result.latitude, 0.0);
      expect(result.longitude, 0.0);
      verifyNever(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings')));
    }, tags: ['tdd_green']);

    test('getLocation returns default location when location services disabled',
        () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final result = await locationService.getLocation();

      expect(result.latitude, 0.0);
      expect(result.longitude, 0.0);
      verifyNever(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings')));
    }, tags: ['tdd_green']);

    test('getLocation uses best accuracy for navigation', () async {
      final expectedPosition = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(
        () => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => expectedPosition);

      await locationService.getLocation();

      final captured = verify(() => mockGeolocator.getCurrentPosition(
          locationSettings: captureAny(named: 'locationSettings'))).captured;
      final settings = captured.first as LocationSettings;
      expect(settings.accuracy, LocationAccuracy.best);
    }, tags: ['tdd_green']);
  });

  group('LocationService Caching Tests', () {
    late LocationService locationService;
    late MockGeolocatorPlatform mockGeolocator;

    setUp(() {
      mockGeolocator = MockGeolocatorPlatform();
      locationService = LocationService(geolocator: mockGeolocator);

      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
    });

    test('getLocation caches location for 5 minutes', () async {
      final position1 = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(
        () => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => position1);

      // First call should fetch location
      final result1 = await locationService.getLocation();
      expect(result1.latitude, 37.7749);

      // Second call within 5 minutes should return cached location
      final result2 = await locationService.getLocation();
      expect(result2.latitude, 37.7749);

      // Should only call getCurrentPosition once
      verify(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'))).called(1);
    }, tags: ['tdd_green']);

    test('getLocation fetches fresh location after cache expires', () async {
      final position1 = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final position2 = Position(
        latitude: 40.7128,
        longitude: -74.006,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(
        () => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => position1);

      await withClock(Clock.fixed(DateTime(2024, 1, 1, 12, 0)), () async {
        final result1 = await locationService.getLocation();
        expect(result1.latitude, 37.7749);
      });

      // Update mock to return new position
      when(
        () => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => position2);

      // 6 minutes later - cache should be expired
      await withClock(Clock.fixed(DateTime(2024, 1, 1, 12, 6)), () async {
        final result2 = await locationService.getLocation();
        expect(result2.latitude, 40.7128);
      });

      // Should call getCurrentPosition twice
      verify(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'))).called(2);
    }, tags: ['tdd_green']);
  });
}
