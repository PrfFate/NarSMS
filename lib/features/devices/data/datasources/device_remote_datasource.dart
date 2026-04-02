import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/device_movement_model.dart';
import '../models/supplier_model.dart';

import '../../../../core/models/device_filter_model.dart';

abstract class DeviceRemoteDataSource {
  Future<Map<String, dynamic>> searchBackupAssignments({
    bool isReturned = false,
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  });

  Future<void> assignBackupAssignment(int deviceId, Map<String, dynamic> requestData);

  Future<void> returnBackupAssignment(int assignmentId, String? reason);

  Future<Map<String, dynamic>> searchDevices({
    String? serialNumber,
    String? status,
    int page = 1,
    int pageSize = 15,
  });

  Future<Map<String, dynamic>> searchDevicesWithFilters({
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  });

  Future<void> createDevice(Map<String, dynamic> requestData);
  Future<void> bulkCreateDevices(Map<String, dynamic> requestData);
  Future<void> updateDevice(int id, Map<String, dynamic> requestData);
  Future<void> deleteDevice(int id);
  Future<List<String>> getDeviceTypes();
  Future<Map<String, dynamic>> getDeviceTypesPaged({int page = 1, int pageSize = 15});
  Future<void> createDeviceTypeEntity(String name);
  Future<void> updateDeviceTypeEntity(int id, String name);
  Future<void> deleteDeviceTypeEntity(int id);
  Future<List<String>> getSuppliers();
  Future<List<SupplierModel>> getSuppliersData();
  Future<void> createSupplier(Map<String, dynamic> data);
  Future<void> updateSupplier(int id, Map<String, dynamic> data);
  Future<void> deleteSupplier(int id);
  Future<Map<int, String>> getSuppliersMap();
  Future<List<DeviceMovementModel>> getDeviceMovements(int deviceId);
}

