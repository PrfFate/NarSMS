import '../../../core/di/injection.dart';
import '../../../core/network/network_info.dart';
import '../../field_management/data/datasources/field_task_remote_datasource.dart';
import '../../field_management/data/repositories/field_task_repository_impl.dart';
import '../../field_management/domain/repositories/field_task_repository.dart';
import '../../field_management/domain/usecases/accept_field_task_usecase.dart';
import '../../field_management/domain/usecases/get_field_tasks_usecase.dart';
import '../../field_management/domain/usecases/reassign_field_task_usecase.dart';
import '../../field_management/domain/usecases/reject_field_task_usecase.dart';

Future<void> initFieldManagementModule() async {
  if (!getIt.isRegistered<FieldTaskRemoteDataSource>()) {
    getIt.registerLazySingleton<FieldTaskRemoteDataSource>(
      () => FieldTaskRemoteDataSourceImpl(
        dioClient: getIt(),
        sharedPreferences: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<FieldTaskRepository>()) {
    getIt.registerLazySingleton<FieldTaskRepository>(
      () => FieldTaskRepositoryImpl(
        remoteDataSource: getIt(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetFieldTasksUseCase>()) {
    getIt.registerLazySingleton(() => GetFieldTasksUseCase(getIt()));
  }

  if (!getIt.isRegistered<AcceptFieldTaskUseCase>()) {
    getIt.registerLazySingleton(() => AcceptFieldTaskUseCase(getIt()));
  }

  if (!getIt.isRegistered<RejectFieldTaskUseCase>()) {
    getIt.registerLazySingleton(() => RejectFieldTaskUseCase(getIt()));
  }

  if (!getIt.isRegistered<ReassignFieldTaskUseCase>()) {
    getIt.registerLazySingleton(() => ReassignFieldTaskUseCase(getIt()));
  }
}
