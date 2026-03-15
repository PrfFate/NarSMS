import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/shipment_model.dart';
import '../models/warranty_model.dart';
import '../models/carrier_model.dart';
import '../models/shipment_create_request.dart';
import '../../../auth/data/models/user_model.dart';

abstract class SaleRemoteDataSource {
  Future<Map<String, dynamic>> getSalesByStatus({
    required String status,
    required int page,
    required int pageSize,
  });

  Future<List<ShipmentModel>> getShipmentBySaleId(int saleId);
  Future<void> createShipment(ShipmentCreateRequest request);
  Future<List<CarrierModel>> getCarriers();
  Future<void> createCarrier(String name);
  Future<void> updateCarrier(int id, String name);
  Future<void> deleteCarrier(int id);
  Future<List<UserModel>> getFielders();
  Future<WarrantyModel?> getDeviceActiveWarranty(int deviceId);
  Future<void> markShipmentDelivered(int shipmentId);
  Future<void> approveSale(int id, String? note);
  Future<void> rejectSale(int id, String? note);
}

/// [SaleRemoteDataSource] Dio HTTP istemcisi ile implementasyonu.
///
/// [ApiErrorHandler] mixin'i ile merkezi Dio hata yönetimi sağlanır.
class SaleRemoteDataSourceImpl
    with ApiErrorHandler
    implements SaleRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  SaleRemoteDataSourceImpl(this.dioClient, this.sharedPreferences);

  Options get _authOptions {
    final token =
        sharedPreferences.getString(StorageConstants.accessToken) ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<Map<String, dynamic>> getSalesByStatus({
    required String status,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.saleSearch,
        queryParameters: {
          'status': status,
          'page': page,
          'pageSize': pageSize,
        },
        options: _authOptions,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<ShipmentModel>> getShipmentBySaleId(int saleId) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.shipmentBySaleId(saleId),
        options: _authOptions,
      );

      final dynamic responseData = response.data;
      List<dynamic> listData = [];

      if (responseData is List) {
        listData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        final payload = responseData.containsKey('value')
            ? responseData['value']
            : responseData;
        if (payload is List) {
          listData = payload;
        } else if (payload is Map<String, dynamic>) {
          return [ShipmentModel.fromJson(payload)];
        }
      }

      return listData
          .map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> createShipment(ShipmentCreateRequest request) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.shipmentCreate,
        data: request.toJson(),
        options: _authOptions,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Kargo oluşturulamadı',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<CarrierModel>> getCarriers() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.carrierAll,
        options: _authOptions,
      );

      final dynamic responseData = response.data;
      List<dynamic> listData = [];

      if (responseData is List) {
        listData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('value') &&
            responseData['value'] is List) {
          listData = responseData['value'] as List<dynamic>;
        } else {
          // Eğer tek bir nesne ise veya farklı bir yapıysa
          return [];
        }
      }

      return listData
          .map((e) => CarrierModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> createCarrier(String name) async {
    try {
      await dioClient.dio.post(
        ApiConstants.carrierCreate,
        data: {'name': name},
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateCarrier(int id, String name) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.carrierUpdate(id),
        data: {'name': name},
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteCarrier(int id) async {
    try {
      await dioClient.dio.delete(
        ApiConstants.carrierDelete(id),
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<UserModel>> getFielders() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.userByRoleFielder,
        options: _authOptions,
      );

      final dynamic responseData = response.data;
      List<dynamic> listData = [];

      if (responseData is List) {
        listData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('value') &&
            responseData['value'] is List) {
          listData = responseData['value'] as List<dynamic>;
        } else {
          return [];
        }
      }

      return listData
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<WarrantyModel?> getDeviceActiveWarranty(int deviceId) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.deviceActiveWarranty(deviceId),
        options: _authOptions,
      );

      final data = response.data as Map<String, dynamic>;
      final payload = data.containsKey('value') && data['value'] != null
          ? data['value']
          : data;

      if (payload == null || (payload is List && payload.isEmpty)) {
        return null;
      }

      return WarrantyModel.fromJson(payload as Map<String, dynamic>);
    } on DioException catch (e) {
      // 404 ise null dön (garanti yok veya aktif değil)
      if (e.response?.statusCode == 404) {
        return null;
      }
      handleDioException(e);
    }
  }

  @override
  Future<void> markShipmentDelivered(int shipmentId) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.shipmentMarkDelivered(shipmentId),
        options: _authOptions,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Teslimat onaylanamadı',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> approveSale(int id, String? note) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.saleApprove(id),
        data: {
          'isApproved': true,
          'notes': note,
        },
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> rejectSale(int id, String? note) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.saleReject(id),
        data: {
          'isApproved': false,
          'notes': note,
        },
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
