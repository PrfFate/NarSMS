import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      return await repository.logout();
    } catch (e) {
      return Left(ServerFailure('Logout failed: ${e.toString()}'));
    }
  }
}
