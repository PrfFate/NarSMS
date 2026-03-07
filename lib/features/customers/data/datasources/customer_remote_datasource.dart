import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_model.dart';
import '../models/create_customer_request_model.dart';
import '../models/update_customer_request_model.dart';

/// Abstract class defining customer-related remote data source operations.
abstract class CustomerRemoteDataSource {
  /// Fetches a paginated list of customers.
  Future<Map<String, dynamic>> getCustomersPaged({
    int page = 1,
    int pageSize = 15,
  });

  /// Searches customers with optional filters.
  Future<Map<String, dynamic>> searchCustomers({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  });

  /// Fetches a single customer by ID.
  Future<CustomerModel> getCustomerById(int id);

  /// Fetches a single customer by unique identifier.
  Future<CustomerModel> getCustomerByUniqueId(String uniqueId);

  /// Fetches devices belonging to a customer.
  Future<List<dynamic>> getCustomerDevices(int id);

  /// Creates a new customer.
  Future<CustomerModel> createCustomer(CreateCustomerRequestModel request);

  /// Updates an existing customer. Returns void (API returns 204 No Content).
  Future<void> updateCustomer(int id, UpdateCustomerRequestModel request);

  /// Deletes a customer.
  Future<void> deleteCustomer(int id);
}

/// Implementation of [CustomerRemoteDataSource] using Dio HTTP client.
/// All requests include Bearer token authentication from SharedPreferences.
class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  CustomerRemoteDataSourceImpl({
    required this.dioClient,
    required this.sharedPreferences,
  });

  /// Builds [Options] with the Authorization header.
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
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'Failed to fetch customers',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
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
        message: 'Failed to search customers',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
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
        message: 'Failed to fetch customer detail',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
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
        message: 'Failed to fetch customer by unique ID',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
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
        message: 'Failed to fetch customer devices',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<CustomerModel> createCustomer(
      CreateCustomerRequestModel request) async {
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
        message: 'Failed to create customer',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
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
        message: 'Failed to update customer',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
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
          message: 'Failed to delete customer',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  /// Centralized Dio exception handler.
  /// Converts [DioException] to application-specific exceptions.
  Never _handleDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      throw UnauthorizedException(message: 'Oturum süresi doldu');
    } else if (e.response?.statusCode == 404) {
      throw ServerException(
        message: 'Kayıt bulunamadı',
        statusCode: 404,
      );
    } else if (e.response?.statusCode == 422) {
      throw ValidationException(
        message: 'Doğrulama hatası',
        errors: e.response?.data['errors'] as Map<String, List<String>>?,
      );
    } else if (e.response?.statusCode == 409) {
      throw ServerException(
        message: 'Bu kayıt zaten mevcut',
        statusCode: 409,
      );
    }

    throw ServerException(
      message: e.message ?? 'Beklenmeyen bir ağ hatası oluştu',
      statusCode: e.response?.statusCode,
    );
  }
}
