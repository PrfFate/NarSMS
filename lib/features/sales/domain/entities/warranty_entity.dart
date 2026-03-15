import 'package:equatable/equatable.dart';

class WarrantyEntity extends Equatable {
  final int id;
  final int deviceId;
  final String? startDate;
  final String? endDate;
  final int durationMonths;
  final bool isActive;
  final int? remainingDays;

  const WarrantyEntity({
    required this.id,
    required this.deviceId,
    this.startDate,
    this.endDate,
    this.durationMonths = 24,
    this.isActive = false,
    this.remainingDays,
  });

  @override
  List<Object?> get props => [
        id,
        deviceId,
        startDate,
        endDate,
        durationMonths,
        isActive,
        remainingDays,
      ];
}
