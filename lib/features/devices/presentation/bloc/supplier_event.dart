import 'package:equatable/equatable.dart';

abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuppliers extends SupplierEvent {}

class CreateSupplier extends SupplierEvent {
  final Map<String, dynamic> data;

  const CreateSupplier(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateSupplier extends SupplierEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateSupplier(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteSupplier extends SupplierEvent {
  final int id;

  const DeleteSupplier(this.id);

  @override
  List<Object?> get props => [id];
}
