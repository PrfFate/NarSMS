import '../../domain/entities/device_movement_entity.dart';

class DeviceMovementModel extends DeviceMovementEntity {
  const DeviceMovementModel({
    super.customerName,
    super.deviceModel,
    super.deviceSerialNumber,
    super.fromLocation,
    super.movementDate,
    super.movementType,
    super.toLocation,
    super.username,
  });

  factory DeviceMovementModel.fromJson(Map<String, dynamic> json) {
    return DeviceMovementModel(
      customerName: json['customerName'] as String?,
      deviceModel: json['deviceModel'] as String?,
      deviceSerialNumber: json['deviceSerialNumber'] as String?,
      fromLocation: json['fromLocation'] as String?,
      movementDate: json['movementDate'] != null
          ? DateTime.tryParse(json['movementDate'] as String)
          : null,
      movementType: json['movementType'] as String?,
      toLocation: json['toLocation'] as String?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'deviceModel': deviceModel,
      'deviceSerialNumber': deviceSerialNumber,
      'fromLocation': fromLocation,
      'movementDate': movementDate?.toIso8601String(),
      'movementType': movementType,
      'toLocation': toLocation,
      'username': username,
    };
  }
}
