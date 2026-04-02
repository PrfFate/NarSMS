import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../entities/service_request_entity.dart';
import '../repositories/technical_service_repository.dart';

class GetServiceRequestsUseCase {
  final TechnicalServiceRepository repository;

  GetServiceRequestsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<ServiceRequestEntity>>> call({
    required int page,
    required int pageSize,
    required String status,
  }) {
    return repository.getServiceRequests(
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }
}
