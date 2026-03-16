class SaleCreateRequest {
  final int customerId;
  final bool isPastSaled;
  final String? saleDate;
  final List<SaleCreateItemRequest> items;

  SaleCreateRequest({
    required this.customerId,
    this.isPastSaled = false,
    this.saleDate,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'isPastSaled': isPastSaled,
      'saleDate': saleDate,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class SaleCreateItemRequest {
  final int deviceId;
  final double price;

  SaleCreateItemRequest({
    required this.deviceId,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'price': price,
    };
  }
}
