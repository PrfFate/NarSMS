import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class UpdateSupplierUseCase {
  final DeviceRepository repository;

  UpdateSupplierUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, Map<String, dynamic> data) {
    return repository.updateSupplier(id, data);
  }
}
