import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

/// Implementation of AuthRepository.
/// This class acts as a bridge between the domain layer and data sources.
/// It handles error conversion from Exceptions to Failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    // Check internet connection first
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      // Create request model
      final request = LoginRequestModel(email: email, password: password);

      // Make API call
      final response = await remoteDataSource.login(request);

      // Save tokens to local storage
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Save user info directly from response
      await sharedPreferences.setString(StorageConstants.userEmail, response.email);
      await sharedPreferences.setString(StorageConstants.userName, response.username);
      await sharedPreferences.setString(StorageConstants.userRole, response.role);
      if (response.phone != null) {
        await sharedPreferences.setString(StorageConstants.userPhone, response.phone!);
      }
      await sharedPreferences.setBool(StorageConstants.isLoggedIn, true);

      // Create and return user entity
      final user = UserEntity(
        email: response.email,
        username: response.username,
        phone: response.phone,
        roleName: response.role,
      );

      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required int roleId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = RegisterRequestModel(
        username: username,
        email: email,
        phone: phone,
        password: password,
        roleId: roleId,
      );

      final response = await remoteDataSource.register(request);

      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Save user info directly from response
      await sharedPreferences.setString(StorageConstants.userEmail, response.email);
      await sharedPreferences.setString(StorageConstants.userName, response.username);
      await sharedPreferences.setString(StorageConstants.userRole, response.role);
      if (response.phone != null) {
        await sharedPreferences.setString(StorageConstants.userPhone, response.phone!);
      }

      // Create and return user entity
      final user = UserEntity(
        email: response.email,
        username: response.username,
        phone: response.phone,
        roleName: response.role,
      );

      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear all stored data
      await sharedPreferences.remove(StorageConstants.accessToken);
      await sharedPreferences.remove(StorageConstants.refreshToken);
      await sharedPreferences.remove(StorageConstants.userId);
      await sharedPreferences.remove(StorageConstants.userEmail);
      await sharedPreferences.remove(StorageConstants.userName);
      await sharedPreferences.remove(StorageConstants.userRole);
      await sharedPreferences.setBool(StorageConstants.isLoggedIn, false);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final newAccessToken = await remoteDataSource.refreshToken(refreshToken);

      await sharedPreferences.setString(
        StorageConstants.accessToken,
        newAccessToken,
      );

      return Right(newAccessToken);
    } on UnauthorizedException catch (e) {
      // Refresh token expired, logout user
      await logout();
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Private helper method to save tokens to local storage
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await sharedPreferences.setString(
      StorageConstants.accessToken,
      accessToken,
    );
    await sharedPreferences.setString(
      StorageConstants.refreshToken,
      refreshToken,
    );
    await sharedPreferences.setBool(StorageConstants.isLoggedIn, true);
  }

}
