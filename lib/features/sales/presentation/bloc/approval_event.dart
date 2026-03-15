import 'package:equatable/equatable.dart';

abstract class ApprovalEvent extends Equatable {
  const ApprovalEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkflows extends ApprovalEvent {}

class LoadRoles extends ApprovalEvent {}

class UpdateWorkflowVersion extends ApprovalEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateWorkflowVersion(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class CreateWorkflow extends ApprovalEvent {
  final Map<String, dynamic> data;
  const CreateWorkflow(this.data);
  @override
  List<Object?> get props => [data];
}

class DeleteWorkflow extends ApprovalEvent {
  final int id;
  const DeleteWorkflow(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleWorkflowStatus extends ApprovalEvent {
  final int id;
  final bool isActive;
  const ToggleWorkflowStatus(this.id, this.isActive);
  @override
  List<Object?> get props => [id, isActive];
}
