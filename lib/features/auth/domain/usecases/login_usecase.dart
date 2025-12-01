import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase for user login operation.
/// Follows the Single Responsibility Principle - only handles login logic.
/// Each UseCase represents one business action.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Executes the login use case.
  ///
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  ///
  /// Returns:
  ///   - Either\<Failure, UserEntity\>: Left for error, Right for success
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // You can add business logic validation here
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    return await repository.login(email: email, password: password);
  }
}
