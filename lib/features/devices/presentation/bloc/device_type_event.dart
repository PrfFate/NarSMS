import 'package:equatable/equatable.dart';

abstract class DeviceTypeEvent extends Equatable {
  const DeviceTypeEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeviceTypesPaged extends DeviceTypeEvent {
  final int page;
  final int pageSize;

  const LoadDeviceTypesPaged({this.page = 1, this.pageSize = 15});

  @override
  List<Object?> get props => [page, pageSize];
}

class CreateDeviceType extends DeviceTypeEvent {
  final String name;

  const CreateDeviceType(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateDeviceType extends DeviceTypeEvent {
  final int id;
  final String name;

  const UpdateDeviceType(this.id, this.name);

  @override
  List<Object?> get props => [id, name];
}

class DeleteDeviceType extends DeviceTypeEvent {
  final int id;

  const DeleteDeviceType(this.id);

  @override
  List<Object?> get props => [id];
}
