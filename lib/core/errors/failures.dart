import 'package:equatable/equatable.dart';
import 'failure_codes.dart';

/// Uygulama genelinde kullanılan soyut hata sınıfı.
///
/// Her [Failure] alt tipi bir [message] ve bir [code] taşır.
/// [message]: debug/log amacıyla kullanılır; UI'de doğrudan gösterilmez.
/// [code]: Presentation katmanının kullanıcıya gösterilecek metni
///         seçmek için kullandığı [AppFailureCode] değeri.
abstract class Failure extends Equatable {
  final String message;
  final AppFailureCode code;

  const Failure(this.message, {required this.code});

  @override
  List<Object?> get props => [message, code];
}

// ─── Failure Alt Tipleri ────────────────────────────────────────────────────

class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    super.code = AppFailureCode.serverError,
  });
}

class CacheFailure extends Failure {
  const CacheFailure(
    super.message, {
    super.code = AppFailureCode.cacheError,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    super.code = AppFailureCode.noInternet,
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(
    super.message, {
    super.code = AppFailureCode.unauthorized,
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(
    super.message, {
    super.code = AppFailureCode.validation,
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, errors];
}
