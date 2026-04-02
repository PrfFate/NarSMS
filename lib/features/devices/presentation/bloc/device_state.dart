import 'package:equatable/equatable.dart';
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
  final List<DeviceEntity> devices;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String? searchQuery;
  final DeviceFilterModel? activeFilter;
  final String? status;

  const DeviceLoaded({
    required this.devices,
    required this.totalCount,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.searchQuery,
    this.activeFilter,
    this.status,
  });

  DeviceLoaded copyWith({
    List<DeviceEntity>? devices,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    DeviceFilterModel? activeFilter,
    String? status,
  }) {
    return DeviceLoaded(
      devices: devices ?? this.devices,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        devices,
        totalCount,
        hasMore,
        isLoadingMore,
        searchQuery,
        activeFilter,
        status,
      ];
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
