// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flyer_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlyerImage _$FlyerImageFromJson(Map<String, dynamic> json) => FlyerImage(
  url: json['url'] as String,
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$FlyerImageToJson(FlyerImage instance) =>
    <String, dynamic>{'url': instance.url, 'order': instance.order};
