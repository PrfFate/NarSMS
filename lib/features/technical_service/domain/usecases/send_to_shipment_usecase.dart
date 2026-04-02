import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/technical_service_repository.dart';

class SendToShipmentUseCase {
  final TechnicalServiceRepository repository;

  SendToShipmentUseCase(this.repository);

  Future<Either<Failure, void>> call(
    int id, 
    int shipmentType, {
    int? carrierId, 
    int? fieldTeamUserId, 
    String? trackingNumber,
  }) {
    return repository.sendToShipment(
      id, 
      shipmentType,
      carrierId: carrierId,
      fieldTeamUserId: fieldTeamUserId,
      trackingNumber: trackingNumber,
    );
  }
}
