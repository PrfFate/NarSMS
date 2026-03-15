import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/carrier_entity.dart';
import '../repositories/sale_repository.dart';

class GetCarriersUseCase {
  final SaleRepository repository;
  GetCarriersUseCase(this.repository);

  Future<Either<Failure, List<CarrierEntity>>> call() {
    return repository.getCarriers();
  }
}

class CreateCarrierUseCase {
  final SaleRepository repository;
  CreateCarrierUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) {
    return repository.createCarrier(name);
  }
}

class UpdateCarrierUseCase {
  final SaleRepository repository;
  UpdateCarrierUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, String name) {
    return repository.updateCarrier(id, name);
  }
}

class DeleteCarrierUseCase {
  final SaleRepository repository;
  DeleteCarrierUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteCarrier(id);
  }
}
