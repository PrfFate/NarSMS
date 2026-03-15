import '../../domain/entities/sale_entity.dart';
import 'sale_item_model.dart';
import 'approval_step_model.dart';

/// API'den gelen satış verisini temsil eder.
class SaleModel {
  final int id;
  final String? customerName;
  final double totalAmount;
  final String? saleDate;
  final String? approvalStatus;
  final String? approvalDate;
  final String? approvedByName;
  
  final List<SaleItemModel>? items;
  final List<ApprovalStepModel>? approvalHistory;

  const SaleModel({
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

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as int? ?? 0,
      customerName: json['customerName'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      saleDate: json['saleDate'] as String?,
      approvalStatus: json['status'] as String?, // status
      approvalDate: json['actualSaleDate'] as String?, // actualSaleDate
      approvedByName: json['createdByUserName'] as String?, // createdByUserName
      items: json['items'] != null
          ? (json['items'] as List).map((i) => SaleItemModel.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      approvalHistory: json['approvals'] != null
          ? (json['approvals'] as List).map((i) => ApprovalStepModel.fromJson(i as Map<String, dynamic>)).toList()
          : null,
    );
  }

  SaleEntity toEntity() => SaleEntity(
        id: id,
        customerName: customerName,
        totalAmount: totalAmount,
        saleDate: saleDate,
        approvalStatus: approvalStatus,
        approvalDate: approvalDate,
        approvedByName: approvedByName,
        items: items?.map((item) => item.toEntity()).toList(),
        approvalHistory: approvalHistory?.map((step) => step.toEntity()).toList(),
      );
}
