import 'package:dartz/dartz.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task_type_entity.dart';
import '../../domain/repositories/task_type_repository.dart';
import '../datasources/task_type_remote_datasource.dart';
import '../models/task_type_model.dart';

class TaskTypeRepositoryImpl extends BaseRepository implements TaskTypeRepository {
  final TaskTypeRemoteDataSource remoteDataSource;

  TaskTypeRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });

  @override
  Future<Either<Failure, List<TaskTypeEntity>>> getActiveTaskTypes() {
    return runNetworkCall(() async {
      final models = await remoteDataSource.getActiveTaskTypes();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<TaskTypeEntity>>> getAllTaskTypes() {
    return runNetworkCall(() async {
      final models = await remoteDataSource.getAllTaskTypes();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, TaskTypeEntity>> getTaskTypeById(int id) {
    return runNetworkCall(() async {
      final model = await remoteDataSource.getTaskTypeById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, TaskTypeEntity>> createTaskType(TaskTypeEntity taskType) {
    return runNetworkCall(() async {
      final model = await remoteDataSource.createTaskType(TaskTypeModel.fromEntity(taskType));
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> updateTaskType(int id, Map<String, dynamic> data) {
    return runNetworkCall(() => remoteDataSource.updateTaskType(id, data));
  }

  @override
  Future<Either<Failure, void>> deleteTaskType(int id) {
    return runNetworkCall(() => remoteDataSource.deleteTaskType(id));
  }
}
