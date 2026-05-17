import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository repository;

  const ChangePasswordUseCase(this.repository);

  Future<Either<Failure, String>> call(ChangePasswordParams params) {
    return repository.changePassword(params);
  }
}
