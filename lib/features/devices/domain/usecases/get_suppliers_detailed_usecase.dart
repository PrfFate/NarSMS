import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';
import '../entities/supplier_entity.dart';

class GetSuppliersDetailedUseCase {
  final DeviceRepository repository;

  GetSuppliersDetailedUseCase(this.repository);

  Future<Either<Failure, List<SupplierEntity>>> call() {
    return repository.getSuppliersData();
  }
}
