import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sale_repository.dart';

class ApproveSaleUseCase {
  final SaleRepository repository;
  ApproveSaleUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, String? note) {
    return repository.approveSale(id, note);
  }
}

class RejectSaleUseCase {
  final SaleRepository repository;
  RejectSaleUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, String? note) {
    return repository.rejectSale(id, note);
  }
}
