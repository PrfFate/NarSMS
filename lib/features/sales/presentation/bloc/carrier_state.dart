import 'package:equatable/equatable.dart';
import '../../domain/entities/carrier_entity.dart';

abstract class CarrierState extends Equatable {
  const CarrierState();

  @override
  List<Object?> get props => [];
}

class CarrierInitial extends CarrierState {}

class CarrierLoading extends CarrierState {}

class CarriersLoaded extends CarrierState {
  final List<CarrierEntity> carriers;
  const CarriersLoaded(this.carriers);

  @override
  List<Object?> get props => [carriers];
}

class CarrierOperationSuccess extends CarrierState {
  final String message;
  const CarrierOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CarrierError extends CarrierState {
  final String message;
  const CarrierError(this.message);

  @override
  List<Object?> get props => [message];
}
