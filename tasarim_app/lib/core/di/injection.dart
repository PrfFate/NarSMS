import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

// Auth feature imports
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Home feature imports
import '../../features/home/domain/usecases/get_user_info_usecase.dart';
import '../../features/home/domain/usecases/logout_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // ===== EXTERNAL DEPENDENCIES =====
  getIt.registerLazySingleton(() => Connectivity());

  // SharedPreferences (async initialization)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // ===== CORE DEPENDENCIES =====
  getIt.registerLazySingleton(() => DioClient());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // ===== AUTH FEATURE =====

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => ForgotPasswordUseCase(getIt<AuthRepository>()),
  );

  // BLoC (Factory pattern - yeni instance her seferinde)
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
    ),
  );

  // ===== HOME FEATURE =====

  // Use cases
  getIt.registerLazySingleton(
    () => GetUserInfoUseCase(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => HomeBloc(
      getUserInfoUseCase: getIt<GetUserInfoUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );
}
