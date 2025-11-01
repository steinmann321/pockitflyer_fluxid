class Creator {
  Creator({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] as int,
      username: json['username'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  final int id;
  final String username;
  final String? profilePictureUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture_url': profilePictureUrl,
    };
  }

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
