import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_device_types_paged_usecase.dart';
import '../../domain/usecases/create_device_type_usecase.dart';
import '../../domain/usecases/update_device_type_usecase.dart';
import '../../domain/usecases/delete_device_type_usecase.dart';
import 'device_type_event.dart';
import 'device_type_state.dart';

class DeviceTypeBloc extends Bloc<DeviceTypeEvent, DeviceTypeState> {
  final GetDeviceTypesPagedUseCase getDeviceTypesPagedUseCase;
  final CreateDeviceTypeUseCase createDeviceTypeUseCase;
  final UpdateDeviceTypeUseCase updateDeviceTypeUseCase;
  final DeleteDeviceTypeUseCase deleteDeviceTypeUseCase;

  DeviceTypeBloc({
    required this.getDeviceTypesPagedUseCase,
    required this.createDeviceTypeUseCase,
    required this.updateDeviceTypeUseCase,
    required this.deleteDeviceTypeUseCase,
  }) : super(DeviceTypeInitial()) {
    on<LoadDeviceTypesPaged>(_onLoadDeviceTypesPaged);
    on<CreateDeviceType>(_onCreateDeviceType);
    on<UpdateDeviceType>(_onUpdateDeviceType);
    on<DeleteDeviceType>(_onDeleteDeviceType);
  }

  Future<void> _onLoadDeviceTypesPaged(
    LoadDeviceTypesPaged event,
    Emitter<DeviceTypeState> emit,
  ) async {
    emit(DeviceTypeLoading());

    final result = await getDeviceTypesPagedUseCase(page: event.page, pageSize: event.pageSize);

    result.fold(
      (failure) => emit(DeviceTypeError(failure.message)),
      (paginated) => emit(DeviceTypeLoaded(result: paginated)),
    );
  }

  Future<void> _onCreateDeviceType(
    CreateDeviceType event,
    Emitter<DeviceTypeState> emit,
  ) async {
    emit(DeviceTypeLoading());

    final result = await createDeviceTypeUseCase(event.name);

    result.fold(
      (failure) => emit(DeviceTypeError(failure.message)),
      (_) => emit(const DeviceTypeActionSuccess('Cihaz modeli başarıyla oluşturuldu.')),
    );
  }

  Future<void> _onUpdateDeviceType(
    UpdateDeviceType event,
    Emitter<DeviceTypeState> emit,
  ) async {
    emit(DeviceTypeLoading());

    final result = await updateDeviceTypeUseCase(event.id, event.name);

    result.fold(
      (failure) => emit(DeviceTypeError(failure.message)),
      (_) => emit(const DeviceTypeActionSuccess('Cihaz modeli başarıyla güncellendi.')),
    );
  }

  Future<void> _onDeleteDeviceType(
    DeleteDeviceType event,
    Emitter<DeviceTypeState> emit,
  ) async {
    emit(DeviceTypeLoading());

    final result = await deleteDeviceTypeUseCase(event.id);

    result.fold(
      (failure) => emit(DeviceTypeError(failure.message)),
      (_) => emit(const DeviceTypeActionSuccess('Cihaz modeli başarıyla silindi.')),
    );
  }
}
