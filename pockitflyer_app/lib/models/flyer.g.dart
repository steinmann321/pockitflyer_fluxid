// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flyer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flyer _$FlyerFromJson(Map<String, dynamic> json) => Flyer(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  creator: Creator.fromJson(json['creator'] as Map<String, dynamic>),
  images: (json['images'] as List<dynamic>)
      .map((e) => FlyerImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  locationAddress: json['location_address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
  validFrom: DateTime.parse(json['valid_from'] as String),
  validUntil: DateTime.parse(json['valid_until'] as String),
  isValid: json['is_valid'] as bool,
);

Map<String, dynamic> _$FlyerToJson(Flyer instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'creator': instance.creator.toJson(),
  'images': instance.images.map((e) => e.toJson()).toList(),
  'location_address': instance.locationAddress,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'distance_km': instance.distanceKm,
  'valid_from': instance.validFrom.toIso8601String(),
  'valid_until': instance.validUntil.toIso8601String(),
  'is_valid': instance.isValid,
};
