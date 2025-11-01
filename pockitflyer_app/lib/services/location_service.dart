import 'package:clock/clock.dart';
import 'package:geolocator/geolocator.dart';

enum PermissionStatus {
  granted,
  denied,
  notDetermined,
  disabled,
}

class LocationData {
  LocationData({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationService {
  LocationService({GeolocatorPlatform? geolocator})
      : _geolocator = geolocator ?? GeolocatorPlatform.instance;

  final GeolocatorPlatform _geolocator;
  LocationData? _cachedLocation;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  Future<PermissionStatus> requestPermission() async {
    try {
      final permission = await _geolocator.requestPermission();

      return switch (permission) {
        LocationPermission.whileInUse => PermissionStatus.granted,
        LocationPermission.always => PermissionStatus.granted,
        LocationPermission.denied => PermissionStatus.denied,
        LocationPermission.deniedForever => PermissionStatus.denied,
        LocationPermission.unableToDetermine => PermissionStatus.notDetermined,
      };
    } catch (e) {
      return PermissionStatus.notDetermined;
    }
  }

  Future<PermissionStatus> getPermissionStatus() async {
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return PermissionStatus.disabled;
    }

    final permission = await _geolocator.checkPermission();

    return switch (permission) {
      LocationPermission.whileInUse => PermissionStatus.granted,
      LocationPermission.always => PermissionStatus.granted,
      LocationPermission.denied => PermissionStatus.notDetermined,
      LocationPermission.deniedForever => PermissionStatus.denied,
      LocationPermission.unableToDetermine => PermissionStatus.notDetermined,
    };
  }

  Future<LocationData> getLocation() async {
    // Check cache
    if (_cachedLocation != null && _cacheTime != null) {
      final now = clock.now();
      if (now.difference(_cacheTime!) < _cacheDuration) {
        return _cachedLocation!;
      }
    }

    // Check if location services are enabled
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationData(latitude: 0.0, longitude: 0.0);
    }

    // Check permission
    final permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return LocationData(latitude: 0.0, longitude: 0.0);
    }

    // Get current position with best accuracy
    final position = await _geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );

    // Cache the location
    _cachedLocation = LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    _cacheTime = clock.now();

    return _cachedLocation!;
  }
}
