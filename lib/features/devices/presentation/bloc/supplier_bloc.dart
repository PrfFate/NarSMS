import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_suppliers_detailed_usecase.dart';
import '../../domain/usecases/create_supplier_usecase.dart';
import '../../domain/usecases/update_supplier_usecase.dart';
import '../../domain/usecases/delete_supplier_usecase.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final GetSuppliersDetailedUseCase getSuppliersDetailedUseCase;
  final CreateSupplierUseCase createSupplierUseCase;
  final UpdateSupplierUseCase updateSupplierUseCase;
  final DeleteSupplierUseCase deleteSupplierUseCase;

  SupplierBloc({
    required this.getSuppliersDetailedUseCase,
    required this.createSupplierUseCase,
    required this.updateSupplierUseCase,
    required this.deleteSupplierUseCase,
  }) : super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<CreateSupplier>(_onCreateSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());

    final result = await getSuppliersDetailedUseCase();

    result.fold(
      (failure) => emit(SupplierError(failure.message)),
      (suppliers) => emit(SupplierLoaded(suppliers: suppliers)),
    );
  }

  Future<void> _onCreateSupplier(
    CreateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());

    final result = await createSupplierUseCase(event.data);

    result.fold(
      (failure) => emit(SupplierError(failure.message)),
      (_) => emit(const SupplierActionSuccess('Tedarikçi başarıyla oluşturuldu.')),
    );
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());

    final result = await updateSupplierUseCase(event.id, event.data);

    result.fold(
      (failure) => emit(SupplierError(failure.message)),
      (_) => emit(const SupplierActionSuccess('Tedarikçi başarıyla güncellendi.')),
    );
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());

    final result = await deleteSupplierUseCase(event.id);

    result.fold(
      (failure) => emit(SupplierError(failure.message)),
      (_) => emit(const SupplierActionSuccess('Tedarikçi başarıyla silindi.')),
    );
  }
}
