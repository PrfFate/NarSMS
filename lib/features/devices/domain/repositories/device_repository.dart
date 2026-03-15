import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/device_filter_model.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../entities/device_entity.dart';
import '../entities/device_type_entity.dart';
import '../entities/device_movement_entity.dart';
import '../entities/supplier_entity.dart';

abstract class DeviceRepository {
  Future<Either<Failure, PaginatedResult<DeviceEntity>>> searchDevices({
    String? serialNumber,
    int page = 1,
    int pageSize = 15,
  });

  Future<Either<Failure, PaginatedResult<DeviceEntity>>> searchDevicesWithFilters({
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  });

  Future<Either<Failure, void>> createDevice(Map<String, dynamic> requestData);
  Future<Either<Failure, void>> bulkCreateDevices(Map<String, dynamic> requestData);
  Future<Either<Failure, void>> updateDevice(int id, Map<String, dynamic> requestData);
  Future<Either<Failure, void>> deleteDevice(int id);
  Future<Either<Failure, List<String>>> getDeviceTypes();
  Future<Either<Failure, PaginatedResult<DeviceTypeEntity>>> getDeviceTypesPaged({int page = 1, int pageSize = 15});
  Future<Either<Failure, void>> createDeviceTypeEntity(String name);
  Future<Either<Failure, void>> updateDeviceTypeEntity(int id, String name);
  Future<Either<Failure, void>> deleteDeviceTypeEntity(int id);
  Future<Either<Failure, List<String>>> getSuppliers();
  Future<Either<Failure, List<SupplierEntity>>> getSuppliersData();
  Future<Either<Failure, void>> createSupplier(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateSupplier(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteSupplier(int id);
  Future<Either<Failure, List<DeviceMovementEntity>>> getDeviceMovements(int deviceId);
}
