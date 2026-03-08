import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../entities/paginated_result.dart';
import '../repositories/customer_repository.dart';

/// Use case for searching customers with filters.
/// Supports filtering by name, email, phone, address, and uniqueId.
class SearchCustomersUseCase {
  final CustomerRepository repository;

  SearchCustomersUseCase(this.repository);

  /// Executes the use case.
  ///
  /// At least one filter parameter should be provided for meaningful results.
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> call({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  }) async {
    return await repository.searchCustomers(
      name: name,
      email: email,
      phone: phone,
      address: address,
      uniqueId: uniqueId,
      page: page,
      pageSize: pageSize,
    );
  }
}
