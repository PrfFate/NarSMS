import 'package:dartz/dartz.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/customers/domain/entities/paginated_result.dart';
import '../datasources/sale_remote_datasource.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/entities/warranty_entity.dart';
import '../../domain/entities/carrier_entity.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_model.dart';
import '../models/shipment_create_request.dart';
import '../models/sale_create_request.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// [SaleRepository] implementasyonu.
///
/// [BaseRepository.runNetworkCall] ile ağ kontrolü ve
/// exception→failure dönüşümü merkezi olarak yönetilir.
class SaleRepositoryImpl extends BaseRepository implements SaleRepository {
  final SaleRemoteDataSource remoteDataSource;

  SaleRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedResult<SaleEntity>>> getSalesByStatus({
    required String status,
    required int page,
    required int pageSize,
  }) {
    return runNetworkCall(() async {
      final data = await remoteDataSource.getSalesByStatus(
        status: status,
        page: page,
        pageSize: pageSize,
      );
      return _parsePaginatedResponse(data);
    });
  }

  @override
  Future<Either<Failure, void>> createSale(SaleCreateRequest request) {
    return runNetworkCall(() => remoteDataSource.createSale(request));
  }

  @override
  Future<Either<Failure, List<ShipmentEntity>>> getShipmentBySaleId(
      int saleId) {
    return runNetworkCall(() async {
      final models = await remoteDataSource.getShipmentBySaleId(saleId);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, void>> createShipment(ShipmentCreateRequest request) {
    return runNetworkCall(() => remoteDataSource.createShipment(request));
  }

  @override
  Future<Either<Failure, List<CarrierEntity>>> getCarriers() {
    return runNetworkCall(() async {
      final models = await remoteDataSource.getCarriers();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, void>> createCarrier(String name) {
    return runNetworkCall(() => remoteDataSource.createCarrier(name));
  }

  @override
  Future<Either<Failure, void>> updateCarrier(int id, String name) {
    return runNetworkCall(() => remoteDataSource.updateCarrier(id, name));
  }

  @override
  Future<Either<Failure, void>> deleteCarrier(int id) {
    return runNetworkCall(() => remoteDataSource.deleteCarrier(id));
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getFielders() {
    return runNetworkCall(() async {
      final models = await remoteDataSource.getFielders();
      return models.map((m) => m as UserEntity).toList();
    });
  }

  @override
  Future<Either<Failure, WarrantyEntity?>> getDeviceActiveWarranty(
      int deviceId) {
    return runNetworkCall(() async {
      final model = await remoteDataSource.getDeviceActiveWarranty(deviceId);
      return model?.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> markShipmentDelivered(int shipmentId) {
    return runNetworkCall(
        () => remoteDataSource.markShipmentDelivered(shipmentId));
  }

  @override
  Future<Either<Failure, void>> approveSale(int id, String? note) {
    return runNetworkCall(() => remoteDataSource.approveSale(id, note));
  }

  @override
  Future<Either<Failure, void>> rejectSale(int id, String? note) {
    return runNetworkCall(() => remoteDataSource.rejectSale(id, note));
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  PaginatedResult<SaleEntity> _parsePaginatedResponse(
      Map<String, dynamic> data) {
    // Backend bazen Result<T> objesi döndürdüğü için veriler 'value' içinde olabilir.
    final Map<String, dynamic> payload =
        data.containsKey('value') && data['value'] != null
            ? data['value'] as Map<String, dynamic>
            : data;

    final items = (payload['items'] as List<dynamic>? ?? [])
        .map((e) => SaleModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    final totalCount = payload['totalCount'] as int? ?? 0;
    final page = payload['page'] as int? ?? 1;
    final pageSize = payload['pageSize'] as int? ?? 20;
    final totalPages = payload['totalPages'] as int? ??
        (pageSize > 0 ? (totalCount / pageSize).ceil() : 1);

    return PaginatedResult<SaleEntity>(
      items: items,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages,
    );
  }
}
