import 'package:equatable/equatable.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../../domain/entities/device_entity.dart';
import '../../../../core/models/device_filter_model.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final PaginatedResult<DeviceEntity> result;
  final String? searchQuery;
  final DeviceFilterModel? activeFilter;

  const DeviceLoaded({required this.result, this.searchQuery, this.activeFilter});

  @override
  List<Object?> get props => [result, searchQuery, activeFilter];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceOptionsLoaded extends DeviceState {
  final List<String> deviceTypes;
  final List<String> suppliers;

  const DeviceOptionsLoaded({
    required this.deviceTypes,
    required this.suppliers,
  });

  @override
  List<Object?> get props => [deviceTypes, suppliers];
}

class DeviceActionSuccess extends DeviceState {
  final String message;

  const DeviceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
