import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_devices_usecase.dart';
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
  final CreateDeviceUseCase createDeviceUseCase;
  final BulkCreateDevicesUseCase bulkCreateDevicesUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;
  final GetDeviceTypesUseCase getDeviceTypesUseCase;
  final GetSuppliersUseCase getSuppliersUseCase;

  DeviceBloc({
    required this.searchDevicesUseCase,
    required this.createDeviceUseCase,
    required this.bulkCreateDevicesUseCase,
    required this.updateDeviceUseCase,
    required this.deleteDeviceUseCase,
    required this.getDeviceTypesUseCase,
    required this.getSuppliersUseCase,
  }) : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<SearchDevices>(_onSearchDevices);
    on<FilterDevices>(_onFilterDevices);
    on<LoadDeviceOptions>(_onLoadDeviceOptions);
    on<CreateDevice>(_onCreateDevice);
    on<BulkCreateDevices>(_onBulkCreateDevices);
    on<UpdateDevice>(_onUpdateDevice);
    on<DeleteDevice>(_onDeleteDevice);
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
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (paginatedResult) => emit(DeviceLoaded(result: paginatedResult)),
    );
  }

  Future<void> _onSearchDevices(
    SearchDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await searchDevicesUseCase(
      serialNumber: event.serialNumber,
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
}
