import 'create_device_request_model.dart';

class BulkCreateDeviceRequestModel {
  final List<CreateDeviceRequestModel> devices;
  final bool stopOnFirstError;

  BulkCreateDeviceRequestModel({
    required this.devices,
    this.stopOnFirstError = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'devices': devices.map((e) => e.toJson()).toList(),
      'stopOnFirstError': stopOnFirstError,
    };
  }
}
