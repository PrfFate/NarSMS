import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../entities/device_type_entity.dart';
import '../repositories/device_repository.dart';

class GetDeviceTypesPagedUseCase {
  final DeviceRepository repository;

  GetDeviceTypesPagedUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<DeviceTypeEntity>>> call({int page = 1, int pageSize = 15}) {
    return repository.getDeviceTypesPaged(page: page, pageSize: pageSize);
  }
}
