import 'package:equatable/equatable.dart';

class SaleItemEntity extends Equatable {
  final int id;
  final int saleId;
  final int? deviceId;
  final String? serialNumber;
  final String? modelName;
  final double price;
  final String? imageUrl;

  const SaleItemEntity({
    required this.id,
    required this.saleId,
    this.deviceId,
    this.serialNumber,
    this.modelName,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        deviceId,
        serialNumber,
        modelName,
        price,
        imageUrl,
      ];
}
