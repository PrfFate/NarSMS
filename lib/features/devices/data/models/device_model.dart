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
    super.shipmentId,
    super.shipmentStatus,
    super.assignmentId,
    super.customerId,
    super.customerName,
    super.assignmentDate,
    super.returnDate,
    super.isReturned,
    super.notes,
    super.returnReason,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    // BackupAssignment API'den geliyorsa id alanı assignment id'yi temsil eder.
    final bool isBackupAssignment = json.containsKey('deviceId') && json.containsKey('customerId');
    final int deviceId = isBackupAssignment ? (json['deviceId'] as int? ?? 0) : (json['id'] as int? ?? 0);
    final int? assignmentId = isBackupAssignment ? json['id'] as int? : null;

    return DeviceModel(
      id: deviceId,
      assignmentId: assignmentId,
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
      shipmentId: json['shipmentId'] as int?,
      shipmentStatus: json['shipmentStatus'] as String?,
      customerId: isBackupAssignment ? json['customerId'] as int? : null,
      customerName: json['customerName'] as String?,
      assignmentDate: json['assignmentDate'] != null
          ? DateTime.tryParse(json['assignmentDate'] as String)
          : null,
      returnDate: json['returnDate'] != null
          ? DateTime.tryParse(json['returnDate'] as String)
          : null,
      isReturned: json['isReturned'] as bool?,
      notes: json['notes'] as String?,
      returnReason: json['returnReason'] as String?,
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
      'shipmentId': shipmentId,
      'shipmentStatus': shipmentStatus,
      'assignmentId': assignmentId,
      'customerId': customerId,
      'customerName': customerName,
      'assignmentDate': assignmentDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'isReturned': isReturned,
      'notes': notes,
      'returnReason': returnReason,
    };
  }
}
