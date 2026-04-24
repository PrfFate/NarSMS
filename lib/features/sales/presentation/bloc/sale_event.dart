import 'package:equatable/equatable.dart';

import '../../data/models/shipment_create_request.dart';
import '../../data/models/sale_create_request.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Duruma göre filtrelenmiş satışları yükler.
class LoadSalesByStatus extends SaleEvent {
  final String status;
  final int page;
  final int pageSize;
  final String? customerName;

  const LoadSalesByStatus({
    required this.status,
    this.page = 1,
    this.pageSize = 20,
    this.customerName,
  });

  @override
  List<Object?> get props => [status, page, pageSize, customerName];
}

/// Sonsuz kaydırma için bir sonraki sayfayı mevcut listeye ekler.
class LoadMoreSalesByStatus extends SaleEvent {
  final String status;
  final int nextPage;
  final List<dynamic> existingSales;
  final int pageSize;
  final String? customerName;

  const LoadMoreSalesByStatus({
    required this.status,
    required this.nextPage,
    required this.existingSales,
    this.pageSize = 20,
    this.customerName,
  });

  @override
  List<Object?> get props => [status, nextPage, existingSales, pageSize, customerName];
}

/// Satışa ait kargo detayını yükler.
class LoadShipmentDetail extends SaleEvent {
  final int saleId;

  const LoadShipmentDetail(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Kargo oluşturma formundaki seçenekleri (firmalar/sahacılar) yükler.
class LoadShipmentOptions extends SaleEvent {
  final int? saleId;
  const LoadShipmentOptions({this.saleId});

  @override
  List<Object?> get props => [saleId];
}

/// Yeni bir kargo oluşturur.
class CreateShipment extends SaleEvent {
  final ShipmentCreateRequest request;

  const CreateShipment(this.request);

  @override
  List<Object?> get props => [request];
}

/// Kargo teslimatını onaylar.
class MarkShipmentDelivered extends SaleEvent {
  final int shipmentId;
  const MarkShipmentDelivered(this.shipmentId);
  @override
  List<Object?> get props => [shipmentId];
}

class ApproveSale extends SaleEvent {
  final int id;
  final String? note;
  const ApproveSale(this.id, {this.note});
  @override
  List<Object?> get props => [id, note];
}

class RejectSale extends SaleEvent {
  final int id;
  final String? note;
  const RejectSale(this.id, {this.note});
  @override
  List<Object?> get props => [id, note];
}

class CreateSale extends SaleEvent {
  final SaleCreateRequest request;
  const CreateSale(this.request);
  @override
  List<Object?> get props => [request];
}

class ReturnSaleItem extends SaleEvent {
  final int saleId;
  final int saleItemId;
  final String condition;
  final String? conditionNotes;

  const ReturnSaleItem({
    required this.saleId,
    required this.saleItemId,
    required this.condition,
    this.conditionNotes,
  });

  @override
  List<Object?> get props => [saleId, saleItemId, condition, conditionNotes];
}
