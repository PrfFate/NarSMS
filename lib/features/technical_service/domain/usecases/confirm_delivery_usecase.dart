import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/technical_service_repository.dart';

class ConfirmDeliveryUseCase {
  final TechnicalServiceRepository repository;

  ConfirmDeliveryUseCase(this.repository);

  Future<Either<Failure, void>> call(int shipmentId) async {
    return await repository.confirmDelivery(shipmentId);
  }
}
