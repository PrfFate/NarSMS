import 'package:equatable/equatable.dart';

abstract class TechnicalServiceEvent extends Equatable {
  const TechnicalServiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadServiceRequests extends TechnicalServiceEvent {
  final int page;
  final int pageSize;
  final String status;

  const LoadServiceRequests({
    this.page = 1,
    this.pageSize = 15,
    required this.status,
  });

  @override
  List<Object?> get props => [page, pageSize, status];
}

class LoadMoreServiceRequests extends TechnicalServiceEvent {
  final int nextPage;
  final int pageSize;
  final String status;
  final List existingRequests;

  const LoadMoreServiceRequests({
    required this.nextPage,
    required this.existingRequests,
    this.pageSize = 15,
    required this.status,
  });

  @override
  List<Object?> get props => [nextPage, pageSize, status];
}

class CreateServiceRequest extends TechnicalServiceEvent {
  final Map<String, dynamic> requestData;

  const CreateServiceRequest(this.requestData);

  @override
  List<Object?> get props => [requestData];
}

class SendToShipment extends TechnicalServiceEvent {
  final int id;
  final int shipmentType;
  final int? carrierId;
  final int? fieldTeamUserId;
  final String? trackingNumber;

  const SendToShipment({
    required this.id, 
    required this.shipmentType,
    this.carrierId,
    this.fieldTeamUserId,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [id, shipmentType, carrierId, fieldTeamUserId, trackingNumber];
}

class LoadShipmentOptions extends TechnicalServiceEvent {}

class ConfirmDelivery extends TechnicalServiceEvent {
  final int shipmentId;

  const ConfirmDelivery({required this.shipmentId});

  @override
  List<Object?> get props => [shipmentId];
}
