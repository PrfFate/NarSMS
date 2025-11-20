import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase for user registration operation.
/// Follows the Single Responsibility Principle - only handles registration logic.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Executes the register use case.
  ///
  /// Parameters:
  ///   - username: User's username
  ///   - email: User's email address
  ///   - phone: User's phone number
  ///   - password: User's password
  ///   - roleId: User's role ID
  ///
  /// Returns:
  ///   - Either\<Failure, UserEntity\>: Left for error, Right for success
  Future<Either<Failure, UserEntity>> call({
    required String username,
    required String email,
    required String phone,
    required String password,
    required int roleId,
  }) async {
    // Business logic validation
    if (username.isEmpty) {
      return const Left(ValidationFailure('Kullanıcı adı boş olamaz'));
    }

    if (email.isEmpty) {
      return const Left(ValidationFailure('Email boş olamaz'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Şifre boş olamaz'));
    }

    if (password.length < 6) {
      return const Left(ValidationFailure('Şifre en az 6 karakter olmalıdır'));
    }

    return await repository.register(
      username: username,
      email: email,
      phone: phone,
      password: password,
      roleId: roleId,
    );
  }
}
