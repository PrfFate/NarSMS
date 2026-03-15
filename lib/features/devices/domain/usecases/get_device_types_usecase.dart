import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class GetDeviceTypesUseCase {
  final DeviceRepository repository;

  GetDeviceTypesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getDeviceTypes();
  }
}
