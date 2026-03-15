import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/approval_workflow_entity.dart';

abstract class ApprovalRepository {
  Future<Either<Failure, List<ApprovalWorkflowEntity>>> getWorkflows();
  Future<Either<Failure, ApprovalWorkflowEntity>> getWorkflowById(int id);
  Future<Either<Failure, void>> createWorkflow(Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteWorkflow(int id);
  Future<Either<Failure, void>> activateWorkflow(int id);
  Future<Either<Failure, void>> deactivateWorkflow(int id);
  Future<Either<Failure, void>> updateWorkflowVersion(
      int id, Map<String, dynamic> data);
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoles();
}
