import 'package:equatable/equatable.dart';

class DeviceFeatureEntity extends Equatable {
  final String? featureName;
  final String? featureValue;

  const DeviceFeatureEntity({
    this.featureName,
    this.featureValue,
  });

  @override
  List<Object?> get props => [featureName, featureValue];
}

class DeviceEntity extends Equatable {
  final int id;
  final String? deviceSerialNumber;
  final String? status;
  final DateTime? purchaseDate;
  final String? deviceTypeName;
  final String? supplierName;
  final int? supplierId;
  final double? purchasePrice;
  final List<DeviceFeatureEntity>? features;
  final List<String>? featuresName;
  final List<String>? featuresValue;
  final int? shipmentId;
  final String? shipmentStatus;
  
  // Backup Assignment özel alanları
  final int? assignmentId;
  final int? customerId;
  final String? customerName;
  final DateTime? assignmentDate;
  final DateTime? returnDate;
  final bool? isReturned;
  final String? notes;
  final String? returnReason;

  const DeviceEntity({
    required this.id,
    this.deviceSerialNumber,
    this.status,
    this.purchaseDate,
    this.deviceTypeName,
    this.supplierName,
    this.supplierId,
    this.purchasePrice,
    this.features,
    this.featuresName,
    this.featuresValue,
    this.shipmentId,
    this.shipmentStatus,
    this.assignmentId,
    this.customerId,
    this.customerName,
    this.assignmentDate,
    this.returnDate,
    this.isReturned,
    this.notes,
    this.returnReason,
  });

  @override
  List<Object?> get props => [
        id,
        deviceSerialNumber,
        status,
        purchaseDate,
        deviceTypeName,
        supplierName,
        supplierId,
        purchasePrice,
        features,
        featuresName,
        featuresValue,
        shipmentId,
        shipmentStatus,
        assignmentId,
        customerId,
        customerName,
        assignmentDate,
        returnDate,
        isReturned,
        notes,
        returnReason,
      ];
}
