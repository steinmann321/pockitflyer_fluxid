import 'package:json_annotation/json_annotation.dart';

import 'creator.dart';
import 'flyer_image.dart';

part 'flyer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
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

  factory Flyer.fromJson(Map<String, dynamic> json) => _$FlyerFromJson(json);

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

  Map<String, dynamic> toJson() => _$FlyerToJson(this);

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
