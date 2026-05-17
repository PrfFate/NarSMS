import 'package:dartz/dartz.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/field_task_entity.dart';
import '../../domain/repositories/field_task_repository.dart';
import '../datasources/field_task_remote_datasource.dart';

class FieldTaskRepositoryImpl extends BaseRepository
    implements FieldTaskRepository {
  final FieldTaskRemoteDataSource remoteDataSource;

  const FieldTaskRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });

  @override
  Future<Either<Failure, FieldTaskPagedResultEntity>> getTasks({
    required String endpoint,
    required String status,
    required int pageNumber,
    required int pageSize,
    String? customerName,
  }) {
    return runNetworkCall(
      () => remoteDataSource.getTasks(
        endpoint: endpoint,
        status: status,
        pageNumber: pageNumber,
        pageSize: pageSize,
        customerName: customerName,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> acceptTask(int taskId) {
    return runNetworkCall(() => remoteDataSource.acceptTask(taskId));
  }

  @override
  Future<Either<Failure, void>> rejectTask(int taskId, String reason) {
    return runNetworkCall(() => remoteDataSource.rejectTask(taskId, reason));
  }

  @override
  Future<Either<Failure, void>> reassignTask(
    int taskId,
    int newAssignedToUserId,
  ) {
    return runNetworkCall(
      () => remoteDataSource.reassignTask(taskId, newAssignedToUserId),
    );
  }
}
