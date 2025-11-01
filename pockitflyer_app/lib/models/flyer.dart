import 'creator.dart';
import 'flyer_image.dart';

class Flyer {
  Flyer({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.images,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    required this.validFrom,
    required this.validUntil,
    required this.isValid,
  });

  factory Flyer.fromJson(Map<String, dynamic> json) {
    return Flyer(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      creator: Creator.fromJson(json['creator'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>)
          .map((e) => FlyerImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      locationAddress: json['location_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      isValid: json['is_valid'] as bool,
    );
  }

  final int id;
  final String title;
  final String description;
  final Creator creator;
  final List<FlyerImage> images;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isValid;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creator': creator.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_valid': isValid,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Flyer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          creator == other.creator &&
          images.length == other.images.length &&
          locationAddress == other.locationAddress &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          distanceKm == other.distanceKm &&
          validFrom == other.validFrom &&
          validUntil == other.validUntil &&
          isValid == other.isValid;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        creator,
        Object.hashAll(images),
        locationAddress,
        latitude,
        longitude,
        distanceKm,
        validFrom,
        validUntil,
        isValid,
      );
}
