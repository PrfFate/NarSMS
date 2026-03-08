import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC (Business Logic Component) — Kimlik doğrulama iş mantığı.
///
/// Clean Architecture pattern:
/// UI → Event → BLoC → UseCase → Repository → DataSource
///
/// Yönetilen durumlar:
/// - [AuthInitial]         : Başlangıç durumu
/// - [AuthLoading]         : İşlem devam ediyor
/// - [AuthAuthenticated]   : Kullanıcı oturum açmış
/// - [AuthUnauthenticated] : Kullanıcı oturum açmamış
/// - [AuthError]           : Bir hata oluştu
/// - [PasswordResetSent]   : Şifre sıfırlama e-postası gönderildi
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  // ─── Event Handlers ─────────────────────────────────────────────────────

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      username: event.username,
      email: event.email,
      phone: event.phone,
      password: event.password,
      roleId: event.roleId,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Kullanıcı oturumunu kapatır.
  ///
  /// [AuthRepository.logout] çağrısı ile yerel önbellekteki token ve
  /// kullanıcı bilgilerini temizler.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  /// Uygulama açıldığında yerel önbellekteki token'ı kontrol eder.
  ///
  /// Token geçerliyse → [AuthAuthenticated] (otomatik giriş)
  /// Token yoksa    → [AuthUnauthenticated] (giriş sayfasına yönlendir)
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final loggedIn = await authRepository.isLoggedIn();

    if (!loggedIn) {
      emit(AuthUnauthenticated());
      return;
    }

    final userResult = await authRepository.getCachedUser();

    userResult.fold(
      (_) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await forgotPasswordUseCase(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSent(event.email)),
    );
  }
}
