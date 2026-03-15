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

  const LoadDevices({this.page = 1, this.pageSize = 15});

  @override
  List<Object?> get props => [page, pageSize];
}

class SearchDevices extends DeviceEvent {
  final String? serialNumber;
  final DeviceFilterModel? filter;
  final int page;
  final int pageSize;

  const SearchDevices({
    this.serialNumber,
    this.filter,
    this.page = 1,
    this.pageSize = 15,
  });

  @override
  List<Object?> get props => [serialNumber, filter, page, pageSize];
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
