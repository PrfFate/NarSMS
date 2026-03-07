import 'package:equatable/equatable.dart';

/// Domain entity representing a customer.
/// This is the core business object used across the domain and presentation layers.
class CustomerEntity extends Equatable {
  final int? id;
  final String? uniqueId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerEntity({
    this.id,
    this.uniqueId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        uniqueId,
        name,
        email,
        phone,
        address,
        createdAt,
        updatedAt,
      ];

  CustomerEntity copyWith({
    int? id,
    String? uniqueId,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
