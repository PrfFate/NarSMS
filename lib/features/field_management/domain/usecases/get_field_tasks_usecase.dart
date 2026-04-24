import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/field_task_entity.dart';
import '../repositories/field_task_repository.dart';

class GetFieldTasksUseCase {
  final FieldTaskRepository repository;

  const GetFieldTasksUseCase(this.repository);

  Future<Either<Failure, FieldTaskPagedResultEntity>> call({
    required String endpoint,
    required String status,
    required int pageNumber,
    required int pageSize,
    String? customerName,
  }) {
    return repository.getTasks(
      endpoint: endpoint,
      status: status,
      pageNumber: pageNumber,
      pageSize: pageSize,
      customerName: customerName,
    );
  }
}
