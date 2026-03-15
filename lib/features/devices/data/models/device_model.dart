import '../../domain/entities/device_entity.dart';

class DeviceFeatureModel extends DeviceFeatureEntity {
  const DeviceFeatureModel({
    super.featureName,
    super.featureValue,
  });

  factory DeviceFeatureModel.fromJson(Map<String, dynamic> json) {
    return DeviceFeatureModel(
      featureName: json['featureName'] as String?,
      featureValue: json['featureValue'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'featureName': featureName,
      'featureValue': featureValue,
    };
  }
}

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    super.deviceSerialNumber,
    super.status,
    super.purchaseDate,
    super.deviceTypeName,
    super.supplierName,
    super.supplierId,
    super.purchasePrice,
    super.features,
    super.featuresName,
    super.featuresValue,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int? ?? 0,
      deviceSerialNumber: json['deviceSerialNumber'] as String?,
      status: json['status'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'] as String)
          : null,
      deviceTypeName: json['deviceTypeName'] as String?,
      supplierName: json['supplierName'] as String?,
      supplierId: json['supplierId'] as int?,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => DeviceFeatureModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuresName: (json['featuresName'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      featuresValue: (json['featuresValue'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceSerialNumber': deviceSerialNumber,
      'status': status,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'deviceTypeName': deviceTypeName,
      'supplierName': supplierName,
      'supplierId': supplierId,
      'purchasePrice': purchasePrice,
      'features': features
          ?.map((e) => {
                'featureName': e.featureName,
                'featureValue': e.featureValue,
              })
          .toList(),
      'featuresName': featuresName,
      'featuresValue': featuresValue,
    };
  }
}
