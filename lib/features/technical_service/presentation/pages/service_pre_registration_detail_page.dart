import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../domain/entities/service_request_entity.dart';
import '../bloc/technical_service_bloc.dart';
import '../bloc/technical_service_state.dart';

class ServicePreRegistrationDetailPage extends StatefulWidget {
  final ServiceRequestEntity request;

  const ServicePreRegistrationDetailPage({super.key, required this.request});

  @override
  State<ServicePreRegistrationDetailPage> createState() =>
      _ServicePreRegistrationDetailPageState();
}

class _ServicePreRegistrationDetailPageState
    extends State<ServicePreRegistrationDetailPage> {
  void _onShipToSupplier() async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.serviceRequestShipment,
      arguments: {'requestId': widget.request.id, 'shipmentType': 1},
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  void _onShipToCustomer() async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.serviceRequestShipment,
      arguments: {'requestId': widget.request.id, 'shipmentType': 2},
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  void _onConfirmDelivery() {
    // TODO: Teslimatı onayla işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Teslimat onayı yakında eklenecek.')),
    );
  }

  bool get _isPending =>
      widget.request.status?.toLowerCase() == 'pending';

  bool get _hasShipment => widget.request.shipmentId != null;

  bool get _isInTransit {
    final status = widget.request.shipmentStatus?.toLowerCase() ?? '';
    return status.replaceAll(' ', '').replaceAll('-', '') == 'intransit';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TechnicalServiceBloc, TechnicalServiceState>(
      listener: (context, state) {
        if (state is TechnicalServiceShipmentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kargo kaydı başarıyla oluşturuldu'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TechnicalServiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          title: const Text(
            'Servis Kaydı Detay',
            style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: const Color(0xFFF57C00), height: 2.0),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildDetailsCard(),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return _buildCard(
      child: Row(
        children: [
          DeviceImageWidget(
              deviceTypeName: widget.request.deviceTypeName, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.deviceTypeName ?? 'Bilinmeyen Model',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seri No: ${widget.request.deviceSerialNumber ?? '-'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Durum',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500)),
                    _buildStatusChip(widget.request.status),
                  ],
                ),
                if (widget.request.shipmentStatus != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kargo',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500)),
                      _buildShipmentStatusChip(widget.request.shipmentStatus),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;
    switch (status?.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'BEKLEMEDE';
        break;
      case 'inprogress':
        color = Colors.blue;
        label = 'İŞLEMDE';
        break;
      case 'completed':
        color = Colors.green;
        label = 'TAMAMLANDI';
        break;
      default:
        color = Colors.grey;
        label = status?.toUpperCase() ?? '-';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withAlpha(30), borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShipmentStatusChip(String? status) {
    Color color;
    String label;
    switch (status?.toLowerCase()) {
      case 'intransit':
        color = Colors.deepPurple;
        label = 'KARGODA';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'TESLİM EDİLDİ';
        break;
      default:
        color = Colors.grey;
        label = status?.toUpperCase() ?? '-';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withAlpha(30), borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kayıt Detayları',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.business,
            title: 'Tedarikçi / Servis',
            value: widget.request.supplierName ?? '-',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Kayıt Tarihi',
            value: widget.request.requestDate != null
                ? DateFormat('dd.MM.yyyy HH:mm')
                    .format(widget.request.requestDate!.toLocal())
                : '-',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.report_problem_outlined,
            title: 'Arıza Açıklaması',
            value: widget.request.faultDescription ?? 'Açıklama belirtilmemiş',
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // shipmentStatus = InTransit → Sadece "Teslimatı Onayla" göster
    if (_isInTransit) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _onConfirmDelivery,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Teslimatı Onayla',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
        ),
      );
    }

    // Eğer bir kargo girişi yapılmışsa ama henüz InTransit değilse veya başka bir durumdaysa 
    // "Gönder" butonlarını göstermeyelim.
    if (_hasShipment) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bu cihaz için kargo kaydı zaten oluşturulmuş.',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          ],
        ),
      );
    }

    // shipmentStatus = null/yok ve status = Pending → Gönder butonları
    final bool canSend = _isPending;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            // disabled if not Pending
            onPressed: canSend ? _onShipToSupplier : null,
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text('Servise Gönder',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: canSend ? _onShipToCustomer : null,
            icon: const Icon(Icons.person_pin_circle_outlined),
            label: const Text('Müşteriye Gönder',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF57C00),
              disabledForegroundColor: Colors.grey[400],
              side: BorderSide(
                  color: canSend ? const Color(0xFFF57C00) : Colors.grey[300]!,
                  width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (!canSend) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kargo işlemi sadece "Beklemede" statüsündeki kayıtlar için yapılabilir.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFF57C00).withAlpha(26),
              shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: const Color(0xFFF57C00)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500])),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                    height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
