import 'package:dartz/dartz.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/approval_remote_datasource.dart';
import '../../domain/entities/approval_workflow_entity.dart';
import '../../domain/repositories/approval_repository.dart';

class ApprovalRepositoryImpl extends BaseRepository
    implements ApprovalRepository {
  final ApprovalRemoteDataSource remoteDataSource;

  ApprovalRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });

  @override
  Future<Either<Failure, List<ApprovalWorkflowEntity>>> getWorkflows() {
    return runNetworkCall(() => remoteDataSource.getWorkflows());
  }

  @override
  Future<Either<Failure, ApprovalWorkflowEntity>> getWorkflowById(int id) {
    return runNetworkCall(() => remoteDataSource.getWorkflowById(id));
  }

  @override
  Future<Either<Failure, void>> createWorkflow(Map<String, dynamic> data) {
    return runNetworkCall(() => remoteDataSource.createWorkflow(data));
  }

  @override
  Future<Either<Failure, void>> deleteWorkflow(int id) {
    return runNetworkCall(() => remoteDataSource.deleteWorkflow(id));
  }

  @override
  Future<Either<Failure, void>> activateWorkflow(int id) {
    return runNetworkCall(() => remoteDataSource.activateWorkflow(id));
  }

  @override
  Future<Either<Failure, void>> deactivateWorkflow(int id) {
    return runNetworkCall(() => remoteDataSource.deactivateWorkflow(id));
  }

  @override
  Future<Either<Failure, void>> updateWorkflowVersion(
      int id, Map<String, dynamic> data) {
    return runNetworkCall(
        () => remoteDataSource.updateWorkflowVersion(id, data));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoles() {
    return runNetworkCall(() => remoteDataSource.getRoles());
  }
}