class DeviceRemoteDataSourceImpl
    with ApiErrorHandler
    implements DeviceRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  DeviceRemoteDataSourceImpl({
    required this.dioClient,
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
  Future<Map<String, dynamic>> searchDevicesWithFilters({
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final hasFilters = filter != null && !filter.isEmpty;
      final endpoint = hasFilters
          ? ApiConstants.deviceFilterSearch
          : ApiConstants.deviceSearch;

      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (serialNumber != null && serialNumber.isNotEmpty) {
        queryParams['deviceSerialNumber'] = serialNumber;
      }

      if (hasFilters) {
        queryParams.addAll(filter!.toQueryParams());
      }

      final response = await dioClient.get(
        endpoint,
        queryParameters: queryParams,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'Cihaz araması başarısız',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> searchDevices({
    String? serialNumber,
    String? status,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (serialNumber != null && serialNumber.isNotEmpty) {
        queryParams['deviceSerialNumber'] = serialNumber;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await dioClient.get(
        ApiConstants.deviceSearch,
        queryParameters: queryParams,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API seviyesinde başarı kontrolü
        if (data['isSuccess'] == false) {
          throw ServerException(
            message: data['error'] ?? 'Cihaz araması başarısız',
            statusCode: response.statusCode,
          );
        }
        return data;
      }

      throw ServerException(
        message: 'Sunucu hatası: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> searchBackupAssignments({
    bool isReturned = false,
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'isReturned': isReturned,
      };

      if (serialNumber != null && serialNumber.isNotEmpty) {
        queryParams['deviceSerialNumber'] = serialNumber;
      }

      if (filter != null && !filter.isEmpty) {
        queryParams.addAll(filter.toQueryParams());
      }

      final response = await dioClient.get(
        ApiConstants.backupAssignmentSearch,
        queryParameters: queryParams,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'Sunucu hatası: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
      rethrow;
    }
  }

  @override
  Future<void> assignBackupAssignment(int deviceId, Map<String, dynamic> requestData) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.apiVersion}/BackupAssignment/assign/$deviceId',
        data: requestData,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerException(
        message: 'Sunucu hatası: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
      rethrow;
    }
  }

  @override
  Future<void> returnBackupAssignment(int assignmentId, String? reason) async {
    try {
      final String requestBody = reason != null && reason.trim().isNotEmpty 
          ? '"${reason.trim()}"' 
          : '""';

      final token = sharedPreferences.getString(StorageConstants.accessToken);

      final response = await dioClient.post(
        '${ApiConstants.apiVersion}/BackupAssignment/return/$assignmentId',
        data: requestBody,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerException(
        message: 'Sunucu hatası: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
      rethrow;
    }
  }

  @override
  Future<void> createDevice(Map<String, dynamic> requestData) async {
    try {
      final response = await dioClient.post(
        ApiConstants.deviceCreate,
        data: requestData,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerException(
        message: 'Cihaz oluşturulamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> bulkCreateDevices(Map<String, dynamic> requestData) async {
    try {
      final response = await dioClient.post(
        ApiConstants.deviceBulkCreate,
        data: requestData,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerException(
        message: 'Toplu cihaz oluşturulamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateDevice(int id, Map<String, dynamic> requestData) async {
    try {
      final response = await dioClient.patch(
        ApiConstants.deviceUpdate(id),
        data: requestData,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Cihaz güncellenemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteDevice(int id) async {
    try {
      final response = await dioClient.delete(
        ApiConstants.deviceDelete(id),
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Cihaz silinemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<String>> getDeviceTypes() async {
    try {
      // Endpoint: /api/devicetype?pageNumber=1&pageSize=100
      final response = await dioClient.get(
        ApiConstants.deviceTypes,
        queryParameters: {'pageNumber': 1, 'pageSize': 100},
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        return items.map((e) => e['name'] as String).toList();
      }

      throw ServerException(
        message: 'Cihaz modelleri alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDeviceTypesPaged({int page = 1, int pageSize = 15}) async {
    try {
      final response = await dioClient.get(
        ApiConstants.deviceTypes,
        queryParameters: {'pageNumber': page, 'pageSize': pageSize},
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw ServerException(
        message: 'Cihaz modelleri alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> createDeviceTypeEntity(String name) async {
    try {
      final response = await dioClient.post(
        ApiConstants.deviceTypes,
        data: {'name': name},
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerException(
        message: 'Cihaz modeli oluşturulamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateDeviceTypeEntity(int id, String name) async {
    try {
      final response = await dioClient.patch(
        '${ApiConstants.deviceTypes}/$id',
        data: {'name': name},
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Cihaz modeli güncellenemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteDeviceTypeEntity(int id) async {
    try {
      final response = await dioClient.delete(
        '${ApiConstants.deviceTypes}/$id',
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Cihaz modeli silinemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<String>> getSuppliers() async {
    try {
      final response = await dioClient.get(
        ApiConstants.suppliers,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        // Response bir liste (ya da items içeren obje) olabilir, eğer direkt listeyse:
        final data = response.data;
        if (data is List) {
           return data.map((e) => e['name'] as String).toList();
        } else if (data['items'] != null) {
           return (data['items'] as List).map((e) => e['name'] as String).toList();
        }
        return [];
      }

      throw ServerException(
        message: 'Tedarikçiler alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<SupplierModel>> getSuppliersData() async {
    try {
      final response = await dioClient.get(
        ApiConstants.suppliers,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
           return data.map((e) => SupplierModel.fromJson(e)).toList();
        } else if (data['items'] != null) {
           return (data['items'] as List).map((e) => SupplierModel.fromJson(e)).toList();
        }
        return [];
      }

      throw ServerException(
        message: 'Tedarikçiler alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> createSupplier(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.suppliers,
        data: data,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw ServerException(
        message: 'Tedarikçi oluşturulamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateSupplier(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.patch(
        '${ApiConstants.suppliers}/$id',
        data: data,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Tedarikçi güncellenemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    try {
      final response = await dioClient.delete(
        '${ApiConstants.suppliers}/$id',
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Tedarikçi silinemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<Map<int, String>> getSuppliersMap() async {
    try {
      final response = await dioClient.get(
        ApiConstants.suppliers,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Map<int, String> map = {};
        if (data is List) {
           for (var e in data) { map[e['id'] as int] = e['name'] as String; }
           return map;
        } else if (data['items'] != null) {
           for (var e in data['items']) { map[e['id'] as int] = e['name'] as String; }
           return map;
        }
        return {};
      }

      throw ServerException(
        message: 'Tedarikçiler alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<DeviceMovementModel>> getDeviceMovements(int deviceId) async {
    try {
      final response = await dioClient.get(
        ApiConstants.deviceMovements(deviceId),
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => DeviceMovementModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data['items'] != null) {
          return (data['items'] as List)
              .map((e) => DeviceMovementModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      }

      throw ServerException(
        message: 'Cihaz hareketleri alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
