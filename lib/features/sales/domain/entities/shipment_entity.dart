import 'package:equatable/equatable.dart';

/// Kargo detayı domain entity'si.
///
/// [GET /api/shipment/sale/{id}] endpoint'inden dönen veriyi temsil eder.
class ShipmentEntity extends Equatable {
  final int id;
  final int saleId;
  final int? serviceRequestId;
  final int type;
  final String? typeText;
  final int status;
  final String? statusText;
  final int? carrierId;
  final String? carrierName;
  final String? trackingNumber;
  final int? fieldTeamUserId;
  final String? fieldTeamUserName;
  final String? shipmentDate;
  final String? completedDate;
  final String? notes;
  final int createdByUserId;
  final String? createdByUserName;
  final List<ShipmentItemEntity> items;

  const ShipmentEntity({
    required this.id,
    required this.saleId,
    this.serviceRequestId,
    required this.type,
    this.typeText,
    required this.status,
    this.statusText,
    this.carrierId,
    this.carrierName,
    this.trackingNumber,
    this.fieldTeamUserId,
    this.fieldTeamUserName,
    this.shipmentDate,
    this.completedDate,
    this.notes,
    required this.createdByUserId,
    this.createdByUserName,
    this.items = const [],
  });

  @override
  List<Object?> get props => [id, saleId, trackingNumber, status, statusText];
}

class ShipmentItemEntity extends Equatable {
  final int id;
  final int shipmentId;
  final int saleItemId;
  final int deviceId;
  final String? deviceSerialNumber;
  final String? deviceModel;
  final double salePrice;

  const ShipmentItemEntity({
    required this.id,
    required this.shipmentId,
    required this.saleItemId,
    required this.deviceId,
    this.deviceSerialNumber,
    this.deviceModel,
    required this.salePrice,
  });

  @override
  List<Object?> get props => [id, shipmentId, saleItemId, deviceId];
}
