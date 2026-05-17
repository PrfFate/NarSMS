import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/field_task_model.dart';
import '../../domain/entities/field_task_entity.dart';

abstract class FieldTaskRemoteDataSource {
  Future<FieldTaskPagedResultEntity> getTasks({
    required String endpoint,
    required String status,
    required int pageNumber,
    required int pageSize,
    String? customerName,
  });

  Future<void> acceptTask(int taskId);

  Future<void> rejectTask(int taskId, String reason);

  Future<void> reassignTask(int taskId, int newAssignedToUserId);
}

class FieldTaskRemoteDataSourceImpl implements FieldTaskRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  const FieldTaskRemoteDataSourceImpl({
    required this.dioClient,
    required this.sharedPreferences,
  });

  Dio get _dio => dioClient.dio;

  Options _authOptions() {
    final token = sharedPreferences.getString(StorageConstants.accessToken);
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<FieldTaskPagedResultEntity> getTasks({
    required String endpoint,
    required String status,
    required int pageNumber,
    required int pageSize,
    String? customerName,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'Status': status,
          'PageNumber': pageNumber,
          'PageSize': pageSize,
          if (customerName != null && customerName.trim().isNotEmpty)
            'CustomerName': customerName.trim(),
        },
        options: _authOptions(),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final items = (data['items'] as List? ?? const [])
          .map(
            (e) => FieldTaskModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return FieldTaskPagedResultEntity(
        items: items,
        totalCount: (data['totalCount'] as num?)?.toInt() ?? items.length,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Sunucu hatası';
      throw ServerException(message: message, statusCode: statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> acceptTask(int taskId) async {
    try {
      await _dio.post(
        ApiConstants.fieldTaskAccept(taskId),
        options: _authOptions(),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Sunucu hatası';
      throw ServerException(message: message, statusCode: statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> rejectTask(int taskId, String reason) async {
    try {
      await _dio.post(
        ApiConstants.fieldTaskReject(taskId),
        data: {'rejectionReason': reason},
        options: _authOptions(),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Sunucu hatası';
      throw ServerException(message: message, statusCode: statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> reassignTask(int taskId, int newAssignedToUserId) async {
    try {
      await _dio.post(
        ApiConstants.fieldTaskReassign(taskId),
        data: {'newAssignedToUserId': newAssignedToUserId},
        options: _authOptions(),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Sunucu hatası';
      throw ServerException(message: message, statusCode: statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
