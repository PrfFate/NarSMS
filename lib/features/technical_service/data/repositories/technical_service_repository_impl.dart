import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../../domain/entities/service_request_entity.dart';
import '../../domain/repositories/technical_service_repository.dart';
import '../datasources/technical_service_remote_datasource.dart';

class TechnicalServiceRepositoryImpl implements TechnicalServiceRepository {
  final TechnicalServiceRemoteDataSource remoteDataSource;

  TechnicalServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResult<ServiceRequestEntity>>> getServiceRequests({
    required int page,
    required int pageSize,
    required String status,
  }) async {
    try {
      final result = await remoteDataSource.getServiceRequests(
        page: page,
        pageSize: pageSize,
        status: status,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createServiceRequest(Map<String, dynamic> requestData) async {
    try {
      await remoteDataSource.createServiceRequest(requestData);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendToShipment(
    int id, 
    int shipmentType, {
    int? carrierId, 
    int? fieldTeamUserId, 
    String? trackingNumber,
  }) async {
    try {
      await remoteDataSource.sendToShipment(
        id, 
        shipmentType,
        carrierId: carrierId,
        fieldTeamUserId: fieldTeamUserId,
        trackingNumber: trackingNumber,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCarriers() async {
    try {
      final result = await remoteDataSource.getCarriers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFielders() async {
    try {
      final result = await remoteDataSource.getFielders();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmDelivery(int shipmentId) async {
    try {
      await remoteDataSource.confirmDelivery(shipmentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
