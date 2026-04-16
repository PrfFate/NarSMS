import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_type_entity.dart';

abstract class TaskTypeRepository {
  Future<Either<Failure, List<TaskTypeEntity>>> getActiveTaskTypes();
  Future<Either<Failure, List<TaskTypeEntity>>> getAllTaskTypes();
  Future<Either<Failure, TaskTypeEntity>> getTaskTypeById(int id);
  Future<Either<Failure, TaskTypeEntity>> createTaskType(TaskTypeEntity taskType);
  Future<Either<Failure, void>> updateTaskType(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteTaskType(int id);
}
