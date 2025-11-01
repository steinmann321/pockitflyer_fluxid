// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Creator _$CreatorFromJson(Map<String, dynamic> json) => Creator(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  profilePictureUrl: json['profile_picture_url'] as String?,
);

Map<String, dynamic> _$CreatorToJson(Creator instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'profile_picture_url': instance.profilePictureUrl,
};
