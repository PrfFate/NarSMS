import '../../domain/entities/carrier_entity.dart';

class CarrierModel extends CarrierEntity {
  const CarrierModel({
    required super.id,
    required super.name,
  });

  factory CarrierModel.fromJson(Map<String, dynamic> json) {
    return CarrierModel(
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

  CarrierEntity toEntity() => CarrierEntity(id: id, name: name);
}
