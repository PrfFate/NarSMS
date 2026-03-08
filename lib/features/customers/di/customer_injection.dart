import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/customer_remote_datasource.dart';
import '../data/repositories/customer_repository_impl.dart';
import '../domain/repositories/customer_repository.dart';
import '../domain/usecases/get_customers_usecase.dart';
import '../domain/usecases/search_customers_usecase.dart';
import '../domain/usecases/get_customer_detail_usecase.dart';
import '../domain/usecases/create_customer_usecase.dart';
import '../domain/usecases/update_customer_usecase.dart';
import '../domain/usecases/delete_customer_usecase.dart';
import '../presentation/bloc/customer_bloc.dart';

/// Customer feature'ına ait tüm bağımlılıkları kaydeder.
///
/// Ana [injection.dart] dosyasından çağrılır.
/// Yeni bir Customer bileşeni eklendiğinde yalnızca bu dosya değişir.
Future<void> initCustomerModule() async {
  // Data Sources
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

  // Use Cases
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

  // BLoC — Factory: her sayfada yeni instance
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
