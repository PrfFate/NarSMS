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
    final Map<String, dynamic> data = {
      'saleId': saleId,
      'shipmentDate': shipmentDate,
      'saleItemIds': saleItemIds,
    };

    if (carrierId != null) data['carrierId'] = carrierId;
    
    if (fieldTeamUserId != null) {
      data['fieldTeamUserId'] = fieldTeamUserId;
    } else if (trackingNumber != null && trackingNumber!.isNotEmpty) {
      data['trackingNumber'] = trackingNumber;
    }

    return data;
  }
}
