import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class CreateDeviceUseCase {
  final DeviceRepository repository;

  CreateDeviceUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> requestData) {
    return repository.createDevice(requestData);
  }
}
