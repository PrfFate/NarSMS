import 'package:equatable/equatable.dart';
import '../../../../features/customers/domain/entities/paginated_result.dart';
import '../../domain/entities/device_type_entity.dart';

abstract class DeviceTypeState extends Equatable {
  const DeviceTypeState();

  @override
  List<Object?> get props => [];
}

class DeviceTypeInitial extends DeviceTypeState {}

class DeviceTypeLoading extends DeviceTypeState {}

class DeviceTypeLoaded extends DeviceTypeState {
  final PaginatedResult<DeviceTypeEntity> result;

  const DeviceTypeLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}

class DeviceTypeActionSuccess extends DeviceTypeState {
  final String message;

  const DeviceTypeActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceTypeError extends DeviceTypeState {
  final String message;

  const DeviceTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
