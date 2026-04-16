import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/field_task_repository.dart';

class AcceptFieldTaskUseCase {
  final FieldTaskRepository repository;

  const AcceptFieldTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(int taskId) {
    return repository.acceptTask(taskId);
  }
}
