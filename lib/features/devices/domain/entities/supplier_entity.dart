import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final int deviceCount;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    required this.deviceCount,
  });

  @override
  List<Object?> get props => [id, name, contactPerson, phone, email, address, deviceCount];
}
