import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class AssignBackupAssignmentUseCase {
  final DeviceRepository repository;

  AssignBackupAssignmentUseCase(this.repository);

  Future<Either<Failure, void>> call(int deviceId, Map<String, dynamic> requestData) async {
    return await repository.assignBackupAssignment(deviceId, requestData);
  }
}
