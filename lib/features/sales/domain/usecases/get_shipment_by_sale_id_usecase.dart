import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/shipment_entity.dart';
import '../repositories/sale_repository.dart';

/// Satışa ait kargo detayını getirir.
///
/// [GET /api/shipment/sale/{saleId}]
class GetShipmentBySaleIdUseCase {
  final SaleRepository repository;

  GetShipmentBySaleIdUseCase(this.repository);

  Future<Either<Failure, List<ShipmentEntity>>> call(int saleId) {
    return repository.getShipmentBySaleId(saleId);
  }
}
