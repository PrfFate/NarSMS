import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class DeleteDeviceUseCase {
  final DeviceRepository repository;

  DeleteDeviceUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteDevice(id);
  }
}
