import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_movement_entity.dart';
import '../repositories/device_repository.dart';

class GetDeviceMovementsUseCase {
  final DeviceRepository repository;

  GetDeviceMovementsUseCase(this.repository);

  Future<Either<Failure, List<DeviceMovementEntity>>> call(int deviceId) async {
    return await repository.getDeviceMovements(deviceId);
  }
}
