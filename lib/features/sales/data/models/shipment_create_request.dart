class ShipmentCreateRequest {
  final int saleId;
  final int? carrierId;
  final String? trackingNumber;
  final int? fieldTeamUserId;
  final String shipmentDate;
  final List<int> saleItemIds;

  ShipmentCreateRequest({
    required this.saleId,
    this.carrierId,
    this.trackingNumber,
    this.fieldTeamUserId,
    required this.shipmentDate,
    required this.saleItemIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'saleId': saleId,
      'carrierId': carrierId,
      'trackingNumber': trackingNumber,
      'fieldTeamUserId': fieldTeamUserId,
      'shipmentDate': shipmentDate,
      'saleItemIds': saleItemIds,
    };
  }
}
