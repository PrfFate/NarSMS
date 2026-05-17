import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/field_task_repository.dart';

class ReassignFieldTaskUseCase {
  final FieldTaskRepository repository;

  const ReassignFieldTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(int taskId, int newAssignedToUserId) {
    return repository.reassignTask(taskId, newAssignedToUserId);
  }
}
