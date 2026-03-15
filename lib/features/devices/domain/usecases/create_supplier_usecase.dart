import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class CreateSupplierUseCase {
  final DeviceRepository repository;

  CreateSupplierUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> data) {
    return repository.createSupplier(data);
  }
}
