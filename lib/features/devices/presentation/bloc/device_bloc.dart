import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_devices_usecase.dart';
import '../../domain/usecases/search_backup_assignments_usecase.dart';
import '../../domain/usecases/assign_backup_assignment_usecase.dart';
import '../../domain/usecases/return_backup_assignment_usecase.dart';
import '../../domain/usecases/create_device_usecase.dart';
import '../../domain/usecases/bulk_create_devices_usecase.dart';
import '../../domain/usecases/update_device_usecase.dart';
import '../../domain/usecases/delete_device_usecase.dart';
import '../../domain/usecases/get_device_types_usecase.dart';
import '../../domain/usecases/get_suppliers_usecase.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final SearchDevicesUseCase searchDevicesUseCase;
  final SearchBackupAssignmentsUseCase searchBackupAssignmentsUseCase;
  final AssignBackupAssignmentUseCase assignBackupAssignmentUseCase;
  final ReturnBackupAssignmentUseCase returnBackupAssignmentUseCase;
  final CreateDeviceUseCase createDeviceUseCase;
  final BulkCreateDevicesUseCase bulkCreateDevicesUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;
  final GetDeviceTypesUseCase getDeviceTypesUseCase;
  final GetSuppliersUseCase getSuppliersUseCase;

  DeviceBloc({
    required this.searchDevicesUseCase,
    required this.searchBackupAssignmentsUseCase,
    required this.assignBackupAssignmentUseCase,
    required this.returnBackupAssignmentUseCase,
    required this.createDeviceUseCase,
    required this.bulkCreateDevicesUseCase,
    required this.updateDeviceUseCase,
    required this.deleteDeviceUseCase,
    required this.getDeviceTypesUseCase,
    required this.getSuppliersUseCase,
  }) : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<LoadAssignedBackupDevices>(_onLoadAssignedBackupDevices);
    on<SearchDevices>(_onSearchDevices);
    on<FilterDevices>(_onFilterDevices);
    on<LoadDeviceOptions>(_onLoadDeviceOptions);
    on<CreateDevice>(_onCreateDevice);
    on<BulkCreateDevices>(_onBulkCreateDevices);
    on<UpdateDevice>(_onUpdateDevice);
    on<DeleteDevice>(_onDeleteDevice);
    on<AssignBackupAssignment>(_onAssignBackupAssignment);
    on<ReturnBackupAssignment>(_onReturnBackupAssignment);
  }

  Future<void> _onLoadDeviceOptions(
    LoadDeviceOptions event,
    Emitter<DeviceState> emit,
  ) async {
    // DeviceLoading emit edilmez — cihaz listesinin mevcut durumunu bozmamak için.
    // Bu handler sadece dropdown/filtre seçeneklerini yükler.
    final typesResult = await getDeviceTypesUseCase();
    final suppliersResult = await getSuppliersUseCase();

    typesResult.fold(
      (failure) => null, // Sessizce geç, liste bozulmasın
      (types) {
        suppliersResult.fold(
          (failure) => null,
          (suppliers) => emit(DeviceOptionsLoaded(
            deviceTypes: types,
            suppliers: suppliers,
          )),
        );
      },
    );
  }

  Future<void> _onCreateDevice(
    CreateDevice event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await createDeviceUseCase(event.requestData);

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (_) => emit(const DeviceActionSuccess('Cihaz başarıyla eklendi')),
    );
  }

  Future<void> _onBulkCreateDevices(
    BulkCreateDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await bulkCreateDevicesUseCase(event.requestData);

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (_) => emit(const DeviceActionSuccess('Cihazlar toplu olarak başarıyla eklendi')),
    );
  }

  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    // Başlangıçta boş query ile arama kullanılarak listeleme yapılır.
    final result = await searchDevicesUseCase(
      status: event.status,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (paginatedResult) => emit(DeviceLoaded(
        result: paginatedResult,
        status: event.status,
      )),
    );
  }

  Future<void> _onLoadAssignedBackupDevices(
    LoadAssignedBackupDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await searchBackupAssignmentsUseCase(
      isReturned: event.isReturned,
      serialNumber: event.serialNumber,
      filter: event.filter,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (paginatedResult) => emit(DeviceLoaded(
        result: paginatedResult,
        status: 'AssignedBackup',
        searchQuery: event.serialNumber,
        activeFilter: event.filter,
      )),
    );
  }

  Future<void> _onSearchDevices(
    SearchDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await searchDevicesUseCase(
      serialNumber: event.serialNumber,
      status: event.status,
      filter: event.filter,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (paginatedResult) => emit(DeviceLoaded(
        result: paginatedResult,
        searchQuery: event.serialNumber,
        activeFilter: event.filter,
      )),
    );
  }

  Future<void> _onFilterDevices(
    FilterDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await searchDevicesUseCase(
      filter: event.filter,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (paginatedResult) => emit(DeviceLoaded(
        result: paginatedResult,
        activeFilter: event.filter,
      )),
    );
  }

  Future<void> _onUpdateDevice(
    UpdateDevice event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await updateDeviceUseCase(event.id, event.requestData);

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (_) => emit(const DeviceActionSuccess('Cihaz başarıyla güncellendi')),
    );
  }

  Future<void> _onDeleteDevice(
    DeleteDevice event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await deleteDeviceUseCase(event.id);

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (_) => emit(const DeviceActionSuccess('Cihaz başarıyla silindi')),
    );
  }

  Future<void> _onAssignBackupAssignment(
    AssignBackupAssignment event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await assignBackupAssignmentUseCase(event.deviceId, event.requestData);

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (_) => emit(const DeviceActionSuccess('Yedek cihaz başarıyla müşteriye atandı')),
    );
  }

  Future<void> _onReturnBackupAssignment(
    ReturnBackupAssignment event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await returnBackupAssignmentUseCase(
      assignmentId: event.assignmentId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (_) => emit(const DeviceActionSuccess('Cihaz başarıyla geri alındı')),
    );
  }
}
