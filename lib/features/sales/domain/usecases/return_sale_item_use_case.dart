import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/sale_repository.dart';

class ReturnSaleItemParams {
  final int saleId;
  final int saleItemId;
  final String condition;
  final String? conditionNotes;

  ReturnSaleItemParams({
    required this.saleId,
    required this.saleItemId,
    required this.condition,
    this.conditionNotes,
  });
}

class ReturnSaleItemUseCase {
  final SaleRepository repository;

  ReturnSaleItemUseCase(this.repository);

  Future<Either<Failure, void>> call(ReturnSaleItemParams params) {
    return repository.returnSaleItem(
      saleId: params.saleId,
      saleItemId: params.saleItemId,
      condition: params.condition,
      conditionNotes: params.conditionNotes,
    );
  }
}
