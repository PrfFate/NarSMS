import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_service_requests_usecase.dart';
import '../../domain/usecases/create_service_request_usecase.dart';
import '../../domain/usecases/send_to_shipment_usecase.dart';
import '../../domain/usecases/get_shipment_options_usecase.dart';
import 'technical_service_event.dart';
import 'technical_service_state.dart';
import '../../domain/entities/service_request_entity.dart';

class TechnicalServiceBloc extends Bloc<TechnicalServiceEvent, TechnicalServiceState> {
  final GetServiceRequestsUseCase getServiceRequestsUseCase;
  final CreateServiceRequestUseCase createServiceRequestUseCase;
  final SendToShipmentUseCase sendToShipmentUseCase;
  final GetShipmentOptionsUseCase getShipmentOptionsUseCase;

  TechnicalServiceBloc({
    required this.getServiceRequestsUseCase,
    required this.createServiceRequestUseCase,
    required this.sendToShipmentUseCase,
    required this.getShipmentOptionsUseCase,
  }) : super(TechnicalServiceInitial()) {
    on<LoadServiceRequests>(_onLoadServiceRequests);
    on<LoadMoreServiceRequests>(_onLoadMoreServiceRequests);
    on<CreateServiceRequest>(_onCreateServiceRequest);
    on<SendToShipment>(_onSendToShipment);
    on<LoadShipmentOptions>(_onLoadShipmentOptions);
  }

  Future<void> _onLoadShipmentOptions(
    LoadShipmentOptions event,
    Emitter<TechnicalServiceState> emit,
  ) async {
    final result = await getShipmentOptionsUseCase();

    result.fold(
      (failure) => emit(TechnicalServiceError(failure.message)),
      (options) => emit(ShipmentOptionsLoaded(
        carriers: options['carriers']!,
        fielders: options['fielders']!,
      )),
    );
  }

  Future<void> _onSendToShipment(
    SendToShipment event,
    Emitter<TechnicalServiceState> emit,
  ) async {
    emit(TechnicalServiceLoading());

    final result = await sendToShipmentUseCase(
      event.id, 
      event.shipmentType,
      carrierId: event.carrierId,
      fieldTeamUserId: event.fieldTeamUserId,
      trackingNumber: event.trackingNumber,
    );

    result.fold(
      (failure) => emit(TechnicalServiceError(failure.message)),
      (_) => emit(TechnicalServiceShipmentSuccess()),
    );
  }

  Future<void> _onCreateServiceRequest(
    CreateServiceRequest event,
    Emitter<TechnicalServiceState> emit,
  ) async {
    emit(TechnicalServiceLoading());

    final result = await createServiceRequestUseCase(event.requestData);

    result.fold(
      (failure) => emit(TechnicalServiceError(failure.message)),
      (_) => emit(TechnicalServiceCreateSuccess()),
    );
  }

  Future<void> _onLoadServiceRequests(
    LoadServiceRequests event,
    Emitter<TechnicalServiceState> emit,
  ) async {
    emit(TechnicalServiceLoading());

    final result = await getServiceRequestsUseCase(
      page: event.page,
      pageSize: event.pageSize,
      status: event.status,
    );

    result.fold(
      (failure) => emit(TechnicalServiceError(failure.message)),
      (paginatedResult) => emit(TechnicalServiceLoaded(
        requests: paginatedResult.items,
        totalCount: paginatedResult.totalCount,
        hasMore: paginatedResult.items.length < paginatedResult.totalCount,
        status: event.status,
      )),
    );
  }

  // Same for pagination load more...
  Future<void> _onLoadMoreServiceRequests(
    LoadMoreServiceRequests event,
    Emitter<TechnicalServiceState> emit,
  ) async {
    if (state is TechnicalServiceLoaded) {
      emit((state as TechnicalServiceLoaded).copyWith(isLoadingMore: true));
    }

    final result = await getServiceRequestsUseCase(
      page: event.nextPage,
      pageSize: event.pageSize,
      status: event.status,
    );

    result.fold(
      (failure) {
        if (state is TechnicalServiceLoaded) {
          emit((state as TechnicalServiceLoaded).copyWith(isLoadingMore: false));
        }
      },
      (paginatedResult) {
        final existing = List<ServiceRequestEntity>.from(event.existingRequests);
        final merged = [...existing, ...paginatedResult.items];
        emit(TechnicalServiceLoaded(
          requests: merged,
          totalCount: paginatedResult.totalCount,
          hasMore: merged.length < paginatedResult.totalCount,
          isLoadingMore: false,
          status: event.status,
        ));
      },
    );
  }
}
