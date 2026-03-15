import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class DeleteDeviceTypeUseCase {
  final DeviceRepository repository;

  DeleteDeviceTypeUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteDeviceTypeEntity(id);
  }
}
