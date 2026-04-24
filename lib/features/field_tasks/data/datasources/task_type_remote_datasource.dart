import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/task_type_model.dart';

abstract class TaskTypeRemoteDataSource {
  Future<List<TaskTypeModel>> getActiveTaskTypes();
  Future<List<TaskTypeModel>> getAllTaskTypes();
  Future<TaskTypeModel> getTaskTypeById(int id);
  Future<TaskTypeModel> createTaskType(TaskTypeModel taskType);
  Future<void> updateTaskType(int id, Map<String, dynamic> data);
  Future<void> deleteTaskType(int id);
}

class TaskTypeRemoteDataSourceImpl with ApiErrorHandler implements TaskTypeRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  TaskTypeRemoteDataSourceImpl({
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

  List<TaskTypeModel> _parseList(dynamic data) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['items'] != null) {
      list = data['items'] as List;
    } else if (data is Map && data['data'] != null) {
      list = data['data'] as List;
    } else {
      list = [];
    }
    return list.map((e) => TaskTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TaskTypeModel>> getActiveTaskTypes() async {
    try {
      final response = await dioClient.get(
        ApiConstants.taskTypes,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return _parseList(response.data);
      }

      throw ServerException(
        message: 'Görev tipleri alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<TaskTypeModel>> getAllTaskTypes() async {
    try {
      final response = await dioClient.get(
        ApiConstants.taskTypesAll,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return _parseList(response.data);
      }

      throw ServerException(
        message: 'Tüm görev tipleri alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<TaskTypeModel> getTaskTypeById(int id) async {
    try {
      final response = await dioClient.get(
        ApiConstants.taskTypeById(id),
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return TaskTypeModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Görev tipi detayı alınamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<TaskTypeModel> createTaskType(TaskTypeModel taskType) async {
    try {
      final response = await dioClient.post(
        ApiConstants.taskTypes,
        data: taskType.toJson(),
        options: _authOptions(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TaskTypeModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: 'Görev tipi oluşturulamadı',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateTaskType(int id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.taskTypeById(id),
        data: data,
        options: _authOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ServerException(
        message: 'Görev tipi güncellenemedi',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteTaskType(int id) async {
    try {
      final response = await dioClient.delete(
        ApiConstants.taskTypeById(id),
        options: _authOptions(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Görev tipi silinemedi',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
