import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class BulkCreateDevicesUseCase {
  final DeviceRepository repository;

  BulkCreateDevicesUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> params) {
    return repository.bulkCreateDevices(params);
  }
}
