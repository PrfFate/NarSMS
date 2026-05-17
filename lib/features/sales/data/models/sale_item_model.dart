import '../../domain/entities/sale_item_entity.dart';

class SaleItemModel extends SaleItemEntity {
  const SaleItemModel({
    required super.id,
    required super.saleId,
    super.deviceId,
    super.serialNumber,
    super.modelName,
    required super.price,
    super.imageUrl,
    super.isReturned = false,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    final deviceObj = json['device'] as Map<String, dynamic>?;
    return SaleItemModel(
      id: json['id'] as int? ?? json['saleItemId'] as int? ?? 0,
      saleId: json['saleId'] as int? ?? 0,
      deviceId: json['deviceId'] as int?,
      serialNumber: deviceObj?['deviceSerialNumber'] as String?,
      modelName: deviceObj?['deviceTypeName'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: null, // Json'da imaj url yok
      isReturned: json['isReturned'] as bool? ?? false,
    );
  }

  SaleItemEntity toEntity() => SaleItemEntity(
        id: id,
        saleId: saleId,
        deviceId: deviceId,
        serialNumber: serialNumber,
        modelName: modelName,
        price: price,
        imageUrl: imageUrl,
        isReturned: isReturned,
      );
}
