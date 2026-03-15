import 'package:equatable/equatable.dart';
import 'sale_item_entity.dart';
import 'approval_step_entity.dart';

/// Satış kaydı domain entity'si.
///
/// API'den gelen `sale/search` response'unu temsil eder.
/// Presentation ve Domain katmanlarında kullanılır.
class SaleEntity extends Equatable {
  final int id;
  final String? customerName;
  final double totalAmount;
  final String? saleDate;
  final String? approvalStatus;
  final String? approvalDate;
  final String? approvedByName;
  
  final List<SaleItemEntity>? items;
  final List<ApprovalStepEntity>? approvalHistory;

  const SaleEntity({
    required this.id,
    this.customerName,
    required this.totalAmount,
    this.saleDate,
    this.approvalStatus,
    this.approvalDate,
    this.approvedByName,
    this.items,
    this.approvalHistory,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        totalAmount,
        saleDate,
        approvalStatus,
        approvalDate,
        approvedByName,
        items,
        approvalHistory,
      ];
}
