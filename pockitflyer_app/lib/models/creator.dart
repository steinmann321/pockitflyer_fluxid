class Creator {
  Creator({
    required this.id,
    required this.username,
    this.profilePicture,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] as int,
      username: json['username'] as String,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  final int id;
  final String username;
  final String? profilePicture;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture': profilePicture,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Creator &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          profilePicture == other.profilePicture;

  @override
  int get hashCode => Object.hash(id, username, profilePicture);
}
