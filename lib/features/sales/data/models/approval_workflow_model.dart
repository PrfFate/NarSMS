import '../../domain/entities/approval_workflow_entity.dart';

class ApprovalWorkflowModel extends ApprovalWorkflowEntity {
  const ApprovalWorkflowModel({
    required super.id,
    required super.name,
    required super.entityType,
    required super.version,
    required super.isActive,
    required super.steps,
  });

  factory ApprovalWorkflowModel.fromJson(Map<String, dynamic> json) {
    return ApprovalWorkflowModel(
      id: json['id'] as int,
      name: json['name'] as String,
      entityType: json['entityType'] as String,
      version: json['version'] as int,
      isActive: json['isActive'] as bool,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => ApprovalStepDefinitionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'entityType': entityType,
      'version': version,
      'isActive': isActive,
      'steps': steps.map((e) => (e as ApprovalStepDefinitionModel).toJson()).toList(),
    };
  }

  ApprovalWorkflowEntity toEntity() => this;
}

class ApprovalStepDefinitionModel extends ApprovalStepDefinitionEntity {
  const ApprovalStepDefinitionModel({
    required super.id,
    required super.stepOrder,
    required super.stepName,
    required super.roleId,
    super.roleName,
  });

  factory ApprovalStepDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ApprovalStepDefinitionModel(
      id: json['id'] as int,
      stepOrder: json['stepOrder'] as int,
      stepName: json['stepName'] as String,
      roleId: json['roleId'] as int,
      roleName: json['roleName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepOrder': stepOrder,
      'stepName': stepName,
      'roleId': roleId,
      'roleName': roleName,
    };
  }
}
