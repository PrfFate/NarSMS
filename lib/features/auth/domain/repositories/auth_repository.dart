import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository interface for authentication operations.
/// This defines the contract that any auth data source must implement.
/// Using Either\<Failure, Success\> pattern for error handling.
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  /// Returns Either a Failure (left) or UserEntity (right).
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registers a new user.
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required int roleId,
  });

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Refreshes the access token using refresh token.
  Future<Either<Failure, String>> refreshToken(String refreshToken);

  /// Sends a password reset email.
  Future<Either<Failure, void>> forgotPassword(String email);
}
