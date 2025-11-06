import 'user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final DateTime refreshTokenExpiration;
  final UserModel user;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiration,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiration:
          DateTime.parse(json['refreshTokenExpiration'] as String),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
