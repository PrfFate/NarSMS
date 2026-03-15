import '../../domain/entities/shipment_entity.dart';

/// API'den gelen kargo detayını temsil eder.
class ShipmentModel {
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
  final List<ShipmentItemModel> items;

  const ShipmentModel({
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

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as int? ?? 0,
      saleId: json['saleId'] as int? ?? 0,
      serviceRequestId: json['serviceRequestId'] as int?,
      type: json['type'] as int? ?? 0,
      typeText: json['typeText'] as String?,
      status: json['status'] as int? ?? 0,
      statusText: json['statusText'] as String?,
      carrierId: json['carrierId'] as int?,
      carrierName: json['carrierName'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      fieldTeamUserId: json['fieldTeamUserId'] as int?,
      fieldTeamUserName: json['fieldTeamUserName'] as String?,
      shipmentDate: json['shipmentDate'] as String?,
      completedDate: json['completedDate'] as String?,
      notes: json['notes'] as String?,
      createdByUserId: json['createdByUserId'] as int? ?? 0,
      createdByUserName: json['createdByUserName'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ShipmentItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ShipmentEntity toEntity() => ShipmentEntity(
        id: id,
        saleId: saleId,
        serviceRequestId: serviceRequestId,
        type: type,
        typeText: typeText,
        status: status,
        statusText: statusText,
        carrierId: carrierId,
        carrierName: carrierName,
        trackingNumber: trackingNumber,
        fieldTeamUserId: fieldTeamUserId,
        fieldTeamUserName: fieldTeamUserName,
        shipmentDate: shipmentDate,
        completedDate: completedDate,
        notes: notes,
        createdByUserId: createdByUserId,
        createdByUserName: createdByUserName,
        items: items.map((e) => e.toEntity()).toList(),
      );
}

class ShipmentItemModel {
  final int id;
  final int shipmentId;
  final int saleItemId;
  final int deviceId;
  final String? deviceSerialNumber;
  final String? deviceModel;
  final double salePrice;

  const ShipmentItemModel({
    required this.id,
    required this.shipmentId,
    required this.saleItemId,
    required this.deviceId,
    this.deviceSerialNumber,
    this.deviceModel,
    required this.salePrice,
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ShipmentItemModel(
      id: json['id'] as int? ?? 0,
      shipmentId: json['shipmentId'] as int? ?? 0,
      saleItemId: json['saleItemId'] as int? ?? 0,
      deviceId: json['deviceId'] as int? ?? 0,
      deviceSerialNumber: json['deviceSerialNumber'] as String?,
      deviceModel: json['deviceModel'] as String?,
      salePrice: (json['salePrice'] as num? ?? 0.0).toDouble(),
    );
  }

  ShipmentItemEntity toEntity() => ShipmentItemEntity(
        id: id,
        shipmentId: shipmentId,
        saleItemId: saleItemId,
        deviceId: deviceId,
        deviceSerialNumber: deviceSerialNumber,
        deviceModel: deviceModel,
        salePrice: salePrice,
      );
}
