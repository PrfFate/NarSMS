import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/realtime/role_change_hub_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/change_password_usecase.dart';
import '../domain/usecases/get_user_info_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';
import '../presentation/bloc/home_bloc.dart';

/// Home feature'ına ait tüm bağımlılıkları kaydeder.
///
/// [GetUserInfoUseCase] artık [AuthRepository] üzerinden çalışır;
/// SharedPreferences'a doğrudan bağımlılık kaldırıldı.
Future<void> initHomeModule() async {
  // Repositories
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      dioClient: getIt<DioClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetUserInfoUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton(
    () => ChangePasswordUseCase(getIt<ProfileRepository>()),
  );

  // BLoC — Factory: her sayfada yeni instance
  getIt.registerFactory(
    () => HomeBloc(
      getUserInfoUseCase: getIt<GetUserInfoUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      roleChangeHubService: getIt<RoleChangeHubService>(),
    ),
  );
}
