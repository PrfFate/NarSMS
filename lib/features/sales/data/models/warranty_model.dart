import '../../domain/entities/warranty_entity.dart';

class WarrantyModel extends WarrantyEntity {
  const WarrantyModel({
    required super.id,
    required super.deviceId,
    super.startDate,
    super.endDate,
    super.durationMonths,
    super.isActive,
    super.remainingDays,
  });

  factory WarrantyModel.fromJson(Map<String, dynamic> json) {
    return WarrantyModel(
      id: json['id'] as int? ?? 0,
      deviceId: json['deviceId'] as int? ?? 0,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      durationMonths: json['durationMonths'] as int? ?? 24,
      isActive: json['isActive'] as bool? ?? false,
      remainingDays: json['remainingDays'] as int?,
    );
  }

  WarrantyEntity toEntity() => WarrantyEntity(
        id: id,
        deviceId: deviceId,
        startDate: startDate,
        endDate: endDate,
        durationMonths: durationMonths,
        isActive: isActive,
        remainingDays: remainingDays,
      );
}
