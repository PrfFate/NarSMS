import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}
