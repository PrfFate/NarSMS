import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/approval_workflow_model.dart';

abstract class ApprovalRemoteDataSource {
  Future<List<ApprovalWorkflowModel>> getWorkflows();
  Future<ApprovalWorkflowModel> getWorkflowById(int id);
  Future<void> createWorkflow(Map<String, dynamic> data);
  Future<void> deleteWorkflow(int id);
  Future<void> activateWorkflow(int id);
  Future<void> deactivateWorkflow(int id);
  Future<void> updateWorkflowVersion(int id, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getRoles();
}

class ApprovalRemoteDataSourceImpl
    with ApiErrorHandler
    implements ApprovalRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  ApprovalRemoteDataSourceImpl(this.dioClient, this.sharedPreferences);

  Options get _authOptions {
    final token =
        sharedPreferences.getString(StorageConstants.accessToken) ?? '';
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'accept': '*/*', // Curl komutuna uygun olarak eklendi
    });
  }

  @override
  Future<List<ApprovalWorkflowModel>> getWorkflows() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.approvalWorkflow,
        options: _authOptions,
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['value'] as List;
      return payload
          .map((e) => ApprovalWorkflowModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<ApprovalWorkflowModel> getWorkflowById(int id) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.approvalWorkflowById(id),
        options: _authOptions,
      );
      final data = response.data as Map<String, dynamic>;
      return ApprovalWorkflowModel.fromJson(
          data['value'] as Map<String, dynamic>);
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> createWorkflow(Map<String, dynamic> data) async {
    try {
      await dioClient.dio.post(
        ApiConstants.approvalWorkflow,
        data: data,
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deleteWorkflow(int id) async {
    try {
      await dioClient.dio.delete(
        ApiConstants.approvalWorkflowById(id),
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> activateWorkflow(int id) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.approvalWorkflowActivate(id),
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> deactivateWorkflow(int id) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.approvalWorkflowDeactivate(id),
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateWorkflowVersion(int id, Map<String, dynamic> data) async {
    try {
      await dioClient.dio.post(
        '${ApiConstants.approvalWorkflow}/$id/versions',
        data: data,
        options: _authOptions,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.role,
        options: _authOptions,
      );
      final data = response.data;
      if (data is Map && data['value'] != null) {
        return (data['value'] as List).cast<Map<String, dynamic>>();
      }
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
