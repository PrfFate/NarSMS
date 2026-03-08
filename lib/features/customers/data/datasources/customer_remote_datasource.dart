import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_model.dart';
import '../models/create_customer_request_model.dart';
import '../models/update_customer_request_model.dart';

/// Müşteri işlemlerine ait uzak veri kaynağı sözleşmesi.
abstract class CustomerRemoteDataSource {
  /// Sayfalı müşteri listesi döner.
  Future<Map<String, dynamic>> getCustomersPaged({
    int page = 1,
    int pageSize = 15,
  });

  /// Filtreli müşteri araması yapar.
  Future<Map<String, dynamic>> searchCustomers({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  });

  /// ID ile tek müşteri getirir.
  Future<CustomerModel> getCustomerById(int id);

  /// Benzersiz kimlik ile tek müşteri getirir.
  Future<CustomerModel> getCustomerByUniqueId(String uniqueId);

  /// Müşteriye ait cihazları getirir.
  Future<List<dynamic>> getCustomerDevices(int id);

  /// Yeni müşteri oluşturur.
  Future<CustomerModel> createCustomer(CreateCustomerRequestModel request);

  /// Mevcut müşteriyi günceller. API 204 No Content döner.
  Future<void> updateCustomer(int id, UpdateCustomerRequestModel request);

  /// Müşteriyi siler.
  Future<void> deleteCustomer(int id);
}

/// [CustomerRemoteDataSource] Dio HTTP istemcisi ile implementasyonu.
///
/// [ApiErrorHandler] mixin'i sayesinde her metoddaki tekrarlı
/// [DioException] catch bloğu tek [handleDioException] çağrısına inmiştir.
/// Auth header'ı [_authOptions] helper'ı ile merkezi olarak yönetilir.
class CustomerRemoteDataSourceImpl
    with ApiErrorHandler
    implements CustomerRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  CustomerRemoteDataSourceImpl({
    required this.dioClient,
    required this.sharedPreferences,
  });

  /// Bearer token içeren [Options] nesnesi oluşturur.
  Options _authOptions() {
    final token = sharedPreferences.getString(StorageConstants.accessToken);
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getCustomersPaged({
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final response = await dioClient.get(
        ApiConstants.customerPaged,
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'Müşteri listesi alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> searchCustomers({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (phone != null && phone.isNotEmpty) queryParams['phone'] = phone;
      if (address != null && address.isNotEmpty) {
        queryParams['address'] = address;
      }
      if (uniqueId != null && uniqueId.isNotEmpty) {
        queryParams['uniqueId'] = uniqueId;
      }

      final response = await dioClient.get(
        ApiConstants.customerSearch,
        queryParameters: queryParams,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'Müşteri araması başarısız',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<CustomerModel> getCustomerById(int id) async {
    try {
      final response = await dioClient.get(
        ApiConstants.customerById(id),
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return CustomerModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Müşteri detayı alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<CustomerModel> getCustomerByUniqueId(String uniqueId) async {
    try {
      final response = await dioClient.get(
        ApiConstants.customerByUniqueId(uniqueId),
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return CustomerModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Müşteri benzersiz ID ile alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getCustomerDevices(int id) async {
    try {
      final response = await dioClient.get(
        ApiConstants.customerDevices(id),
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }

      throw ServerException(
        message: 'Müşteri cihazları alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<CustomerModel> createCustomer(
    CreateCustomerRequestModel request,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.customerCreate,
        data: request.toJson(),
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustomerModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Müşteri oluşturulamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateCustomer(
    int id,
    UpdateCustomerRequestModel request,
  ) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.customerUpdate(id),
        data: request.toJson(),
        options: _authOptions(),
      );

      // 200 OK veya 204 No Content → başarılı güncelleme
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Müşteri güncellenemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    try {
      final response = await dioClient.delete(
        ApiConstants.customerDelete(id),
        options: _authOptions(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Müşteri silinemedi',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
