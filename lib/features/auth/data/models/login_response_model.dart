class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String username;
  final String email;
  final String role;
  final String? phone;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.email,
    required this.role,
    this.phone,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
    );
  }
}
