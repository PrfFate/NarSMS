import '../../domain/entities/device_type_entity.dart';

class DeviceTypeModel extends DeviceTypeEntity {
  DeviceTypeModel({required super.id, required super.name});

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) {
    return DeviceTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
