import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/device_filter_model.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class SearchDevicesUseCase {
  final DeviceRepository repository;

  SearchDevicesUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<DeviceEntity>>> call({
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) {
    final hasFilter = filter != null && !filter.isEmpty;

    if (hasFilter) {
      return repository.searchDevicesWithFilters(
        serialNumber: serialNumber,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    }

    return repository.searchDevices(
      serialNumber: serialNumber,
      page: page,
      pageSize: pageSize,
    );
  }
}
