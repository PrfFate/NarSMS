import 'package:dio/dio.dart';

/// Narpos `Result<T>` sarmalayıcı yanıtlarını parse eder.
class ApiResponseUtils {
  const ApiResponseUtils._();

  static Map<String, dynamic>? asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  /// `value` alanı varsa iç payload'ı döner.
  static Map<String, dynamic> unwrapPayload(Map<String, dynamic> data) {
    final value = data['value'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return data;
  }

  static bool isSuccessResponse(Response response) {
    final code = response.statusCode ?? 0;
    if (code != 200 && code != 201 && code != 204) return false;

    final map = asMap(response.data);
    if (map == null) return true;

    final isFailure = map['isFailure'] ?? map['IsFailure'];
    if (isFailure == true) return false;

    final isSuccess = map['isSuccess'] ?? map['IsSuccess'];
    if (isSuccess == false) return false;

    return true;
  }

  static String errorMessageFrom(dynamic data, {String fallback = 'İşlem başarısız'}) {
    final map = asMap(data);
    if (map == null) return fallback;

    final error = map['error'] ?? map['Error'];
    if (error != null && error.toString().trim().isNotEmpty) {
      return error.toString();
    }

    final errors = map['errors'] ?? map['Errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }

    return fallback;
  }
}
