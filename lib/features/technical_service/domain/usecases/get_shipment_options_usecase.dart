import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/technical_service_repository.dart';

class GetShipmentOptionsUseCase {
  final TechnicalServiceRepository repository;

  GetShipmentOptionsUseCase(this.repository);

  Future<Either<Failure, Map<String, List<Map<String, dynamic>>>>> call() async {
    final carriersResult = await repository.getCarriers();
    final fieldersResult = await repository.getFielders();

    return carriersResult.fold(
      (failure) => Left(failure),
      (carriers) => fieldersResult.fold(
        (failure) => Left(failure),
        (fielders) => Right({
          'carriers': carriers,
          'fielders': fielders,
        }),
      ),
    );
  }
}
