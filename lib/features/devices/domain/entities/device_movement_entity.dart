import 'package:equatable/equatable.dart';

class DeviceMovementEntity extends Equatable {
  final String? customerName;
  final String? deviceModel;
  final String? deviceSerialNumber;
  final String? fromLocation;
  final DateTime? movementDate;
  final String? movementType;
  final String? toLocation;
  final String? username;

  const DeviceMovementEntity({
    this.customerName,
    this.deviceModel,
    this.deviceSerialNumber,
    this.fromLocation,
    this.movementDate,
    this.movementType,
    this.toLocation,
    this.username,
  });

  @override
  List<Object?> get props => [
        customerName,
        deviceModel,
        deviceSerialNumber,
        fromLocation,
        movementDate,
        movementType,
        toLocation,
        username,
      ];
}
