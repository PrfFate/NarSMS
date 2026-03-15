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

  // Device endpoints
  static const String devicePaged = '$apiVersion/Device/paged';
  static const String deviceSearch = '$apiVersion/Device/search';
  static const String deviceFilterSearch = '$apiVersion/Device/search-by-multiple-features';
  static String deviceById(int id) => '$apiVersion/Device/$id';
  static const String deviceCreate = '$apiVersion/Device';
  static String deviceUpdate(int id) => '$apiVersion/Device/$id';
  static String deviceDelete(int id) => '$apiVersion/Device/$id';
  static const String deviceBulkCreate = '$apiVersion/Device/bulk-create';

  // Device Type and Supplier API Endpoints
  static const String deviceTypes = '$apiVersion/devicetype';
  static const String suppliers = '$apiVersion/Supplier';
  static String deviceMovements(int id) => '$apiVersion/Device/$id/movements';
}
