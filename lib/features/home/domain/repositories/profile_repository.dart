import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class UpdateProfileParams {
  final int id;
  final String username;
  final String email;
  final String phone;

  const UpdateProfileParams({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
  });
}

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });
}

abstract class ProfileRepository {
  Future<Either<Failure, void>> updateProfile(UpdateProfileParams params);

  Future<Either<Failure, String>> changePassword(ChangePasswordParams params);
}
