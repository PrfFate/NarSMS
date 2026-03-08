import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';

/// Auth ile ilgili uzak veri kaynağı sözleşmesi.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> register(RegisterRequestModel request);
  Future<String> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
}

/// [AuthRemoteDataSource] Dio HTTP istemcisi ile implementasyonu.
///
/// [ApiErrorHandler] mixin'i sayesinde her metoddaki tekrarlı
/// [DioException] catch bloğu tek [ handleDioException ] çağrısına inmiştir.
class AuthRemoteDataSourceImpl
    with ApiErrorHandler
    implements AuthRemoteDataSource {
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
      }

      throw ServerException(
        message: 'Giriş başarısız',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(response.data);
      }

      throw ServerException(
        message: 'Kayıt başarısız',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
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
      }

      throw ServerException(
        message: 'Token yenileme başarısız',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
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
          message: 'Şifre sıfırlama e-postası gönderilemedi',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
