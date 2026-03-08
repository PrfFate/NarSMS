/// Request model for creating a new customer.
/// Used as the POST body for /api/Customer endpoint.
class CreateCustomerRequestModel {
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? uniqueId;

  const CreateCustomerRequestModel({
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.uniqueId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (uniqueId != null && uniqueId!.isNotEmpty) 'uniqueId': uniqueId,
    };
  }
}
