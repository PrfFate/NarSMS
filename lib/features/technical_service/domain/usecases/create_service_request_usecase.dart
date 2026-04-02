import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/technical_service_repository.dart';

class CreateServiceRequestUseCase {
  final TechnicalServiceRepository repository;

  CreateServiceRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> requestData) {
    return repository.createServiceRequest(requestData);
  }
}
