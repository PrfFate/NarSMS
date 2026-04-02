import '../../domain/entities/service_request_entity.dart';

class ServiceRequestModel extends ServiceRequestEntity {
  const ServiceRequestModel({
    super.id,
    super.deviceSerialNumber,
    super.deviceTypeName,
    super.customerId,
    super.customerName,
    super.requestDate,
    super.status,
    super.faultDescription,
    super.supplierId,
    super.supplierName,
    super.shipmentId,
    super.shipmentStatus,
    super.serviceOperations,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'],
      deviceSerialNumber: json['deviceSerialNumber'],
      deviceTypeName: json['deviceTypeName'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      requestDate: json['requestDate'] != null ? DateTime.parse(json['requestDate']) : null,
      status: json['status'],
      faultDescription: json['faultDescription'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      shipmentId: json['shipmentId'],
      shipmentStatus: json['shipmentStatus'],
      serviceOperations: json['serviceOperations'],
    );
  }
}
