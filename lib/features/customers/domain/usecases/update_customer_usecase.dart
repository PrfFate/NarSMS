import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/customer_repository.dart';

/// Use case for updating an existing customer.
/// Validates required fields before delegating to the repository.
class UpdateCustomerUseCase {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Parameters:
  ///   - [id]: Required customer ID to update
  ///   - Other fields are optional (PATCH semantics)
  Future<Either<Failure, void>> call({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  }) async {
    if (id <= 0) {
      return const Left(ValidationFailure('Geçersiz müşteri ID'));
    }

    if (name != null && name.trim().isEmpty) {
      return const Left(ValidationFailure('Müşteri adı boş olamaz'));
    }

    if (email != null && email.isNotEmpty && !_isValidEmail(email)) {
      return const Left(ValidationFailure('Geçersiz e-posta adresi'));
    }

    return await repository.updateCustomer(
      id: id,
      name: name?.trim(),
      email: email?.trim(),
      phone: phone?.trim(),
      address: address?.trim(),
      uniqueId: uniqueId?.trim(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
