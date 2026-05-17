import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  const ProfileRepositoryImpl({
    required this.dioClient,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, void>> updateProfile(
    UpdateProfileParams params,
  ) async {
    try {
      final options = _authorizedOptions();
      final currentUser = await dioClient.get(
        ApiConstants.userById(params.id),
        options: options,
      );
      final currentUserData = _asMap(currentUser.data);

      await dioClient.patch(
        ApiConstants.userById(params.id),
        data: {
          'id': params.id,
          'username': params.username,
          'email': params.email,
          'phone': params.phone,
          'roleId': (currentUserData['roleId'] as num?)?.toInt() ?? 1,
          'roleName': currentUserData['roleName']?.toString() ?? 'Admin',
        },
        options: options,
      );

      await sharedPreferences.setString(
        StorageConstants.userName,
        params.username,
      );
      await sharedPreferences.setString(
        StorageConstants.userEmail,
        params.email,
      );
      await sharedPreferences.setString(
        StorageConstants.userPhone,
        params.phone,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Profil güncellenemedi')));
    } catch (e) {
      return Left(ServerFailure('Profil güncellenemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword(
    ChangePasswordParams params,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.changePassword,
        data: {
          'oldPassword': params.oldPassword,
          'newPassword': params.newPassword,
          'confirmNewPassword': params.confirmNewPassword,
        },
        options: _authorizedOptions(),
      );

      final data = _asMap(response.data);
      return Right(
        data['message']?.toString() ?? 'Şifre başarıyla değiştirildi.',
      );
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e, 'Şifre değiştirilemedi')));
    } catch (e) {
      return Left(ServerFailure('Şifre değiştirilemedi: $e'));
    }
  }

  Options _authorizedOptions() {
    final token = sharedPreferences.getString(StorageConstants.accessToken);
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }

  String _extractMessage(DioException exception, String fallback) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['title']?.toString() ??
          data['detail']?.toString() ??
          fallback;
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return exception.message ?? fallback;
  }
}
