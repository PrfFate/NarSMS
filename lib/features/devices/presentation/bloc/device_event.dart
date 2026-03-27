import 'package:equatable/equatable.dart';
import '../../../../core/models/device_filter_model.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDevices extends DeviceEvent {
  final int page;
  final int pageSize;
  final String? status;

  const LoadDevices({this.page = 1, this.pageSize = 15, this.status});

  @override
  List<Object?> get props => [page, pageSize, status];
}

/// Mevcut listenin sonum gelince bir sonraki sayfayı yükler.
/// [existingDevices] — şu an ekranda görünen tüm cihazlar (append için)
class LoadMoreDevices extends DeviceEvent {
  final int nextPage;
  final int pageSize;
  // Hangi modda olduğumuzu taşıyoruz:
  final String? searchQuery;
  final DeviceFilterModel? activeFilter;
  final String? status;
  final List existingDevices; // DeviceEntity listesi

  const LoadMoreDevices({
    required this.nextPage,
    required this.existingDevices,
    this.pageSize = 15,
    this.searchQuery,
    this.activeFilter,
    this.status,
  });

  @override
  List<Object?> get props => [nextPage, pageSize, searchQuery, activeFilter, status];
}

class LoadAssignedBackupDevices extends DeviceEvent {
  final bool isReturned;
  final String? serialNumber;
  final DeviceFilterModel? filter;
  final int page;
  final int pageSize;

  const LoadAssignedBackupDevices({
    this.isReturned = false,
    this.serialNumber,
    this.filter,
    this.page = 1,
    this.pageSize = 15,
  });

  @override
  List<Object?> get props => [isReturned, serialNumber, filter, page, pageSize];
}

class SearchDevices extends DeviceEvent {
  final String? serialNumber;
  final String? status;
  final DeviceFilterModel? filter;
  final int page;
  final int pageSize;

  const SearchDevices({
    this.serialNumber,
    this.status,
    this.filter,
    this.page = 1,
    this.pageSize = 15,
  });

  @override
  List<Object?> get props => [serialNumber, status, filter, page, pageSize];
}

class FilterDevices extends DeviceEvent {
  final DeviceFilterModel filter;
  final int page;
  final int pageSize;

  const FilterDevices({
    required this.filter,
    this.page = 1,
    this.pageSize = 15,
  });

  @override
  List<Object?> get props => [filter, page, pageSize];
}

class LoadDeviceOptions extends DeviceEvent {}

class CreateDevice extends DeviceEvent {
  final Map<String, dynamic> requestData;

  const CreateDevice(this.requestData);

  @override
  List<Object?> get props => [requestData];
}

class BulkCreateDevices extends DeviceEvent {
  final Map<String, dynamic> requestData;

  const BulkCreateDevices(this.requestData);

  @override
  List<Object?> get props => [requestData];
}

class UpdateDevice extends DeviceEvent {
  final int id;
  final Map<String, dynamic> requestData;

  const UpdateDevice({required this.id, required this.requestData});

  @override
  List<Object?> get props => [id, requestData];
}

class DeleteDevice extends DeviceEvent {
  final int id;

  const DeleteDevice(this.id);

  @override
  List<Object?> get props => [id];
}

class AssignBackupAssignment extends DeviceEvent {
  final int deviceId;
  final Map<String, dynamic> requestData;

  const AssignBackupAssignment({required this.deviceId, required this.requestData});

  @override
  List<Object?> get props => [deviceId, requestData];
}

class ReturnBackupAssignment extends DeviceEvent {
  final int assignmentId;
  final String? reason;

  const ReturnBackupAssignment({required this.assignmentId, this.reason});

  @override
  List<Object?> get props => [assignmentId, reason];
}
