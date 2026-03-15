import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class UpdateDeviceTypeUseCase {
  final DeviceRepository repository;

  UpdateDeviceTypeUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, String name) {
    return repository.updateDeviceTypeEntity(id, name);
  }
}
