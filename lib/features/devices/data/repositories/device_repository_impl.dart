import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/device_filter_model.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/device_movement_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_model.dart';
import '../../domain/entities/device_type_entity.dart';
import '../../domain/entities/supplier_entity.dart';
import '../models/device_type_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepositoryImpl({required this.remoteDataSource});

  Map<String, dynamic> _payload(Map<String, dynamic> data) {
    final nested = data['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return data;
  }

  List<dynamic> _itemsFrom(Map<String, dynamic> data) {
    final payload = _payload(data);
    final items = payload['items'] ??
        payload['data'] ??
        payload['results'] ??
        payload['values'];
    if (items is List) return items;
    if (data['items'] is List) return data['items'] as List;
    return const [];
  }

  @override
  Future<Either<Failure, PaginatedResult<DeviceEntity>>> searchDevices({
    String? serialNumber,
    String? status,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final data = await remoteDataSource.searchDevices(
        serialNumber: serialNumber,
        status: status,
        page: page,
        pageSize: pageSize,
      );

      // Tedarikçi listesi ID'leri isimlerle eşleştirmek için alınıyor
      Map<int, String> supplierMap = {};
      try {
        supplierMap = await remoteDataSource.getSuppliersMap();
      } catch (_) {
        // Hata durumunda boş harita ile devam et
      }

      final payload = _payload(data);
      final items = _itemsFrom(data).map((item) {
        var mapItem = item as Map<String, dynamic>;

        // Eğer backend supplierName yollamıyorsa ama ID varsa, ismi map'ten bul
        if (mapItem['supplierName'] == null && mapItem['supplierId'] != null) {
          final sId = mapItem['supplierId'] as int;
          if (supplierMap.containsKey(sId)) {
            // UnmodifiableMap olabileceği için yeni map açıyoruz
            mapItem = Map<String, dynamic>.from(mapItem);
            mapItem['supplierName'] = supplierMap[sId];
          }
        }

        return DeviceModel.fromJson(mapItem);
      }).toList();

      int totalCountVal = payload['totalCount'] as int? ??
          payload['totalItems'] as int? ??
          payload['count'] as int? ??
          items.length;
      int pageVal = payload['page'] as int? ??
          payload['pageNumber'] as int? ??
          payload['currentPage'] as int? ??
          (payload['index'] != null ? (payload['index'] as int) + 1 : page);
      int pageSizeVal =
          payload['pageSize'] as int? ?? payload['size'] as int? ?? pageSize;
      int totalPagesVal = payload['totalPages'] as int? ??
          payload['pageCount'] as int? ??
          payload['pages'] as int? ??
          (totalCountVal / pageSizeVal).ceil();

      final result = PaginatedResult<DeviceEntity>(
        items: items,
        totalCount: totalCountVal,
        page: pageVal,
        pageSize: pageSizeVal,
        totalPages: totalPagesVal,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<DeviceEntity>>>
      searchDevicesWithFilters({
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final data = await remoteDataSource.searchDevicesWithFilters(
        serialNumber: serialNumber,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

      Map<int, String> supplierMap = {};
      try {
        supplierMap = await remoteDataSource.getSuppliersMap();
      } catch (_) {}

      final payload = _payload(data);
      final items = _itemsFrom(data).map((item) {
        var mapItem = item as Map<String, dynamic>;
        if (mapItem['supplierName'] == null && mapItem['supplierId'] != null) {
          final sId = mapItem['supplierId'] as int;
          if (supplierMap.containsKey(sId)) {
            mapItem = Map<String, dynamic>.from(mapItem);
            mapItem['supplierName'] = supplierMap[sId];
          }
        }
        return DeviceModel.fromJson(mapItem);
      }).toList();

      int totalCountVal = payload['totalCount'] as int? ??
          payload['totalItems'] as int? ??
          payload['count'] as int? ??
          items.length;
      int pageVal = payload['page'] as int? ??
          payload['pageNumber'] as int? ??
          payload['currentPage'] as int? ??
          page;
      int pageSizeVal =
          payload['pageSize'] as int? ?? payload['size'] as int? ?? pageSize;
      int totalPagesVal = payload['totalPages'] as int? ??
          payload['pageCount'] as int? ??
          (totalCountVal / pageSizeVal).ceil();

      return Right(PaginatedResult<DeviceEntity>(
        items: items,
        totalCount: totalCountVal,
        page: pageVal,
        pageSize: pageSizeVal,
        totalPages: totalPagesVal,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<DeviceEntity>>>
      searchBackupAssignments({
    bool isReturned = false,
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final data = await remoteDataSource.searchBackupAssignments(
        isReturned: isReturned,
        serialNumber: serialNumber,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

      final items = (data['items'] as List).map((item) {
        return DeviceModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      int totalCountVal = data['totalCount'] as int? ??
          data['totalItems'] as int? ??
          data['count'] as int? ??
          items.length;
      int pageVal = data['page'] as int? ??
          data['pageNumber'] as int? ??
          data['currentPage'] as int? ??
          (data['index'] != null ? (data['index'] as int) + 1 : page);

      return Right(PaginatedResult<DeviceEntity>(
        items: items,
        totalCount: totalCountVal,
        page: pageVal,
        pageSize: pageSize,
        totalPages: (totalCountVal / pageSize).ceil(),
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> assignBackupAssignment(
      int deviceId, Map<String, dynamic> requestData) async {
    try {
      await remoteDataSource.assignBackupAssignment(deviceId, requestData);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> returnBackupAssignment(
      int assignmentId, String? reason) async {
    try {
      await remoteDataSource.returnBackupAssignment(assignmentId, reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createDevice(
      Map<String, dynamic> requestData) async {
    try {
      await remoteDataSource.createDevice(requestData);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bulkCreateDevices(
      Map<String, dynamic> requestData) async {
    try {
      await remoteDataSource.bulkCreateDevices(requestData);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDevice(
      int id, Map<String, dynamic> requestData) async {
    try {
      await remoteDataSource.updateDevice(id, requestData);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDevice(int id) async {
    try {
      await remoteDataSource.deleteDevice(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDeviceTypes() async {
    try {
      final types = await remoteDataSource.getDeviceTypes();
      return Right(types);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<DeviceTypeEntity>>>
      getDeviceTypesPaged({int page = 1, int pageSize = 15}) async {
    try {
      final data = await remoteDataSource.getDeviceTypesPaged(
          page: page, pageSize: pageSize);

      final items = (data['items'] as List?)
              ?.map((item) => DeviceTypeModel.fromJson(item))
              .toList() ??
          [];

      int totalCountVal = data['totalCount'] as int? ??
          data['totalItems'] as int? ??
          data['count'] as int? ??
          items.length;
      int pageVal = data['page'] as int? ??
          data['pageNumber'] as int? ??
          data['currentPage'] as int? ??
          (data['index'] != null ? (data['index'] as int) + 1 : page);
      int pageSizeVal =
          data['pageSize'] as int? ?? data['size'] as int? ?? pageSize;
      int totalPagesVal = data['totalPages'] as int? ??
          data['pageCount'] as int? ??
          data['pages'] as int? ??
          (totalCountVal / pageSizeVal).ceil();

      final result = PaginatedResult<DeviceTypeEntity>(
        items: items,
        totalCount: totalCountVal,
        page: pageVal,
        pageSize: pageSizeVal,
        totalPages: totalPagesVal,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createDeviceTypeEntity(String name) async {
    try {
      await remoteDataSource.createDeviceTypeEntity(name);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeviceTypeEntity(
      int id, String name) async {
    try {
      await remoteDataSource.updateDeviceTypeEntity(id, name);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeviceTypeEntity(int id) async {
    try {
      await remoteDataSource.deleteDeviceTypeEntity(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSuppliers() async {
    try {
      final suppliers = await remoteDataSource.getSuppliers();
      return Right(suppliers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliersData() async {
    try {
      final suppliers = await remoteDataSource.getSuppliersData();
      return Right(suppliers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSupplier(
      Map<String, dynamic> data) async {
    try {
      await remoteDataSource.createSupplier(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplier(
      int id, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateSupplier(id, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(int id) async {
    try {
      await remoteDataSource.deleteSupplier(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceMovementEntity>>> getDeviceMovements(
      int deviceId) async {
    try {
      final movements = await remoteDataSource.getDeviceMovements(deviceId);
      return Right(movements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
