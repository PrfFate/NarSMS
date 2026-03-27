import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class ReturnBackupAssignmentUseCase {
  final DeviceRepository repository;

  ReturnBackupAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int assignmentId,
    String? reason,
  }) async {
    return await repository.returnBackupAssignment(
      assignmentId,
      reason,
    );
  }
}
