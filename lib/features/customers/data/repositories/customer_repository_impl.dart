import 'package:dartz/dartz.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';
import '../models/create_customer_request_model.dart';
import '../models/update_customer_request_model.dart';

/// [CustomerRepository] implementasyonu.
///
/// [BaseRepository]'den türetilir; ağ kontrolü ve exception→failure
/// dönüşümü [runNetworkCall] ile merkezi olarak yönetilir.
/// Bu sınıf yalnızca Customer'a özgü veri dönüşüm mantığını içerir.
class CustomerRepositoryImpl extends BaseRepository
    implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required super.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> getCustomersPaged({
    int page = 1,
    int pageSize = 15,
  }) {
    return runNetworkCall(() async {
      final response = await remoteDataSource.getCustomersPaged(
        page: page,
        pageSize: pageSize,
      );
      return _parsePaginatedResponse(response);
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> searchCustomers({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
    int page = 1,
    int pageSize = 15,
  }) {
    return runNetworkCall(() async {
      final response = await remoteDataSource.searchCustomers(
        name: name,
        email: email,
        phone: phone,
        address: address,
        uniqueId: uniqueId,
        page: page,
        pageSize: pageSize,
      );
      return _parsePaginatedResponse(response);
    });
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(int id) {
    return runNetworkCall(() async {
      final model = await remoteDataSource.getCustomerById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerByUniqueId(
    String uniqueId,
  ) {
    return runNetworkCall(() async {
      final model = await remoteDataSource.getCustomerByUniqueId(uniqueId);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<dynamic>>> getCustomerDevices(int id) {
    return runNetworkCall(() => remoteDataSource.getCustomerDevices(id));
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  }) {
    return runNetworkCall(() async {
      final request = CreateCustomerRequestModel(
        name: name,
        email: email,
        phone: phone,
        address: address,
        uniqueId: uniqueId,
      );
      final model = await remoteDataSource.createCustomer(request);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> updateCustomer({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? uniqueId,
  }) {
    return runNetworkCall(() async {
      final request = UpdateCustomerRequestModel(
        name: name,
        email: email,
        phone: phone,
        address: address,
        uniqueId: uniqueId,
      );
      await remoteDataSource.updateCustomer(id, request);
    });
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(int id) {
    return runNetworkCall(() => remoteDataSource.deleteCustomer(id));
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  /// Ham JSON yanıtı [PaginatedResult<CustomerEntity>] nesnesine dönüştürür.
  PaginatedResult<CustomerEntity> _parsePaginatedResponse(
    Map<String, dynamic> response,
  ) {
    final items = (response['items'] as List<dynamic>?)
            ?.map(
              (item) => CustomerModel.fromJson(item as Map<String, dynamic>)
                  .toEntity(),
            )
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
