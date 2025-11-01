import 'creator.dart';
import 'flyer_image.dart';
import 'location.dart';
import 'validity.dart';

class Flyer {
  Flyer({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.images,
    required this.location,
    required this.validity,
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
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      validity: Validity.fromJson(json['validity'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String title;
  final String description;
  final Creator creator;
  final List<FlyerImage> images;
  final Location location;
  final Validity validity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creator': creator.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'location': location.toJson(),
      'validity': validity.toJson(),
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
          location == other.location &&
          validity == other.validity;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        creator,
        Object.hashAll(images),
        location,
        validity,
      );
}
