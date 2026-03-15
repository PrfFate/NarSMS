import 'package:equatable/equatable.dart';
import 'package:tasarim_app/features/sales/domain/entities/approval_workflow_entity.dart';

abstract class ApprovalState extends Equatable {
  const ApprovalState();
  @override
  List<Object?> get props => [];
}

class ApprovalInitial extends ApprovalState {}

class ApprovalLoading extends ApprovalState {}

class WorkflowsLoaded extends ApprovalState {
  final List<ApprovalWorkflowEntity> workflows;
  const WorkflowsLoaded(this.workflows);
  @override
  List<Object?> get props => [workflows];
}

class RolesLoaded extends ApprovalState {
  final List<Map<String, dynamic>> roles;
  const RolesLoaded(this.roles);
  @override
  List<Object?> get props => [roles];
}

class ApprovalSuccess extends ApprovalState {
  final String message;
  const ApprovalSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ApprovalError extends ApprovalState {
  final String message;
  const ApprovalError(this.message);
  @override
  List<Object?> get props => [message];
}
