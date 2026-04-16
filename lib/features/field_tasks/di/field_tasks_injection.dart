import '../../../core/di/injection.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/task_type_remote_datasource.dart';
import '../data/repositories/task_type_repository_impl.dart';
import '../domain/repositories/task_type_repository.dart';
import '../presentation/bloc/task_type/task_type_bloc.dart';

Future<void> initFieldTasksModule() async {
  // BLoC
  getIt.registerFactory(() => TaskTypeBloc(repository: getIt()));

  // Repository
  getIt.registerLazySingleton<TaskTypeRepository>(
    () => TaskTypeRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data Source
  getIt.registerLazySingleton<TaskTypeRemoteDataSource>(
    () => TaskTypeRemoteDataSourceImpl(
      dioClient: getIt<DioClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
}
