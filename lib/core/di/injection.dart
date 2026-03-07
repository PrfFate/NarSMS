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

// Customer feature imports
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/search_customers_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_detail_usecase.dart';
import '../../features/customers/domain/usecases/create_customer_usecase.dart';
import '../../features/customers/domain/usecases/update_customer_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';

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

  // ===== CUSTOMER FEATURE =====

  // Data sources
  getIt.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(
      dioClient: getIt<DioClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      remoteDataSource: getIt<CustomerRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetCustomersUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton(
    () => SearchCustomersUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetCustomerDetailUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateCustomerUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateCustomerUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteCustomerUseCase(getIt<CustomerRepository>()),
  );

  // BLoC (Factory - her sayfada yeni instance)
  getIt.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: getIt<GetCustomersUseCase>(),
      searchCustomersUseCase: getIt<SearchCustomersUseCase>(),
      getCustomerDetailUseCase: getIt<GetCustomerDetailUseCase>(),
      createCustomerUseCase: getIt<CreateCustomerUseCase>(),
      updateCustomerUseCase: getIt<UpdateCustomerUseCase>(),
      deleteCustomerUseCase: getIt<DeleteCustomerUseCase>(),
    ),
  );
}

