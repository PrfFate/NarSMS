import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/sale_repository.dart';

class GetFieldersUseCase {
  final SaleRepository repository;

  GetFieldersUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call() {
    return repository.getFielders();
  }
}
