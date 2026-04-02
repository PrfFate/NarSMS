import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasarim_app/core/di/injection.dart';
import 'package:tasarim_app/core/network/dio_client.dart';
import 'package:tasarim_app/core/network/network_info.dart';
import 'package:tasarim_app/features/sales/data/datasources/sale_remote_datasource.dart';
import 'package:tasarim_app/features/sales/data/datasources/approval_remote_datasource.dart';
import 'package:tasarim_app/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:tasarim_app/features/sales/data/repositories/approval_repository_impl.dart';
import 'package:tasarim_app/features/sales/domain/repositories/sale_repository.dart';
import 'package:tasarim_app/features/sales/domain/repositories/approval_repository.dart';
import 'package:tasarim_app/features/sales/domain/usecases/get_sales_by_status_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/get_shipment_by_sale_id_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/create_shipment_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/carrier_management_usecases.dart';
import 'package:tasarim_app/features/sales/domain/usecases/get_fielders_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/approval_usecases.dart';
import 'package:tasarim_app/features/sales/domain/usecases/mark_shipment_delivered_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/sale_approval_usecases.dart';
import 'package:tasarim_app/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/carrier_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_bloc.dart';

/// Sale feature bağımlılıklarını kaydeder.
Future<void> initSaleModule() async {
  // Data Sources
  getIt.registerLazySingleton<SaleRemoteDataSource>(
    () => SaleRemoteDataSourceImpl(
      getIt.get<DioClient>(),
      getIt.get<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<ApprovalRemoteDataSource>(
    () => ApprovalRemoteDataSourceImpl(
      getIt.get<DioClient>(),
      getIt.get<SharedPreferences>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(
      remoteDataSource: getIt.get<SaleRemoteDataSource>(),
      networkInfo: getIt.get<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<ApprovalRepository>(
    () => ApprovalRepositoryImpl(
      remoteDataSource: getIt.get<ApprovalRemoteDataSource>(),
      networkInfo: getIt.get<NetworkInfo>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
      () => GetSalesByStatusUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => GetShipmentBySaleIdUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => CreateShipmentUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => GetCarriersUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => CreateCarrierUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => UpdateCarrierUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => DeleteCarrierUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => GetFieldersUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => MarkShipmentDeliveredUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => ApproveSaleUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => RejectSaleUseCase(getIt.get<SaleRepository>()));
  getIt.registerLazySingleton(
      () => CreateSaleUseCase(getIt.get<SaleRepository>()));

  // Approval Use Cases
  getIt.registerLazySingleton(
      () => GetWorkflowsUseCase(getIt.get<ApprovalRepository>()));
  getIt.registerLazySingleton(
      () => CreateWorkflowUseCase(getIt.get<ApprovalRepository>()));
  getIt.registerLazySingleton(
      () => DeleteWorkflowUseCase(getIt.get<ApprovalRepository>()));
  getIt.registerLazySingleton(
      () => ActivateWorkflowUseCase(getIt.get<ApprovalRepository>()));
  getIt.registerLazySingleton(
      () => DeactivateWorkflowUseCase(getIt.get<ApprovalRepository>()));
  getIt.registerLazySingleton(
      () => UpdateWorkflowVersionUseCase(getIt.get<ApprovalRepository>()));
  getIt.registerLazySingleton(
      () => GetRolesUseCase(getIt.get<ApprovalRepository>()));

  // BLoC
  getIt.registerFactory<SaleBloc>(
    () => SaleBloc(
      getSalesByStatus: getIt.get<GetSalesByStatusUseCase>(),
      getShipmentBySaleId: getIt.get<GetShipmentBySaleIdUseCase>(),
      createShipmentUseCase: getIt.get<CreateShipmentUseCase>(),
      getCarriersUseCase: getIt.get<GetCarriersUseCase>(),
      getFieldersUseCase: getIt.get<GetFieldersUseCase>(),
      markDeliveredUseCase: getIt.get<MarkShipmentDeliveredUseCase>(),
      approveSaleUseCase: getIt.get<ApproveSaleUseCase>(),
      rejectSaleUseCase: getIt.get<RejectSaleUseCase>(),
      createSaleUseCase: getIt.get<CreateSaleUseCase>(),
    ),
  );

  getIt.registerFactory<CarrierBloc>(
    () => CarrierBloc(
      getCarriers: getIt.get<GetCarriersUseCase>(),
      createCarrier: getIt.get<CreateCarrierUseCase>(),
      updateCarrier: getIt.get<UpdateCarrierUseCase>(),
      deleteCarrier: getIt.get<DeleteCarrierUseCase>(),
    ),
  );

  getIt.registerFactory<ApprovalBloc>(
    () => ApprovalBloc(
      getWorkflows: getIt.get<GetWorkflowsUseCase>(),
      createWorkflow: getIt.get<CreateWorkflowUseCase>(),
      deleteWorkflow: getIt.get<DeleteWorkflowUseCase>(),
      activateWorkflow: getIt.get<ActivateWorkflowUseCase>(),
      deactivateWorkflow: getIt.get<DeactivateWorkflowUseCase>(),
      updateWorkflowVersion: getIt.get<UpdateWorkflowVersionUseCase>(),
      getRoles: getIt.get<GetRolesUseCase>(),
    ),
  );
}
