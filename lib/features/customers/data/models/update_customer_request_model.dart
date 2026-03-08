/// Request model for updating an existing customer.
/// Used as the PATCH body for /api/Customer/{id} endpoint.
/// Only non-null fields will be included in the JSON payload.
class UpdateCustomerRequestModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? uniqueId;

  const UpdateCustomerRequestModel({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.uniqueId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (uniqueId != null) map['uniqueId'] = uniqueId;
    return map;
  }
}
