import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/widgets/generic_confirmation_dialog.dart';
import '../../../../config/routes/app_router.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_item_entity.dart';
import '../../domain/entities/approval_step_entity.dart';
import 'package:tasarim_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tasarim_app/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../../../core/widgets/device_image_widget.dart';

class SaleDetailPage extends StatefulWidget {
  final SaleEntity sale;

  const SaleDetailPage({super.key, required this.sale});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _openShipmentDialog(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context, 
      AppRouter.saleShip, 
      arguments: widget.sale
    );

    if (result == true) {
      // Kargo oluşturulduysa sayfayı kapat ve listeyi yenile
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _handleApprove(BuildContext context) {
    GenericConfirmationDialog.show(
      context: context,
      title: 'Satışı Onayla',
      message: 'Bu satışı onaylamak istediğinize emin misiniz?',
      itemName: 'Fiş #${widget.sale.id}',
      confirmLabel: 'Onayla',
      onConfirm: () {
        context.read<SaleBloc>().add(ApproveSale(widget.sale.id));
      },
    );
  }

  void _handleReject(BuildContext context) {
    _noteController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Satışı Reddet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Satışı reddetme nedeninizi belirtebilirsiniz:'),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Red Nedeni (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SaleBloc>().add(RejectSale(widget.sale.id,
                  note: _noteController.text.trim()));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reddet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ... (existing builder methods)

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: child,
    );
  }

  Widget _buildCardTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _buildSaleItemsList(List<SaleItemEntity>? items) {
    if (items == null || items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text('Kayıtlı satış kalemi bulunamadı.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DeviceImageWidget(
                deviceTypeName: item.modelName,
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.modelName ?? 'Bilinmeyen Model',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.navy),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seri No: ${item.serialNumber ?? '-'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.price.toStringAsFixed(2)} \$',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.navy),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApprovalHistoryList(List<ApprovalStepEntity>? history) {
    if (history == null || history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text('Onay geçmişi bulunamadı.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: history.map((step) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borderLight),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step.stepOrder.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey[700]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.approvalType ?? 'Onay Adımı',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.navy),
                    ),
                    if (step.status?.toLowerCase() != 'pending') ...[
                      const SizedBox(height: 4),
                      Text(
                        'İşlem Yapan: ${step.processedBy ?? '-'}   |   Tarih: ${_fmtDate(step.processedDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    if (step.description != null &&
                        step.description!.isNotEmpty &&
                        step.description != '-') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Açıklama: ${step.description}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(step.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _translateStatus(step.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(step.status),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _translateStatus(String? status) {
    if (status == null) return 'Bilinmiyor';
    final lower = status.toLowerCase();
    if (lower.contains('pending')) return 'Bekleniyor';
    if (lower.contains('approved')) return 'Onaylandı';
    if (lower.contains('rejected')) return 'Reddedildi';
    return status;
  }

  String _fmtDate(String? raw) {
    if (raw == null) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final lower = status.toLowerCase();
    if (lower.contains('onaylandı') || lower.contains('approved'))
      return Colors.green;
    if (lower.contains('red') || lower.contains('rejected')) return Colors.red;
    return AppColors.primary; // Bekliyor / Pending
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String? userRoleName;
    if (authState is AuthAuthenticated) {
      userRoleName = authState.user.roleName;
    }

    final bool canShip =
        widget.sale.approvalStatus?.toLowerCase() == 'approved' ||
            widget.sale.approvalStatus?.toLowerCase() == 'partiallyshipped';

    final bool isPending =
        widget.sale.approvalStatus?.toLowerCase() == 'pending';

    // Kullanıcının şu anki adımda onay yetkisi var mı?
    bool canApproveOrReject = false;
    if (isPending &&
        userRoleName != null &&
        widget.sale.approvalHistory != null) {
      // Bekleyen ilk adımı bul (İngilizce veya Türkçe durumları kontrol et)
      final pendingStep = widget.sale.approvalHistory!.firstWhere(
        (step) {
          final s = step.status?.toLowerCase() ?? '';
          return s == 'pending' || s == 'bekleniyor' || s == 'bekliyor';
        },
        orElse: () => const ApprovalStepEntity(id: 0, saleId: 0, stepOrder: 0),
      );

      // Eğer bekleyen bir adım varsa
      if (pendingStep.stepOrder != 0) {
        final stepRole = pendingStep.approvalType?.toLowerCase().trim();
        final userRole = userRoleName.trim().toLowerCase();

        // Admin ise her zaman onaylayabilir, veya adımın rolü kullanıcıyla eşleşiyorsa
        if (userRole == 'admin' || userRole == 'administrator' || userRole == stepRole) {
          canApproveOrReject = true;
        }
      }
    }

    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is SaleApproved || state is SaleRejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is SaleApproved
                  ? 'Satış onaylandı'
                  : 'Satış reddedildi'),
              backgroundColor:
                  state is SaleApproved ? Colors.green : Colors.red,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: CustomFormScaffold(
        title: 'Satış Detayı',
        isLoading: context.watch<SaleBloc>().state is SaleLoading,
        bottomButtonText: canShip ? 'Kargola' : null,
        onBottomButtonPressed:
            canShip ? () => _openShipmentDialog(context) : null,
        bottomWidget: canApproveOrReject
            ? Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => _handleReject(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reddet',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _handleApprove(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Onayla',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardTitle('Satış Kalemleri'),
                    _buildSaleItemsList(widget.sale.items),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardTitle('Onay Geçmişi'),
                    _buildApprovalHistoryList(widget.sale.approvalHistory),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
