import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../customers/domain/entities/paginated_result.dart';
import '../entities/device_entity.dart';
import '../../../../core/models/device_filter_model.dart';
import '../repositories/device_repository.dart';

class SearchBackupAssignmentsUseCase {
  final DeviceRepository repository;

  SearchBackupAssignmentsUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<DeviceEntity>>> call({
    bool isReturned = false,
    String? serialNumber,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) async {
    return await repository.searchBackupAssignments(
      isReturned: isReturned,
      serialNumber: serialNumber,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}
