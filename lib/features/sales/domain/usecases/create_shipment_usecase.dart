import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/shipment_create_request.dart';
import '../repositories/sale_repository.dart';

class CreateShipmentUseCase {
  final SaleRepository repository;

  CreateShipmentUseCase(this.repository);

  Future<Either<Failure, void>> call(ShipmentCreateRequest request) {
    return repository.createShipment(request);
  }
}
