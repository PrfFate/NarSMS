import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class CreateDeviceTypeUseCase {
  final DeviceRepository repository;

  CreateDeviceTypeUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) {
    return repository.createDeviceTypeEntity(name);
  }
}
