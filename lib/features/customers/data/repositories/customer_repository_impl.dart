import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';
import '../models/create_customer_request_model.dart';
import '../models/update_customer_request_model.dart';

/// Implementation of [CustomerRepository].
/// Acts as a bridge between domain and data layers.
/// Handles Exception → Failure conversion and network checks.
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedResult<CustomerEntity>>>
      getCustomersPaged({
    int page = 1,
    int pageSize = 15,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final response = await remoteDataSource.getCustomersPaged(
        page: page,
        pageSize: pageSize,
      );

      return Right(_parsePaginatedResponse(response));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<CustomerEntity>>>
      searchCustomers({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final response = await remoteDataSource.searchCustomers(
        name: name,
        email: email,
        phone: phone,
        address: address,
        uniqueId: uniqueId,
        page: page,
        pageSize: pageSize,
      );

      return Right(_parsePaginatedResponse(response));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final model = await remoteDataSource.getCustomerById(id);
      return Right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerByUniqueId(
      String uniqueId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final model = await remoteDataSource.getCustomerByUniqueId(uniqueId);
      return Right(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getCustomerDevices(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final devices = await remoteDataSource.getCustomerDevices(id);
      return Right(devices);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final request = CreateCustomerRequestModel(
        name: name,
        email: email,
        phone: phone,
        address: address,
        uniqueId: uniqueId,
      );

      final model = await remoteDataSource.createCustomer(request);
      return Right(model.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      final request = UpdateCustomerRequestModel(
        name: name,
        email: email,
        phone: phone,
        address: address,
        uniqueId: uniqueId,
      );

      await remoteDataSource.updateCustomer(id, request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('İnternet bağlantısı yok'));
    }

    try {
      await remoteDataSource.deleteCustomer(id);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: ${e.toString()}'));
    }
  }

  /// Parses raw JSON response into a [PaginatedResult<CustomerEntity>].
  PaginatedResult<CustomerEntity> _parsePaginatedResponse(
      Map<String, dynamic> response) {
    final items = (response['items'] as List<dynamic>?)
            ?.map((item) =>
                CustomerModel.fromJson(item as Map<String, dynamic>)
                    .toEntity())
            .toList() ??
        [];

    return PaginatedResult<CustomerEntity>(
      items: items,
      totalCount: response['totalCount'] as int? ?? 0,
      page: response['page'] as int? ?? 1,
      pageSize: response['pageSize'] as int? ?? 15,
      totalPages: response['totalPages'] as int? ?? 1,
    );
  }
}
