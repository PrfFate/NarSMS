import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Use case for creating a new customer.
/// Validates required fields before delegating to the repository.
class CreateCustomerUseCase {
  final CustomerRepository repository;

  CreateCustomerUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Parameters:
  ///   - [name]: Required customer name
  ///   - [email]: Optional customer email
  ///   - [phone]: Optional customer phone
  ///   - [address]: Optional customer address
  ///   - [uniqueId]: Optional unique identifier
  Future<Either<Failure, CustomerEntity>> call({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  }) async {
    // Business logic validation
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Müşteri adı boş olamaz'));
    }

    if (email != null && email.isNotEmpty && !_isValidEmail(email)) {
      return const Left(ValidationFailure('Geçersiz e-posta adresi'));
    }

    return await repository.createCustomer(
      name: name.trim(),
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
