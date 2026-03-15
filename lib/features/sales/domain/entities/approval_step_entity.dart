import 'package:equatable/equatable.dart';

class ApprovalStepEntity extends Equatable {
  final int id;
  final int saleId;
  final int stepOrder;
  final String? approvalType;
  final String? status;
  final String? processedBy;
  final String? processedDate;
  final String? description;

  const ApprovalStepEntity({
    required this.id,
    required this.saleId,
    required this.stepOrder,
    this.approvalType,
    this.status,
    this.processedBy,
    this.processedDate,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        stepOrder,
        approvalType,
        status,
        processedBy,
        processedDate,
        description,
      ];
}
