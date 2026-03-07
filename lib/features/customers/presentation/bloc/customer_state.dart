import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/paginated_result.dart';

/// Base class for all customer states.
/// States represent the current status of the customer feature.
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action is taken.
class CustomerInitial extends CustomerState {
  @override
  String toString() => 'CustomerInitial()';
}

/// State when a customer operation is in progress.
class CustomerLoading extends CustomerState {
  @override
  String toString() => 'CustomerLoading()';
}

/// State when paginated customer list is successfully loaded.
class CustomerLoaded extends CustomerState {
  final PaginatedResult<CustomerEntity> result;
  final String? searchQuery;

  const CustomerLoaded({
    required this.result,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [result, searchQuery];

  @override
  String toString() =>
      'CustomerLoaded(count: ${result.items.length}, page: ${result.page})';
}

/// State when a single customer's detail is loaded.
class CustomerDetailLoaded extends CustomerState {
  final CustomerEntity customer;

  const CustomerDetailLoaded(this.customer);

  @override
  List<Object?> get props => [customer];

  @override
  String toString() => 'CustomerDetailLoaded(name: ${customer.name})';
}

/// State when a customer CRUD action (create/update/delete) succeeds.
class CustomerActionSuccess extends CustomerState {
  final String message;

  const CustomerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CustomerActionSuccess(message: $message)';
}

/// State when an error occurs during any customer operation.
class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CustomerError(message: $message)';
}
