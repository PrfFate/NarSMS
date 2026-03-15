import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/device_repository.dart';

class UpdateDeviceUseCase {
  final DeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, Map<String, dynamic> requestData) async {
    return await repository.updateDevice(id, requestData);
  }
}
