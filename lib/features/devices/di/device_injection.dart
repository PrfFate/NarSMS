import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/repositories/device_repository_impl.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/usecases/search_devices_usecase.dart';
import '../domain/usecases/search_backup_assignments_usecase.dart';
import '../domain/usecases/assign_backup_assignment_usecase.dart';
import '../domain/usecases/return_backup_assignment_usecase.dart';
import '../domain/usecases/create_device_usecase.dart';
import '../domain/usecases/bulk_create_devices_usecase.dart';
import '../domain/usecases/update_device_usecase.dart';
import '../domain/usecases/delete_device_usecase.dart';
import '../domain/usecases/get_device_types_usecase.dart';
import '../domain/usecases/get_suppliers_usecase.dart';
import '../domain/usecases/get_device_movements_usecase.dart';
import '../domain/usecases/get_device_types_paged_usecase.dart';
import '../domain/usecases/create_device_type_usecase.dart';
import '../domain/usecases/create_device_type_usecase.dart';
import '../domain/usecases/update_device_type_usecase.dart';
import '../domain/usecases/delete_device_type_usecase.dart';
import '../domain/usecases/get_suppliers_detailed_usecase.dart';
import '../domain/usecases/create_supplier_usecase.dart';
import '../domain/usecases/update_supplier_usecase.dart';
import '../domain/usecases/delete_supplier_usecase.dart';
import '../presentation/bloc/device_bloc.dart';
import '../presentation/bloc/device_type_bloc.dart';
import '../presentation/bloc/supplier_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDeviceModule() async {
  // BLoC
  getIt.registerFactory(
    () => DeviceBloc(
      searchDevicesUseCase: getIt(),
      searchBackupAssignmentsUseCase: getIt(),
      assignBackupAssignmentUseCase: getIt(),
      returnBackupAssignmentUseCase: getIt(),
      createDeviceUseCase: getIt(),
      bulkCreateDevicesUseCase: getIt(),
      updateDeviceUseCase: getIt(),
      deleteDeviceUseCase: getIt(),
      getDeviceTypesUseCase: getIt(),
      getSuppliersUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => DeviceTypeBloc(
      getDeviceTypesPagedUseCase: getIt(),
      createDeviceTypeUseCase: getIt(),
      updateDeviceTypeUseCase: getIt(),
      deleteDeviceTypeUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => SupplierBloc(
      getSuppliersDetailedUseCase: getIt(),
      createSupplierUseCase: getIt(),
      updateSupplierUseCase: getIt(),
      deleteSupplierUseCase: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => SearchDevicesUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchBackupAssignmentsUseCase(getIt()));
  getIt.registerLazySingleton(() => AssignBackupAssignmentUseCase(getIt()));
  getIt.registerLazySingleton(() => ReturnBackupAssignmentUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateDeviceUseCase(getIt()));
  getIt.registerLazySingleton(() => BulkCreateDevicesUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateDeviceUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteDeviceUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDeviceTypesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSuppliersUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDeviceMovementsUseCase(getIt()));

  getIt.registerLazySingleton(() => GetDeviceTypesPagedUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateDeviceTypeUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateDeviceTypeUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteDeviceTypeUseCase(getIt()));

  getIt.registerLazySingleton(() => GetSuppliersDetailedUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateSupplierUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateSupplierUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteSupplierUseCase(getIt()));

  // Repository
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(
      dioClient: getIt<DioClient>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
}
