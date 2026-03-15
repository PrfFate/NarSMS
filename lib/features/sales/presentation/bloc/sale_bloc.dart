import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasarim_app/features/sales/domain/usecases/get_sales_by_status_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/get_shipment_by_sale_id_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/create_shipment_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/carrier_management_usecases.dart';
import 'package:tasarim_app/features/sales/domain/usecases/get_fielders_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/mark_shipment_delivered_usecase.dart';
import 'package:tasarim_app/features/sales/domain/usecases/sale_approval_usecases.dart';
import 'sale_event.dart';
import 'sale_state.dart';

/// Satış listesi ve kargo detayı iş mantığı.
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final GetSalesByStatusUseCase getSalesByStatus;
  final GetShipmentBySaleIdUseCase getShipmentBySaleId;
  final CreateShipmentUseCase createShipmentUseCase;
  final GetCarriersUseCase getCarriersUseCase;
  final GetFieldersUseCase getFieldersUseCase;
  final MarkShipmentDeliveredUseCase markDeliveredUseCase;
  final ApproveSaleUseCase approveSaleUseCase;
  final RejectSaleUseCase rejectSaleUseCase;

  SaleBloc({
    required this.getSalesByStatus,
    required this.getShipmentBySaleId,
    required this.createShipmentUseCase,
    required this.getCarriersUseCase,
    required this.getFieldersUseCase,
    required this.markDeliveredUseCase,
    required this.approveSaleUseCase,
    required this.rejectSaleUseCase,
  }) : super(const SaleInitial()) {
    on<LoadSalesByStatus>(_onLoadSalesByStatus);
    on<LoadShipmentDetail>(_onLoadShipmentDetail);
    on<LoadShipmentOptions>(_onLoadShipmentOptions);
    on<CreateShipment>(_onCreateShipment);
    on<MarkShipmentDelivered>(_onMarkShipmentDelivered);
    on<ApproveSale>(_onApproveSale);
    on<RejectSale>(_onRejectSale);
  }

  Future<void> _onLoadSalesByStatus(
    LoadSalesByStatus event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final result = await getSalesByStatus(
      status: event.status,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (paginated) => emit(SalesLoaded(paginated)),
    );
  }

  Future<void> _onLoadShipmentDetail(
    LoadShipmentDetail event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final result = await getShipmentBySaleId(event.saleId);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (shipments) => emit(ShipmentLoaded(shipments)),
    );
  }

  Future<void> _onLoadShipmentOptions(
    LoadShipmentOptions event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final carriersResult = await getCarriersUseCase();
    final fieldersResult = await getFieldersUseCase();

    List<int> shippedItemIds = [];
    if (event.saleId != null) {
      final shipmentsResult = await getShipmentBySaleId(event.saleId!);
      shipmentsResult.fold(
        (_) => null, // Hata olsa da devam et
        (shipments) {
          for (var s in shipments) {
            shippedItemIds.addAll(s.items.map((i) => i.saleItemId));
          }
        },
      );
    }

    carriersResult.fold(
      (failure) => emit(SaleError(failure.message)),
      (carriers) {
        fieldersResult.fold(
          (failure) => emit(SaleError(failure.message)),
          (fielders) => emit(ShipmentOptionsLoaded(
            carriers: carriers,
            fielders: fielders,
            shippedSaleItemIds: shippedItemIds,
          )),
        );
      },
    );
  }

  Future<void> _onCreateShipment(
    CreateShipment event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final result = await createShipmentUseCase(event.request);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (_) => emit(const ShipmentCreated()),
    );
  }

  Future<void> _onMarkShipmentDelivered(
    MarkShipmentDelivered event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final result = await markDeliveredUseCase(event.shipmentId);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (_) => emit(const ShipmentDelivered()),
    );
  }

  Future<void> _onApproveSale(
    ApproveSale event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final result = await approveSaleUseCase(event.id, event.note);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (_) => emit(const SaleApproved()),
    );
  }

  Future<void> _onRejectSale(
    RejectSale event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoading());

    final result = await rejectSaleUseCase(event.id, event.note);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (_) => emit(const SaleRejected()),
    );
  }
}
