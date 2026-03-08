import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/customer_repository.dart';

/// Use case for deleting a customer.
/// Validates the customer ID before delegating to the repository.
class DeleteCustomerUseCase {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Parameters:
  ///   - [id]: The ID of the customer to delete
  Future<Either<Failure, void>> call(int id) async {
    if (id <= 0) {
      return const Left(ValidationFailure('Geçersiz müşteri ID'));
    }

    return await repository.deleteCustomer(id);
  }
}
