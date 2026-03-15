import 'package:equatable/equatable.dart';

class ApprovalWorkflowEntity extends Equatable {
  final int id;
  final String name;
  final String entityType;
  final int version;
  final bool isActive;
  final List<ApprovalStepDefinitionEntity> steps;

  const ApprovalWorkflowEntity({
    required this.id,
    required this.name,
    required this.entityType,
    required this.version,
    required this.isActive,
    required this.steps,
  });

  @override
  List<Object?> get props => [id, name, entityType, version, isActive, steps];
}

class ApprovalStepDefinitionEntity extends Equatable {
  final int id;
  final int stepOrder;
  final String stepName;
  final int roleId;
  final String? roleName;

  const ApprovalStepDefinitionEntity({
    required this.id,
    required this.stepOrder,
    required this.stepName,
    required this.roleId,
    this.roleName,
  });

  @override
  List<Object?> get props => [id, stepOrder, stepName, roleId, roleName];
}
