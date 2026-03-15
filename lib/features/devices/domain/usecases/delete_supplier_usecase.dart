import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class DeleteSupplierUseCase {
  final DeviceRepository repository;

  DeleteSupplierUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteSupplier(id);
  }
}
