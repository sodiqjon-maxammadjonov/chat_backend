class UsersModel {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final DateTime createdAt;

  UsersModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.createdAt,
  });

  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      id: map['id'],
      username: map['username'],
      displayName: map['display_name'],
      email: map['email'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}