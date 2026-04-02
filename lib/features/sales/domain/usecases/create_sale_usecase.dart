import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/sale_create_request.dart';
import '../repositories/sale_repository.dart';

class CreateSaleUseCase {
  final SaleRepository repository;
  CreateSaleUseCase(this.repository);

  Future<Either<Failure, void>> call(SaleCreateRequest request) {
    return repository.createSale(request);
  }
}
