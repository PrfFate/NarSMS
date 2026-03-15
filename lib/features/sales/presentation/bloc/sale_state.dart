import 'package:equatable/equatable.dart';
import '../../../../features/customers/domain/entities/paginated_result.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/entities/carrier_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {
  const SaleInitial();
}

class SaleLoading extends SaleState {
  const SaleLoading();
}

class SalesLoaded extends SaleState {
  final PaginatedResult<SaleEntity> result;

  const SalesLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

class ShipmentLoaded extends SaleState {
  final List<ShipmentEntity> shipments;

  const ShipmentLoaded(this.shipments);

  @override
  List<Object?> get props => [shipments];
}

class ShipmentOptionsLoaded extends SaleState {
  final List<CarrierEntity> carriers;
  final List<UserEntity> fielders;
  final List<int> shippedSaleItemIds;

  const ShipmentOptionsLoaded({
    required this.carriers,
    required this.fielders,
    this.shippedSaleItemIds = const [],
  });

  @override
  List<Object?> get props => [carriers, fielders, shippedSaleItemIds];
}

class ShipmentCreated extends SaleState {
  const ShipmentCreated();
}

class ShipmentDelivered extends SaleState {
  const ShipmentDelivered();
}

class SaleApproved extends SaleState {
  const SaleApproved();
}

class SaleRejected extends SaleState {
  const SaleRejected();
}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}
