import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
/// Events represent user actions or external triggers.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user attempts to login.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];

  @override
  String toString() => 'LoginRequested(email: $email)';
}

/// Event triggered when user attempts to register.
class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String phone;
  final String password;
  final int roleId;

  const RegisterRequested({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.roleId,
  });

  @override
  List<Object?> get props => [username, email, phone, password, roleId];

  @override
  String toString() => 'RegisterRequested(email: $email)';
}

/// Event triggered when user logs out.
class LogoutRequested extends AuthEvent {
  @override
  String toString() => 'LogoutRequested()';
}

/// Event triggered when checking if user is already logged in.
class CheckAuthStatus extends AuthEvent {
  @override
  String toString() => 'CheckAuthStatus()';
}

/// Event triggered when requesting password reset.
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];

  @override
  String toString() => 'ForgotPasswordRequested(email: $email)';
}
