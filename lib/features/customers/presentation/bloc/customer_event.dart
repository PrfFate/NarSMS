import 'package:equatable/equatable.dart';

/// Base class for all customer events.
/// Events represent user actions or triggers from the UI.
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load paginated customer list.
class LoadCustomers extends CustomerEvent {
  final int page;
  final int pageSize;

  const LoadCustomers({
    this.page = 1,
    this.pageSize = 15,
  });

  @override
  List<Object?> get props => [page, pageSize];

  @override
  String toString() => 'LoadCustomers(page: $page, pageSize: $pageSize)';
}

/// Event to search customers with filters.
class SearchCustomers extends CustomerEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? uniqueId;
  final int page;
  final int pageSize;

  const SearchCustomers({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.uniqueId,
    this.page = 1,
    this.pageSize = 15,
  });

  @override
  List<Object?> get props =>
      [name, email, phone, address, uniqueId, page, pageSize];

  @override
  String toString() => 'SearchCustomers(name: $name, page: $page)';
}

/// Event to load a single customer's detail.
class LoadCustomerDetail extends CustomerEvent {
  final int customerId;

  const LoadCustomerDetail(this.customerId);

  @override
  List<Object?> get props => [customerId];

  @override
  String toString() => 'LoadCustomerDetail(id: $customerId)';
}

/// Event to create a new customer.
class CreateCustomer extends CustomerEvent {
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? uniqueId;

  const CreateCustomer({
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.uniqueId,
  });

  @override
  List<Object?> get props => [name, email, phone, address, uniqueId];

  @override
  String toString() => 'CreateCustomer(name: $name)';
}

/// Event to update an existing customer.
class UpdateCustomer extends CustomerEvent {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? uniqueId;

  const UpdateCustomer({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.uniqueId,
  });

  @override
  List<Object?> get props => [id, name, email, phone, address, uniqueId];

  @override
  String toString() => 'UpdateCustomer(id: $id)';
}

/// Event to delete a customer.
class DeleteCustomer extends CustomerEvent {
  final int customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];

  @override
  String toString() => 'DeleteCustomer(id: $customerId)';
}
