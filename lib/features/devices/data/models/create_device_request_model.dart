class CreateDeviceRequestModel {
  final String deviceSerialNumber;
  final String deviceTypeName;
  final String supplierName;
  final String status;
  final DateTime purchaseDate;
  final double purchasePrice;
  final List<Map<String, dynamic>> features;

  CreateDeviceRequestModel({
    required this.deviceSerialNumber,
    required this.deviceTypeName,
    required this.supplierName,
    required this.status,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.features,
  });

  String _formatDate(DateTime date) {
    String iso = date.toUtc().toIso8601String();
    if (iso.contains('.')) {
      List<String> parts = iso.split('.');
      String ms = parts[1].replaceAll('Z', '').padRight(3, '0').substring(0, 3);
      return "${parts[0]}.${ms}Z"; // 3 MS digit + Z
    } else {
      return "${iso.replaceAll('Z', '')}.000Z";
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceSerialNumber': deviceSerialNumber,
      'deviceTypeName': deviceTypeName,
      'supplierName': supplierName,
      'status': status,
      'purchaseDate': _formatDate(purchaseDate),
      'purchasePrice': purchasePrice == purchasePrice.toInt() ? purchasePrice.toInt() : purchasePrice,
      'features': features,
    };
  }
}
