class ApiConstants {
  static const String baseUrl = 'http://172.25.128.1:5122';
  static const String apiVersion = '/api';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh-token';
  static const String logout = '$apiVersion/auth/logout';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';

  // Diğer endpoint'ler sonradan eklenecek
}
