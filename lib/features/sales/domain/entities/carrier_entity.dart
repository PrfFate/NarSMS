import 'package:equatable/equatable.dart';

class CarrierEntity extends Equatable {
  final int id;
  final String name;

  const CarrierEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
