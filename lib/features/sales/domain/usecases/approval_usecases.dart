import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/approval_workflow_entity.dart';
import '../repositories/approval_repository.dart';

class GetWorkflowsUseCase {
  final ApprovalRepository repository;
  GetWorkflowsUseCase(this.repository);

  Future<Either<Failure, List<ApprovalWorkflowEntity>>> call() {
    return repository.getWorkflows();
  }
}

class GetWorkflowByIdUseCase {
  final ApprovalRepository repository;
  GetWorkflowByIdUseCase(this.repository);

  Future<Either<Failure, ApprovalWorkflowEntity>> call(int id) {
    return repository.getWorkflowById(id);
  }
}

class CreateWorkflowUseCase {
  final ApprovalRepository repository;
  CreateWorkflowUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> data) {
    return repository.createWorkflow(data);
  }
}

class DeleteWorkflowUseCase {
  final ApprovalRepository repository;
  DeleteWorkflowUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteWorkflow(id);
  }
}

class ActivateWorkflowUseCase {
  final ApprovalRepository repository;
  ActivateWorkflowUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.activateWorkflow(id);
  }
}

class DeactivateWorkflowUseCase {
  final ApprovalRepository repository;
  DeactivateWorkflowUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deactivateWorkflow(id);
  }
}

class UpdateWorkflowVersionUseCase {
  final ApprovalRepository repository;
  UpdateWorkflowVersionUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, Map<String, dynamic> data) {
    return repository.updateWorkflowVersion(id, data);
  }
}

class GetRolesUseCase {
  final ApprovalRepository repository;
  GetRolesUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return repository.getRoles();
  }
}
