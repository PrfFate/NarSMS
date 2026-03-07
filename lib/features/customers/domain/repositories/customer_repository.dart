import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../entities/paginated_result.dart';

/// Abstract repository interface for customer operations.
/// Defines the contract that any customer data source must implement.
/// Uses `Either<Failure, Success>` pattern for functional error handling.
abstract class CustomerRepository {
  /// Fetches a paginated list of customers.
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> getCustomersPaged({
    int page = 1,
    int pageSize = 15,
  });

  /// Searches customers with filters and returns a paginated result.
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> searchCustomers({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  });

  /// Gets a single customer by their ID.
  Future<Either<Failure, CustomerEntity>> getCustomerById(int id);

  /// Gets a single customer by their unique identifier.
  Future<Either<Failure, CustomerEntity>> getCustomerByUniqueId(
      String uniqueId);

  /// Gets devices belonging to a specific customer.
  Future<Either<Failure, List<dynamic>>> getCustomerDevices(int id);

  /// Creates a new customer.
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  });

  /// Updates an existing customer.
  Future<Either<Failure, void>> updateCustomer({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  });

  /// Deletes a customer by their ID.
  Future<Either<Failure, void>> deleteCustomer(int id);
}
