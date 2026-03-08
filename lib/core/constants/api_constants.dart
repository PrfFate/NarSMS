import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {

  static String get baseUrl => dotenv.get('API_BASE_URL');
  static const String apiVersion = '/api';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh-token';
  static const String logout = '$apiVersion/auth/logout';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';

  // Customer endpoints
  static const String customerPaged = '$apiVersion/Customer/paged';
  static const String customerSearch = '$apiVersion/Customer/search';
  static String customerById(int id) => '$apiVersion/Customer/$id';
  static String customerByUniqueId(String uniqueId) =>
      '$apiVersion/Customer/unique/$uniqueId';
  static String customerDevices(int id) =>
      '$apiVersion/Customer/$id/devices';
  static const String customerCreate = '$apiVersion/Customer';
  static String customerUpdate(int id) => '$apiVersion/Customer/$id';
  static String customerDelete(int id) => '$apiVersion/Customer/$id';
  static const String customerBulk = '$apiVersion/Customer/bulk';
}
