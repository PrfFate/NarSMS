import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// UseCase for forgot password operation.
/// Follows the Single Responsibility Principle - only handles password reset request logic.
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  /// Executes the forgot password use case.
  ///
  /// Parameters:
  ///   - email: User's email address
  ///
  /// Returns:
  ///   - Either\<Failure, void\>: Left for error, Right for success
  Future<Either<Failure, void>> call(String email) async {
    // Business logic validation
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email boş olamaz'));
    }

    if (!email.contains('@')) {
      return const Left(ValidationFailure('Geçerli bir email adresi girin'));
    }

    return await repository.forgotPassword(email);
  }
}
