import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sale_repository.dart';

class MarkShipmentDeliveredUseCase {
  final SaleRepository repository;

  MarkShipmentDeliveredUseCase(this.repository);

  Future<Either<Failure, void>> call(int shipmentId) async {
    return await repository.markShipmentDelivered(shipmentId);
  }
}
