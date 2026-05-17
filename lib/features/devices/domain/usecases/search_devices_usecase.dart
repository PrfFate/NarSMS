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
    String? status,
    DeviceFilterModel? filter,
    int page = 1,
    int pageSize = 15,
  }) {
    // 1. Teknik/Donanım filtrelerinden (RAM, İşlemci vb.) herhangi biri seçilmiş mi?
    final hasTechnical = filter != null && filter.hasTechnicalFilters;

    if (hasTechnical) {
      // Teknik filtreler varsa 'search-by-multiple-features' kullanılır.
      // Bu endpoint RAM/İşlemci/Ekran/Hafıza/Cihaz Tipi ile birlikte status'u da destekler.
      return repository.searchDevicesWithFilters(
        serialNumber: serialNumber,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    }

    // 2. Teknik filtre yoksa (boş filtre veya sadece status/serial varsa)
    // her zaman normal '/api/Device/search' endpoint'ini kullan.
    // Bu endpoint 'status' ve 'deviceSerialNumber' parametrelerini birlikte destekler.
    return repository.searchDevices(
      serialNumber: serialNumber,
      status: status ?? filter?.status,
      page: page,
      pageSize: pageSize,
    );
  }
}
