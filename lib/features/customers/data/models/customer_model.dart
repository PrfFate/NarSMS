import '../../domain/entities/customer_entity.dart';

/// Data model for Customer that handles JSON serialization/deserialization.
/// Maps between the API response format and the domain entity.
class CustomerModel {
  final int? id;
  final String? uniqueId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    this.id,
    this.uniqueId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [CustomerModel] from a JSON map.
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int?,
      uniqueId: json['uniqueId'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (uniqueId != null) 'uniqueId': uniqueId,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    };
  }

  /// Converts this data model to a domain entity.
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      uniqueId: uniqueId,
      name: name,
      email: email,
      phone: phone,
      address: address,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [CustomerModel] from a domain entity.
  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      uniqueId: entity.uniqueId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
