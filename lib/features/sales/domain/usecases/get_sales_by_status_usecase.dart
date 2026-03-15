import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/customers/domain/entities/paginated_result.dart';
import '../entities/sale_entity.dart';
import '../repositories/sale_repository.dart';

/// Duruma göre sayfalı satış listesini getirir.
///
/// Kullanım:
/// ```dart
/// final result = await useCase(status: 'Pending', page: 1, pageSize: 20);
/// ```
class GetSalesByStatusUseCase {
  final SaleRepository repository;

  GetSalesByStatusUseCase(this.repository);

  Future<Either<Failure, PaginatedResult<SaleEntity>>> call({
    required String status,
    required int page,
    required int pageSize,
  }) {
    return repository.getSalesByStatus(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }
}
