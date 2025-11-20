import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/failures.dart';

class GetUserInfoUseCase {
  final SharedPreferences sharedPreferences;

  GetUserInfoUseCase(this.sharedPreferences);

  Future<Either<Failure, Map<String, String>>> call() async {
    try {
      final userName = sharedPreferences.getString(StorageConstants.userName) ?? '';
      final userRole = sharedPreferences.getString(StorageConstants.userRole) ?? '';

      return Right({
        'userName': userName,
        'userRole': userRole,
      });
    } catch (e) {
      return Left(ServerFailure('Failed to load user info: ${e.toString()}'));
    }
  }
}
