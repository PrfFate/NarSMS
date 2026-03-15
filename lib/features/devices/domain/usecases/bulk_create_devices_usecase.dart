import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';
import '../../data/models/bulk_create_device_request_model.dart';

class BulkCreateDevicesUseCase {
  final DeviceRepository repository;

  BulkCreateDevicesUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> params) {
    return repository.bulkCreateDevices(params);
  }
}
