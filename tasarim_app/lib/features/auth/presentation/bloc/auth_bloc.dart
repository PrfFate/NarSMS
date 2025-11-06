import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC (Business Logic Component) for authentication.
///
/// This class manages the authentication state and handles auth-related events.
/// It uses the clean architecture pattern:
/// - Receives events from UI
/// - Calls use cases to perform business logic
/// - Emits states back to UI
///
/// Example usage in widget:
/// ```dart
/// BlocBuilder<AuthBloc, AuthState>(
///   builder: (context, state) {
///     if (state is AuthLoading) {
///       return LoadingIndicator();
///     }
///     if (state is AuthAuthenticated) {
///       return HomePage(user: state.user);
///     }
///     return LoginPage();
///   },
/// )
/// ```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  // Add other use cases as needed
  // final RegisterUseCase registerUseCase;
  // final LogoutUseCase logoutUseCase;
  // final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
  }) : super(AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  /// Handles login request event.
  /// This method:
  /// 1. Emits AuthLoading state
  /// 2. Calls LoginUseCase
  /// 3. Emits either AuthAuthenticated or AuthError based on result
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emit loading state to show progress indicator
    emit(AuthLoading());

    // Call use case to perform login
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    // Handle result using fold (from dartz Either)
    // Left = Failure, Right = Success
    result.fold(
      (failure) {
        // Login failed - emit error state
        emit(AuthError(failure.message));
      },
      (user) {
        // Login successful - emit authenticated state
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// Handles logout request event.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // TODO: Call logout use case when implemented
    // final result = await logoutUseCase();
    //
    // result.fold(
    //   (failure) => emit(AuthError(failure.message)),
    //   (_) => emit(AuthUnauthenticated()),
    // );

    // For now, just emit unauthenticated state
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  /// Checks if user is already authenticated (e.g., on app startup).
  /// This is useful for auto-login feature.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // TODO: Check if user has valid token in local storage
    // If yes, emit AuthAuthenticated
    // If no, emit AuthUnauthenticated

    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  /// Handles forgot password request.
  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // TODO: Call forgot password use case when implemented
    // final result = await forgotPasswordUseCase(event.email);
    //
    // result.fold(
    //   (failure) => emit(AuthError(failure.message)),
    //   (_) => emit(PasswordResetSent(event.email)),
    // );

    await Future.delayed(const Duration(seconds: 1));
    emit(PasswordResetSent(event.email));
  }
}
