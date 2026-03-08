import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Use case for getting a single customer's detail.
/// Supports fetching by either numeric ID or unique string ID.
class GetCustomerDetailUseCase {
  final CustomerRepository repository;

  GetCustomerDetailUseCase(this.repository);

  /// Fetches customer by numeric ID.
  Future<Either<Failure, CustomerEntity>> callById(int id) async {
    if (id <= 0) {
      return const Left(ValidationFailure('Customer ID must be positive'));
    }
    return await repository.getCustomerById(id);
  }

  /// Fetches customer by unique string identifier.
  Future<Either<Failure, CustomerEntity>> callByUniqueId(
      String uniqueId) async {
    if (uniqueId.isEmpty) {
      return const Left(ValidationFailure('Unique ID cannot be empty'));
    }
    return await repository.getCustomerByUniqueId(uniqueId);
  }
}
