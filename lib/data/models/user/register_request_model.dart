class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String displayName;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.displayName,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      displayName: json['displayName'] ?? json['username'],
    );
  }
}