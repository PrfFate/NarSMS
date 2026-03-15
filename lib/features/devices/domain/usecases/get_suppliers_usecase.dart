import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class GetSuppliersUseCase {
  final DeviceRepository repository;

  GetSuppliersUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getSuppliers();
  }
}
