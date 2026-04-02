import 'package:equatable/equatable.dart';
import '../../domain/entities/service_request_entity.dart';

abstract class TechnicalServiceState extends Equatable {
  const TechnicalServiceState();

  @override
  List<Object?> get props => [];
}

class TechnicalServiceInitial extends TechnicalServiceState {}

class TechnicalServiceLoading extends TechnicalServiceState {}

class TechnicalServiceLoaded extends TechnicalServiceState {
  final List<ServiceRequestEntity> requests;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String status;

  const TechnicalServiceLoaded({
    required this.requests,
    required this.totalCount,
    required this.hasMore,
    this.isLoadingMore = false,
    required this.status,
  });

  TechnicalServiceLoaded copyWith({
    List<ServiceRequestEntity>? requests,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    String? status,
  }) {
    return TechnicalServiceLoaded(
      requests: requests ?? this.requests,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [requests, totalCount, hasMore, isLoadingMore, status];
}

class TechnicalServiceError extends TechnicalServiceState {
  final String message;

  const TechnicalServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

class TechnicalServiceActionSuccess extends TechnicalServiceState {
  final String message;

  const TechnicalServiceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TechnicalServiceCreateSuccess extends TechnicalServiceState {}

class TechnicalServiceShipmentSuccess extends TechnicalServiceState {}

class ShipmentOptionsLoaded extends TechnicalServiceState {
  final List<Map<String, dynamic>> carriers;
  final List<Map<String, dynamic>> fielders;

  const ShipmentOptionsLoaded({required this.carriers, required this.fielders});

  @override
  List<Object?> get props => [carriers, fielders];
}
