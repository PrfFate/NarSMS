class MovementLogItem {
  final String deviceSerialNumber;
  final String deviceTypeName;
  final String movementType;
  final DateTime movementDate;
  final DateTime createdDate;
  final String? customerName;
  final String username;

  const MovementLogItem({
    required this.deviceSerialNumber,
    required this.deviceTypeName,
    required this.movementType,
    required this.movementDate,
    required this.createdDate,
    required this.customerName,
    required this.username,
  });

  factory MovementLogItem.fromJson(Map<String, dynamic> json) {
    final movementDateRaw = json['movementDate'] as String?;
    final createdDateRaw = json['createdDate'] as String?;

    return MovementLogItem(
      deviceSerialNumber: (json['deviceSerialNumber'] as String?) ?? '-',
      deviceTypeName: (json['deviceTypeName'] as String?) ??
          (json['deviceModel'] as String?) ??
          '-',
      movementType: (json['movementType'] as String?) ?? 'Unknown',
      movementDate: DateTime.tryParse(movementDateRaw ?? '') ?? DateTime.now(),
      createdDate: DateTime.tryParse(createdDateRaw ?? '') ?? DateTime.now(),
      customerName: json['customerName'] as String?,
      username: (json['username'] as String?) ?? '-',
    );
  }
}
