import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/customers/domain/entities/paginated_result.dart';
import '../entities/sale_entity.dart';
import '../entities/shipment_entity.dart';
import '../entities/warranty_entity.dart';
import '../entities/carrier_entity.dart';
import '../../data/models/shipment_create_request.dart';
import '../../data/models/sale_create_request.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Satış işlemleri için soyut repository sözleşmesi.
abstract class SaleRepository {
  /// Duruma göre filtrelenmiş sayfalı satış listesini getirir.
  ///
  /// [status] : 'Pending' | 'Shipped' | 'PartiallyShipped' | vb.
  Future<Either<Failure, PaginatedResult<SaleEntity>>> getSalesByStatus({
    required String status,
    required int page,
    required int pageSize,
    String? customerName,
  });
  
  Future<Either<Failure, void>> createSale(SaleCreateRequest request);

  /// Belirli bir satışa ait kargo detayını getirir.
  ///
  /// [GET /api/shipment/sale/{saleId}]
  Future<Either<Failure, List<ShipmentEntity>>> getShipmentBySaleId(int saleId);

  Future<Either<Failure, void>> createShipment(ShipmentCreateRequest request);
  Future<Either<Failure, List<CarrierEntity>>> getCarriers();
  Future<Either<Failure, void>> createCarrier(String name);
  Future<Either<Failure, void>> updateCarrier(int id, String name);
  Future<Either<Failure, void>> deleteCarrier(int id);
  Future<Either<Failure, List<UserEntity>>> getFielders();

  /// Cihaz için aktif garanti bilgisini getirir.
  Future<Either<Failure, WarrantyEntity?>> getDeviceActiveWarranty(
      int deviceId);

  /// Kargo teslimatını onaylar.
  Future<Either<Failure, void>> markShipmentDelivered(int shipmentId);

  /// Satışı onaylar.
  Future<Either<Failure, void>> approveSale(int id, String? note);

  /// Satışı reddeder.
  Future<Either<Failure, void>> rejectSale(int id, String? note);

  /// Satılık cihazı iade alır.
  Future<Either<Failure, void>> returnSaleItem({
    required int saleId,
    required int saleItemId,
    required String condition,
    String? conditionNotes,
  });
}
