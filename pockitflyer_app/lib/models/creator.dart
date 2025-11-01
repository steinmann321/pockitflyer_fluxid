import 'package:json_annotation/json_annotation.dart';

part 'creator.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Creator {
  Creator({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory Creator.fromJson(Map<String, dynamic> json) =>
      _$CreatorFromJson(json);

  final int id;
  final String username;
  final String? profilePictureUrl;

  Map<String, dynamic> toJson() => _$CreatorToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Creator &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          profilePictureUrl == other.profilePictureUrl;

  @override
  int get hashCode => Object.hash(id, username, profilePictureUrl);
}
