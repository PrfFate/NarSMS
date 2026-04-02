import 'package:equatable/equatable.dart';

class ServiceRequestEntity extends Equatable {
  final int? id;
  final String? deviceSerialNumber;
  final String? deviceTypeName;
  final int? customerId;
  final String? customerName;
  final DateTime? requestDate;
  final String? status;
  final String? faultDescription;
  final int? supplierId;
  final String? supplierName;
  final int? shipmentId;
  final String? shipmentStatus;
  final List<dynamic>? serviceOperations;

  const ServiceRequestEntity({
    this.id,
    this.deviceSerialNumber,
    this.deviceTypeName,
    this.customerId,
    this.customerName,
    this.requestDate,
    this.status,
    this.faultDescription,
    this.supplierId,
    this.supplierName,
    this.shipmentId,
    this.shipmentStatus,
    this.serviceOperations,
  });

  @override
  List<Object?> get props => [
        id,
        deviceSerialNumber,
        deviceTypeName,
        customerId,
        customerName,
        requestDate,
        status,
        faultDescription,
        supplierId,
        supplierName,
        shipmentId,
        shipmentStatus,
        serviceOperations,
      ];
}
