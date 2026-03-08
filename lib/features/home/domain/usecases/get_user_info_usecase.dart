import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Oturum açmış kullanıcının önbellekteki bilgilerini getirir.
///
/// Domain katmanının [SharedPreferences] veya herhangi bir data katmanı
/// paketine doğrudan bağımlı olmamasını sağlar. Tüm önbellek okuma işlemi
/// [AuthRepository] soyutlaması üzerinden yapılır (Dependency Inversion).
class GetUserInfoUseCase {
  final AuthRepository repository;

  GetUserInfoUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.getCachedUser();
  }
}
