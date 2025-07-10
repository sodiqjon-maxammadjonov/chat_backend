import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String? profileImage;
  final String? displayName;
  final String? bio;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
    this.displayName,
    this.bio,
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
      'display_name': displayName,
      'bio': bio,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profile_image'],
      displayName: json['display_name'],
      bio: json['bio'],
      isOnline: json['is_online'] ?? false,
      lastSeen: DateTime.parse(json['last_seen']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String toJsonString() => json.encode(toJson());
}

class UserRegistration {
  final String username;
  final String email;
  final String password;
  final String? displayName;

  UserRegistration({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
  });

  factory UserRegistration.fromJson(Map<String, dynamic> json) {
    return UserRegistration(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      displayName: json['display_name'],
    );
  }
}

class UserLogin {
  final String usernameOrEmail;
  final String password;

  UserLogin({
    required this.usernameOrEmail,
    required this.password,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      usernameOrEmail: json['username_or_email'],
      password: json['password'],
    );
  }
}