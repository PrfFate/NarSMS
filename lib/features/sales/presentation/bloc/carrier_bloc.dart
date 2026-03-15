import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/carrier_management_usecases.dart';
import 'carrier_event.dart';
import 'carrier_state.dart';

class CarrierBloc extends Bloc<CarrierEvent, CarrierState> {
  final GetCarriersUseCase getCarriers;
  final CreateCarrierUseCase createCarrier;
  final UpdateCarrierUseCase updateCarrier;
  final DeleteCarrierUseCase deleteCarrier;

  CarrierBloc({
    required this.getCarriers,
    required this.createCarrier,
    required this.updateCarrier,
    required this.deleteCarrier,
  }) : super(CarrierInitial()) {
    on<LoadCarriers>(_onLoadCarriers);
    on<CreateCarrier>(_onCreateCarrier);
    on<UpdateCarrier>(_onUpdateCarrier);
    on<DeleteCarrier>(_onDeleteCarrier);
  }

  Future<void> _onLoadCarriers(
      LoadCarriers event, Emitter<CarrierState> emit) async {
    emit(CarrierLoading());
    final result = await getCarriers();
    result.fold(
      (failure) => emit(CarrierError(failure.message)),
      (carriers) => emit(CarriersLoaded(carriers)),
    );
  }

  Future<void> _onCreateCarrier(
      CreateCarrier event, Emitter<CarrierState> emit) async {
    emit(CarrierLoading());
    final result = await createCarrier(event.name);
    result.fold(
      (failure) => emit(CarrierError(failure.message)),
      (_) {
        emit(const CarrierOperationSuccess('Kargo firması başarıyla eklendi'));
        add(LoadCarriers());
      },
    );
  }

  Future<void> _onUpdateCarrier(
      UpdateCarrier event, Emitter<CarrierState> emit) async {
    emit(CarrierLoading());
    final result = await updateCarrier(event.id, event.name);
    result.fold(
      (failure) => emit(CarrierError(failure.message)),
      (_) {
        emit(const CarrierOperationSuccess(
            'Kargo firması başarıyla güncellendi'));
        add(LoadCarriers());
      },
    );
  }

  Future<void> _onDeleteCarrier(
      DeleteCarrier event, Emitter<CarrierState> emit) async {
    emit(CarrierLoading());
    final result = await deleteCarrier(event.id);
    result.fold(
      (failure) => emit(CarrierError(failure.message)),
      (_) {
        emit(const CarrierOperationSuccess('Kargo firması başarıyla silindi'));
        add(LoadCarriers());
      },
    );
  }
}
