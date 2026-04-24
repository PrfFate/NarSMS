import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

/// [AuthRepository] implementasyonu.
///
/// [BaseRepository]'den türetilir; ağ kontrolü ve exception→failure
/// dönüşümü [runNetworkCall] ile merkezi olarak yönetilir.
/// Bu sınıf yalnızca Auth'a özgü iş mantığını (token kaydetme vb.) içerir.
class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
    required super.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) {
    return runNetworkCall(() async {
      final request = LoginRequestModel(email: email, password: password);
      final response = await remoteDataSource.login(request);

      await _persistSession(response.accessToken, response.refreshToken);
      await _persistUserInfo(
        email: response.email,
        username: response.username,
        role: response.role,
        phone: response.phone,
      );

      return UserEntity(
        email: response.email,
        username: response.username,
        phone: response.phone,
        roleName: response.role,
      );
    });
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required int roleId,
  }) {
    return runNetworkCall(() async {
      final request = RegisterRequestModel(
        username: username,
        email: email,
        phone: phone,
        password: password,
        roleId: roleId,
      );

      final response = await remoteDataSource.register(request);

      await _persistSession(response.accessToken, response.refreshToken);
      await _persistUserInfo(
        email: response.email,
        username: response.username,
        role: response.role,
        phone: response.phone,
      );

      return UserEntity(
        email: response.email,
        username: response.username,
        phone: response.phone,
        roleName: response.role,
      );
    });
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await sharedPreferences.remove(StorageConstants.accessToken);
      await sharedPreferences.remove(StorageConstants.refreshToken);
      await sharedPreferences.remove(StorageConstants.userId);
      await sharedPreferences.remove(StorageConstants.userEmail);
      await sharedPreferences.remove(StorageConstants.userName);
      await sharedPreferences.remove(StorageConstants.userRole);
      await sharedPreferences.setBool(StorageConstants.isLoggedIn, false);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Çıkış yapılamadı: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) {
    return runNetworkCall(() async {
      final newAccessToken = await remoteDataSource.refreshToken(refreshToken);

      await sharedPreferences.setString(
        StorageConstants.accessToken,
        newAccessToken,
      );

      return newAccessToken;
    });
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) {
    return runNetworkCall(
      () => remoteDataSource.forgotPassword(email),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final email =
          sharedPreferences.getString(StorageConstants.userEmail) ?? '';
      final username =
          sharedPreferences.getString(StorageConstants.userName) ?? '';
      final role = sharedPreferences.getString(StorageConstants.userRole) ?? '';
      final phone = sharedPreferences.getString(StorageConstants.userPhone);
      final userId = int.tryParse(
        sharedPreferences.getString(StorageConstants.userId) ?? '',
      );

      return Right(
        UserEntity(
          id: userId,
          email: email,
          username: username,
          roleName: role,
          phone: phone,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Kullanıcı bilgisi okunamadı: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(StorageConstants.isLoggedIn) ?? false;
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  /// Access ve refresh token'ı yerel depolamaya kaydeder.
  Future<void> _persistSession(
    String accessToken,
    String refreshToken,
  ) async {
    await sharedPreferences.setString(
        StorageConstants.accessToken, accessToken);
    await sharedPreferences.setString(
        StorageConstants.refreshToken, refreshToken);
    await sharedPreferences.setBool(StorageConstants.isLoggedIn, true);

    final userId = _extractUserIdFromToken(accessToken);
    if (userId != null) {
      await sharedPreferences.setString(StorageConstants.userId, userId);
    }
  }

  /// Kullanıcı bilgilerini yerel depolamaya kaydeder.
  Future<void> _persistUserInfo({
    required String email,
    required String username,
    required String role,
    String? phone,
  }) async {
    await sharedPreferences.setString(StorageConstants.userEmail, email);
    await sharedPreferences.setString(StorageConstants.userName, username);
    await sharedPreferences.setString(StorageConstants.userRole, role);
    if (phone != null) {
      await sharedPreferences.setString(StorageConstants.userPhone, phone);
    }
  }

  String? _extractUserIdFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      final rawId = payload[
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
          payload['nameid'] ??
          payload['sub'] ??
          payload['id'];
      return rawId?.toString();
    } catch (_) {
      return null;
    }
  }
}
