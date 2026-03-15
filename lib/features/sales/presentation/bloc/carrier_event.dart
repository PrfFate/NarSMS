import 'package:equatable/equatable.dart';
import '../../domain/entities/carrier_entity.dart';

abstract class CarrierEvent extends Equatable {
  const CarrierEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarriers extends CarrierEvent {}

class CreateCarrier extends CarrierEvent {
  final String name;
  const CreateCarrier(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateCarrier extends CarrierEvent {
  final int id;
  final String name;
  const UpdateCarrier(this.id, this.name);

  @override
  List<Object?> get props => [id, name];
}

class DeleteCarrier extends CarrierEvent {
  final int id;
  const DeleteCarrier(this.id);

  @override
  List<Object?> get props => [id];
}
