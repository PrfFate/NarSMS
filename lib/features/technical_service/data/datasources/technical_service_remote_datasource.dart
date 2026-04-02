import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../models/service_request_model.dart';

abstract class TechnicalServiceRemoteDataSource {
  Future<PaginatedResult<ServiceRequestModel>> getServiceRequests({
    required int page,
    required int pageSize,
    required String status,
  });

  Future<void> createServiceRequest(Map<String, dynamic> requestData);
  Future<void> sendToShipment(int id, int shipmentType, {int? carrierId, int? fieldTeamUserId, String? trackingNumber});
  Future<List<Map<String, dynamic>>> getCarriers();
  Future<List<Map<String, dynamic>>> getFielders();
}

class TechnicalServiceRemoteDataSourceImpl implements TechnicalServiceRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  TechnicalServiceRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  Options _authOptions() {
    final token = sharedPreferences.getString(StorageConstants.accessToken);
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<PaginatedResult<ServiceRequestModel>> getServiceRequests({
    required int page,
    required int pageSize,
    required String status,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.serviceRequestPaged,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'status': status,
        },
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> itemsJson = data['items'] ?? [];
        final items = itemsJson.map((json) => ServiceRequestModel.fromJson(json)).toList();
        
        int total = data['totalCount'] ?? 0;
        int pSize = data['pageSize'] ?? pageSize;
        if (pSize <= 0) pSize = pageSize;

        return PaginatedResult<ServiceRequestModel>(
          items: items,
          totalCount: total,
          page: data['page'] ?? page,
          pageSize: pSize,
          totalPages: (total / pSize).ceil(),
        );
      } else {
        throw ServerException(message: 'Servis kayıtları yüklenemedi');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Sunucu bağlantı hatası');
    }
  }

  @override
  Future<void> createServiceRequest(Map<String, dynamic> requestData) async {
    try {
      final response = await dio.post(
        ApiConstants.serviceRequestCreate,
        data: requestData,
        options: _authOptions(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(message: 'Servis kaydı oluşturulamadı');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Sunucu bağlantı hatası');
    }
  }

  @override
  Future<void> sendToShipment(
    int id, 
    int shipmentType, {
    int? carrierId, 
    int? fieldTeamUserId, 
    String? trackingNumber,
  }) async {
    try {
      final data = {
        'serviceRequestId': id,
        'carrierId': carrierId,
        'fieldTeamUserId': fieldTeamUserId,
        'trackingNumber': trackingNumber,
        'shipmentDate': DateTime.now().toUtc().toIso8601String(),
        'type': shipmentType,
      };

      final response = await dio.post(
        ApiConstants.serviceRequestShipment,
        data: data,
        options: _authOptions(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(message: 'Kargo kaydı oluşturulamadı');
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Sunucu bağlantı hatası');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCarriers() async {
    try {
      final response = await dio.get(
        ApiConstants.carrierAll,
        options: _authOptions(),
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data.containsKey('value')) {
        return List<Map<String, dynamic>>.from(response.data['value']);
      }
      return [];
    } catch (e) {
      throw ServerException(message: 'Kargo firmaları yüklenemedi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFielders() async {
    try {
      final response = await dio.get(
        ApiConstants.userByRoleFielder,
        options: _authOptions(),
      );
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data.containsKey('value')) {
        return List<Map<String, dynamic>>.from(response.data['value']);
      }
      return [];
    } catch (e) {
      throw ServerException(message: 'Saha ekipleri yüklenemedi');
    }
  }
}
