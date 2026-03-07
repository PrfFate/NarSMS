import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../entities/paginated_result.dart';
import '../repositories/customer_repository.dart';

/// Use case for fetching a paginated list of customers.
/// Follows Single Responsibility Principle.
class GetCustomersUseCase {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Parameters:
  ///   - [page]: Page number (1-indexed)
  ///   - [pageSize]: Number of items per page
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> call({
    int page = 1,
    int pageSize = 15,
  }) async {
    if (page < 1) {
      return const Left(ValidationFailure('Page number must be at least 1'));
    }
    if (pageSize < 1 || pageSize > 100) {
      return const Left(
          ValidationFailure('Page size must be between 1 and 100'));
    }

    return await repository.getCustomersPaged(
      page: page,
      pageSize: pageSize,
    );
  }
}
