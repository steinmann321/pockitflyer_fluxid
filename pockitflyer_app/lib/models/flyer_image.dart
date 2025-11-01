import 'package:json_annotation/json_annotation.dart';

part 'flyer_image.g.dart';

@JsonSerializable()
class FlyerImage {
  FlyerImage({
    required this.url,
    required this.order,
  });

  factory FlyerImage.fromJson(Map<String, dynamic> json) =>
      _$FlyerImageFromJson(json);

  final String url;
  final int order;

  Map<String, dynamic> toJson() => _$FlyerImageToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlyerImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          order == other.order;

  @override
  int get hashCode => Object.hash(url, order);
}
