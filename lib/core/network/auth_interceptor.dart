import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../network/navigator_key.dart';
import '../../config/routes/app_router.dart';

/// Her HTTP isteğinde devreye giren interceptor.
///
/// 1️⃣ onRequest: Token varsa Authorization header'ına ekler
/// 2️⃣ onError (401):
///    - login/logout/refresh endpoint'iyse → direkt hata fırlat
///    - refreshToken varsa → refresh dene
///      - Başarılıysa → yeni token ile orijinal isteği tekrar at
///      - Network/5xx hatası → exponential backoff ile 2 retry
///      - Diğer hatalar → logout + login'e yönlendir
///    - refreshToken yoksa → logout + login'e yönlendir
class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;
  final Dio dio;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.sharedPreferences,
    required this.dio,
  });

  // ─── 1) Her istekte token header'ı ekle ───────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = sharedPreferences.getString(StorageConstants.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ─── 2) 401 Hata Yönetimi ─────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // login/logout/refresh endpoint'iyse döngüye girme, direkt hata fırlat
      if (_isAuthEndpoint(err.requestOptions.path)) {
        return handler.next(err);
      }

      // Refresh token var mı?
      final refreshToken = sharedPreferences.getString(StorageConstants.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        _performLogout();
        return handler.next(err);
      }

      // Refresh dene
      final refreshed = await _tryRefreshToken(refreshToken);
      if (refreshed) {
        // Yeni token ile orijinal isteği tekrar at
        try {
          final newToken = sharedPreferences.getString(StorageConstants.accessToken);
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (retryError) {
          _performLogout();
          return handler.next(err);
        }
      } else {
        _performLogout();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  // ─── Auth endpoint kontrolü ────────────────────────────────────────────

  /// login, logout, refresh-token endpoint'lerinde 401 gelirse
  /// refresh denemesine gerek yok — direkt hata dönsün.
  bool _isAuthEndpoint(String path) {
    return path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.logout) ||
        path.contains(ApiConstants.refreshToken);
  }

  // ─── Refresh Token ─────────────────────────────────────────────────────

  /// Refresh token ile yeni token almayı dener.
  /// Network/5xx hatalarında exponential backoff ile 2 retry yapar.
  Future<bool> _tryRefreshToken(String refreshToken) async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      // İlk deneme + 2 retry (toplam 3 deneme)
      const maxRetries = 2;
      for (int attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          final response = await dio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
            options: Options(
              // Refresh isteğinde mevcut (expired) token'ı gönderme
              headers: {'Content-Type': 'application/json'},
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['accessToken'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            if (newAccessToken != null && newRefreshToken != null) {
              // Token rotasyonu: her ikisini de güncelle
              await sharedPreferences.setString(
                  StorageConstants.accessToken, newAccessToken);
              await sharedPreferences.setString(
                  StorageConstants.refreshToken, newRefreshToken);
              return true;
            }
          }
          // 4xx (401/403 gibi) → retry'a gerek yok, token geçersiz
          return false;
        } on DioException catch (e) {
          final statusCode = e.response?.statusCode ?? 0;
          // Network hatası veya 5xx → retry
          if (statusCode == 0 || statusCode >= 500) {
            if (attempt < maxRetries) {
              // Exponential backoff: 1s, 2s
              final delay = Duration(seconds: (attempt + 1));
              await Future.delayed(delay);
              continue;
            }
          }
          // 4xx hata veya retry hakkı bitti
          return false;
        }
      }
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────

  /// Token'ları temizle ve login sayfasına yönlendir
  void _performLogout() {
    sharedPreferences.remove(StorageConstants.accessToken);
    sharedPreferences.remove(StorageConstants.refreshToken);
    sharedPreferences.remove(StorageConstants.isLoggedIn);
    sharedPreferences.remove(StorageConstants.userId);
    sharedPreferences.remove(StorageConstants.userEmail);
    sharedPreferences.remove(StorageConstants.userName);
    sharedPreferences.remove(StorageConstants.userRole);

    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    }
  }
}
