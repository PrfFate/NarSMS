import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../data/datasources/technical_service_remote_datasource.dart';
import '../data/repositories/technical_service_repository_impl.dart';
import '../domain/repositories/technical_service_repository.dart';
import '../domain/usecases/get_service_requests_usecase.dart';
import '../domain/usecases/create_service_request_usecase.dart';
import '../domain/usecases/send_to_shipment_usecase.dart';
import '../domain/usecases/get_shipment_options_usecase.dart';
import '../presentation/bloc/technical_service_bloc.dart';

final getIt = GetIt.instance;

Future<void> initTechnicalServiceModule() async {
  // BLoC
  getIt.registerFactory(
    () => TechnicalServiceBloc(
      getServiceRequestsUseCase: getIt(),
      createServiceRequestUseCase: getIt(),
      sendToShipmentUseCase: getIt(),
      getShipmentOptionsUseCase: getIt(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton(() => GetServiceRequestsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateServiceRequestUseCase(getIt()));
  getIt.registerLazySingleton(() => SendToShipmentUseCase(getIt()));
  getIt.registerLazySingleton(() => GetShipmentOptionsUseCase(getIt()));

  // Repositories
  getIt.registerLazySingleton<TechnicalServiceRepository>(
    () => TechnicalServiceRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // DataSources
  getIt.registerLazySingleton<TechnicalServiceRemoteDataSource>(
    () => TechnicalServiceRemoteDataSourceImpl(
      dio: getIt<DioClient>().dio,
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
}
