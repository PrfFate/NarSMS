import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/field_task_repository.dart';

class RejectFieldTaskUseCase {
  final FieldTaskRepository repository;

  const RejectFieldTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(int taskId, String reason) {
    return repository.rejectTask(taskId, reason);
  }
}
