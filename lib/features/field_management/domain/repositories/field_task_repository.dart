import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/field_task_entity.dart';

abstract class FieldTaskRepository {
  Future<Either<Failure, FieldTaskPagedResultEntity>> getTasks({
    required String endpoint,
    required String status,
    required int pageNumber,
    required int pageSize,
    String? customerName,
  });

  Future<Either<Failure, void>> acceptTask(int taskId);
}
