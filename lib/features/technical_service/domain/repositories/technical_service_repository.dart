import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../entities/service_request_entity.dart';

abstract class TechnicalServiceRepository {
  Future<Either<Failure, PaginatedResult<ServiceRequestEntity>>> getServiceRequests({
    required int page,
    required int pageSize,
    required String status,
  });

  Future<Either<Failure, void>> createServiceRequest(Map<String, dynamic> requestData);
  Future<Either<Failure, void>> sendToShipment(int id, int shipmentType, {int? carrierId, int? fieldTeamUserId, String? trackingNumber});
  Future<Either<Failure, List<Map<String, dynamic>>>> getCarriers();
  Future<Either<Failure, List<Map<String, dynamic>>>> getFielders();
  Future<Either<Failure, void>> confirmDelivery(int shipmentId);
}
