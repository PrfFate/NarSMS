import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/entities/warranty_entity.dart';
import '../../domain/repositories/sale_repository.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../../../core/widgets/generic_confirmation_dialog.dart';
import '../../../../core/widgets/device_image_widget.dart';

class ShippedSaleDetailPage extends StatefulWidget {
  final SaleEntity sale;

  const ShippedSaleDetailPage({super.key, required this.sale});

  @override
  State<ShippedSaleDetailPage> createState() => _ShippedSaleDetailPageState();
}

class _ShippedSaleDetailPageState extends State<ShippedSaleDetailPage> {
  bool _isLoading = true;
  List<ShipmentEntity> _shipments = [];
  final Map<int, WarrantyEntity?> _warranties = {};

  @override
  void initState() {
    super.initState();
    _loadExtraData();
  }

  Future<void> _loadExtraData() async {
    setState(() => _isLoading = true);
    final repo = getIt<SaleRepository>();

    // 1. Kargo Detayını Çek
    final shipmentRes = await repo.getShipmentBySaleId(widget.sale.id);
    shipmentRes.fold(
      (l) => debugPrint('Kargo bilgisi çekilemedi: ${l.message}'),
      (r) => setState(() => _shipments = r),
    );

    // 2. Her bir cihaz için Garanti Bilgisini Çek
    if (widget.sale.items != null) {
      for (final item in widget.sale.items!) {
        if (item.deviceId != null) {
          final warrantyRes =
              await repo.getDeviceActiveWarranty(item.deviceId!);
          warrantyRes.fold(
            (l) => debugPrint('Garanti çekilemedi: ${l.message}'),
            (r) {
              if (mounted) {
                setState(() {
                  _warranties[item.deviceId!] = r;
                });
              }
            },
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openShipmentDialog(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context, 
      AppRouter.saleShip, 
      arguments: widget.sale
    );

    if (result == true) {
      // Yenile
      _loadExtraData();
    }
  }

  void _confirmDelivery(ShipmentEntity shipment) {
    GenericConfirmationDialog.show(
      context: context,
      title: 'Teslimat Onayı',
      message: 'Takip numaralı ürünün teslim edildiğini',
      itemName: shipment.trackingNumber ?? 'Kargo',
      confirmLabel: 'Evet, Onayla',
      onConfirm: () {
        context.read<SaleBloc>().add(MarkShipmentDelivered(shipment.id));
      },
    );
  }

  String _fmtDateStr(String? raw) {
    if (raw == null) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _translateStatus(String? status) {
    if (status == null) return '-';
    final lower = status.toLowerCase();
    if (lower.contains('pending')) return 'Bekleniyor';
    if (lower.contains('approved')) return 'Onaylandı';
    if (lower.contains('rejected')) return 'Reddedildi';
    return status;
  }

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

  Widget _infoRow(IconData icon, String label, String value,
      {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navy,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKargoDetaylari(ShipmentEntity s) {
    // Cihaz Bilgisi: Kargo kalemlerinden al
    String cihazBilgisi = '-';
    if (s.items.isNotEmpty) {
      cihazBilgisi = s.items
          .map((e) => '${e.deviceModel} (${e.deviceSerialNumber})')
          .join(', ');
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardTitle('Kargo Detayları'),
          _infoRow(Icons.computer, 'Cihaz Bilgisi', cihazBilgisi),
          _infoRow(Icons.calendar_today_outlined, 'Kargo Tarihi',
              _fmtDateStr(s.shipmentDate)),
          _infoRow(Icons.flag_outlined, 'Durum', s.statusText ?? '-'),
          _infoRow(Icons.tag, 'Takip Numarası', s.trackingNumber ?? '-'),
          _infoRow(
            Icons.local_shipping_outlined,
            'Kargo Firması',
            s.carrierName ?? (s.fieldTeamUserName != null ? 'Saha ekibi' : '-'),
          ),
          if (s.fieldTeamUserName != null)
            _infoRow(Icons.person_outline, 'Saha Ekibi', s.fieldTeamUserName!),
          if (s.completedDate != null)
            _infoRow(Icons.check_circle_outline, 'Tamamlanma Tarihi',
                _fmtDateStr(s.completedDate)),
        ],
      ),
    );
  }

  Widget _buildSaleItemsList() {
    final items = widget.sale.items ?? [];
    if (items.isEmpty) {
      return const Text('Kayıtlı satış kalemi bulunamadı.',
          style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: items.map((item) {
        final w = _warranties[item.deviceId];
        String warrantyStatus = '-';
        if (w != null && w.isActive) {
          warrantyStatus = '✓ Garantili (${w.remainingDays ?? 0} gün kaldı)';
        } else if (w != null) {
          warrantyStatus = 'Garantisiz';
        }

        String warrantyDur = '-';
        if (w != null) {
          warrantyDur =
              '${_fmtDateStr(w.startDate)} - ${_fmtDateStr(w.endDate)} (${w.durationMonths} ay)';
        }

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
                    if (w != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Garanti: $warrantyStatus',
                        style: TextStyle(
                            fontSize: 12,
                            color: (w.isActive ? Colors.green : Colors.red),
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Süre: $warrantyDur',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ]
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

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final lower = status.toLowerCase();
    if (lower.contains('onaylandı') || lower.contains('approved')) {
      return Colors.green;
    }
    if (lower.contains('red') || lower.contains('rejected')) return Colors.red;
    return AppColors.primary; // Bekliyor / Pending
  }

  Widget _buildApprovalHistoryList() {
    final history = widget.sale.approvalHistory ?? [];
    if (history.isEmpty) {
      return const Text('Onay geçmişi bulunamadı.',
          style: TextStyle(color: Colors.grey));
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
                        'İşlem Yapan: ${step.processedBy ?? '-'}   |   Tarih: ${_fmtDateStr(step.processedDate)}',
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CustomFormScaffold(
        title: 'Kargo Detayı',
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final bool canShip =
        widget.sale.approvalStatus?.toLowerCase() == 'approved' ||
            widget.sale.approvalStatus?.toLowerCase() == 'partiallyshipped';

    final bool canConfirmDelivery = _shipments.any((s) =>
        s.statusText?.toLowerCase() != 'delivered' &&
        s.statusText?.toLowerCase() != 'teslim edildi');

    final undeliveredShipment = _shipments
        .where((s) =>
            s.statusText?.toLowerCase() != 'delivered' &&
            s.statusText?.toLowerCase() != 'teslim edildi')
        .firstOrNull;

    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is ShipmentCreated) {
          // Yeni kargo oluşturulduğunda sayfayı yenile
          _loadExtraData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Kargo başarıyla oluşturuldu.'),
                backgroundColor: Colors.green),
          );
        } else if (state is ShipmentDelivered) {
          // Teslimat onaylandığında sayfayı kapat ve listeyi yenile
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Teslimat onaylandı.'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: CustomFormScaffold(
        title: 'Kargo Detayı',
        isLoading: context.watch<SaleBloc>().state is SaleLoading,
        bottomButtonText: canShip
            ? 'Kargola'
            : (canConfirmDelivery ? 'Teslimatı Onayla' : null),
        onBottomButtonPressed: canShip
            ? () => _openShipmentDialog(context)
            : (canConfirmDelivery && undeliveredShipment != null
                ? () => _confirmDelivery(undeliveredShipment)
                : null),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding azaltıldı
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardTitle('Satış Kalemleri'),
                    _buildSaleItemsList(),
                  ],
                ),
              ),
              if (_shipments.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildCard(
                      child: const Text('Kargo detayı bulunamadı.',
                          style: TextStyle(color: Colors.grey))),
                ),
              ..._shipments.map((s) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildKargoDetaylari(s),
                  )),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardTitle('Onay Geçmişi'),
                    _buildApprovalHistoryList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
