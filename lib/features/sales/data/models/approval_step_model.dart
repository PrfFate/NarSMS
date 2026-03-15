import '../../domain/entities/approval_step_entity.dart';

class ApprovalStepModel extends ApprovalStepEntity {
  const ApprovalStepModel({
    required super.id,
    required super.saleId,
    required super.stepOrder,
    super.approvalType,
    super.status,
    super.processedBy,
    super.processedDate,
    super.description,
  });

  factory ApprovalStepModel.fromJson(Map<String, dynamic> json) {
    return ApprovalStepModel(
      id: json['id'] as int? ?? 0,
      saleId: json['saleId'] as int? ?? 0,
      stepOrder: json['stepOrder'] as int? ?? 0,
      approvalType: json['stepName'] as String?,
      status: json['status'] as String?,
      processedBy: json['reviewedByUserName'] as String?,
      processedDate: json['reviewedDate'] as String?,
      description: json['notes'] as String?,
    );
  }

  ApprovalStepEntity toEntity() => ApprovalStepEntity(
        id: id,
        saleId: saleId,
        stepOrder: stepOrder,
        approvalType: approvalType,
        status: status,
        processedBy: processedBy,
        processedDate: processedDate,
        description: description,
      );
}
