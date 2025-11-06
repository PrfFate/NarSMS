import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';

/// Abstract class defining auth-related remote data source operations.
/// This is the contract for making API calls related to authentication.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> register(RegisterRequestModel request);
  Future<String> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
}

/// Implementation of AuthRemoteDataSource using Dio HTTP client.
/// This class handles all network calls for authentication.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Login failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Handle specific HTTP status codes
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Invalid email or password',
        );
      } else if (e.response?.statusCode == 404) {
        throw ServerException(
          message: 'User not found',
          statusCode: 404,
        );
      } else if (e.response?.statusCode == 422) {
        // Validation error from backend
        throw ValidationException(
          message: 'Validation failed',
          errors: e.response?.data['errors'],
        );
      }

      // Network or server error
      throw ServerException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      // Unexpected error
      throw ServerException(
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException(
          message: 'User already exists',
          statusCode: 409,
        );
      } else if (e.response?.statusCode == 422) {
        throw ValidationException(
          message: 'Validation failed',
          errors: e.response?.data['errors'],
        );
      }

      throw ServerException(
        message: e.message ?? 'Registration failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data['accessToken'] as String;
      } else {
        throw ServerException(
          message: 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Refresh token expired',
        );
      }

      throw ServerException(
        message: e.message ?? 'Token refresh failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await dioClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to send reset email',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to send reset email',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
