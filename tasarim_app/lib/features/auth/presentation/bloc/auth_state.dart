import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base class for all authentication states.
/// States represent the current status of the authentication feature.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts.
class AuthInitial extends AuthState {
  @override
  String toString() => 'AuthInitial()';
}

/// State when authentication operation is in progress.
class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading()';
}

/// State when user is successfully authenticated.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthAuthenticated(user: ${user.email})';
}

/// State when user is not authenticated.
class AuthUnauthenticated extends AuthState {
  @override
  String toString() => 'AuthUnauthenticated()';
}

/// State when an authentication error occurs.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthError(message: $message)';
}

/// State when password reset email is sent successfully.
class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];

  @override
  String toString() => 'PasswordResetSent(email: $email)';
}
