import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../domain/entities/service_request_entity.dart';

/// Son Kontroller Detay Sayfası
class ServiceFinalCheckDetailPage extends StatefulWidget {
  final ServiceRequestEntity request;

  const ServiceFinalCheckDetailPage({super.key, required this.request});

  @override
  State<ServiceFinalCheckDetailPage> createState() =>
      _ServiceFinalCheckDetailPageState();
}

class _ServiceFinalCheckDetailPageState extends State<ServiceFinalCheckDetailPage> {
  // Shipment detail data
  Map<String, dynamic>? _shipmentData;
  bool _isLoadingShipment = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadShipmentDetail();
  }

  Future<void> _loadShipmentDetail() async {
    final shipmentId = widget.request.shipmentId;
    if (shipmentId == null) return;

    setState(() => _isLoadingShipment = true);

    try {
      final dioClient = GetIt.instance<DioClient>();
      final response = await dioClient.dio.get(
        ApiConstants.shipmentById(shipmentId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        Map<String, dynamic>? shipment;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('value') && data['value'] is Map) {
            shipment = data['value'] as Map<String, dynamic>;
          } else if (data.containsKey('id')) {
            shipment = data;
          }
        }
        if (mounted) setState(() => _shipmentData = shipment);
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingShipment = false);
  }

  Future<void> _markDelivered() async {
    final shipmentId = widget.request.shipmentId;
    if (shipmentId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Teslimatı Onayla'),
        content: const Text('Kargo teslimatını onaylamak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Onayla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      final dioClient = GetIt.instance<DioClient>();
      final response = await dioClient.dio.patch(
        ApiConstants.shipmentMarkDelivered(shipmentId),
        data: {}, // Empty body
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teslimat başarıyla onaylandı'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.data?['message'] ?? 'İşlem başarısız';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _returnToBackupPool() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yedek Havuzuna Gönder'),
        content: const Text('Cihazı yedek havuzuna göndermek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Gönder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (widget.request.id == null) return;

    setState(() => _isSubmitting = true);
    try {
      final dioClient = GetIt.instance<DioClient>();
      final response = await dioClient.dio.post(
        ApiConstants.serviceRequestReturnToBackup(widget.request.id!),
        data: {
          "date": DateTime.now().toUtc().toIso8601String()
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yedek havuzuna başarıyla gönderildi'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.data?['message'] ?? 'İşlem başarısız';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _navigateToShipment(int type) async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.serviceRequestShipment,
      arguments: {
        'requestId': widget.request.id,
        'shipmentType': type, // 1 = Servise Gönder, 2 = Müşteriye Gönder
      },
    );
    if (result == true) {
      if (mounted) {
        Navigator.pop(context, true); // Go back and refresh list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          'Son Kontrol Detayı',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildDetailsCard(),
                const SizedBox(height: 16),
                _buildOperationCard(),
                const SizedBox(height: 16),
                _buildShipmentCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFFF57C00))),
            ),
        ],
      ),
    );
  }

  // ── Header Card ──
  Widget _buildHeaderCard() {
    return _buildCard(
      child: Row(
        children: [
          DeviceImageWidget(
            deviceTypeName: widget.request.deviceTypeName,
            size: 72,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.deviceTypeName ?? 'Bilinmeyen Cihaz',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      widget.request.deviceSerialNumber ?? '-',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C00).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SON KONTROLDE',
                    style: TextStyle(
                      color: Color(0xFFF57C00),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Details Card ──
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
            icon: Icons.person_outline,
            title: 'Müşteri',
            value: widget.request.customerName ?? '-',
          ),
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
            value:
                widget.request.faultDescription ?? 'Açıklama belirtilmemiş',
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  // ── Operation Card (Son Yapılan İşlem) ──
  Widget _buildOperationCard() {
    // Get last operation
    final operations = widget.request.serviceOperations;
    if (operations == null || operations.isEmpty) return const SizedBox.shrink();

    // Assuming the list is ordered or we take the last one
    final lastOp = operations.last;
    final description = lastOp['description']?.toString() ?? 'Belirtilmemiş';
    final replacedParts = lastOp['replacedParts']?.toString() ?? 'Parça değişimi yok';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_circle_outlined,
                    color: Color(0xFFF57C00), size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Yapılan İşlem Özeti',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.notes,
            title: 'İşlem Açıklaması',
            value: description,
            isMultiline: true,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.settings_input_component_outlined,
            title: 'Değiştirilen Parçalar',
            value: replacedParts,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  // ── Shipment Card ──
  Widget _buildShipmentCard() {
    if (_isLoadingShipment) {
      return _buildCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFFF57C00)),
          ),
        ),
      );
    }

    if (widget.request.shipmentStatus == null || _shipmentData == null) {
      return _buildCard(
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Kargo takip bilgisi bulunmamaktadır.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    final d = _shipmentData!;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping,
                    color: Colors.deepPurple, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Kargo Bilgisi',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          _buildShipmentInfoRow(
            icon: Icons.business_outlined,
            title: 'Kargo Firması',
            value: d['carrierName'] as String? ?? '-',
          ),
          const SizedBox(height: 12),
          _buildShipmentInfoRow(
            icon: Icons.tag,
            title: 'Takip Numarası',
            value: d['trackingNumber'] as String? ?? '-',
          ),
          const SizedBox(height: 12),
          _buildShipmentInfoRow(
            icon: Icons.person_outline,
            title: 'Gönderen Personel',
            value: d['senderName'] as String? ?? '-',
          ),
          const SizedBox(height: 12),
          _buildShipmentInfoRow(
            icon: Icons.info_outline,
            title: 'Durum',
            value: d['statusText'] as String? ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple.withAlpha(180)),
        const SizedBox(width: 10),
        SizedBox(
          width: 130,
          child:
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
        ),
      ],
    );
  }

  // ── Action Buttons ──
  Widget _buildActionButtons() {
    final status = widget.request.shipmentStatus?.toLowerCase();

    if (status == 'intransit') {
      // Sadece Teslimatı Onayla
      return ElevatedButton.icon(
        onPressed: _markDelivered,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Teslimatı Onayla'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF57C00),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    final hasCustomer = widget.request.customerName != null && 
                        widget.request.customerName!.trim().isNotEmpty;

    // Kargoda değilse duruma göre butonlar
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToShipment(1),
                icon: const Icon(Icons.local_shipping_outlined, size: 20),
                label: const Text('Servise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ),
            if (hasCustomer) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToShipment(2),
                  icon: const Icon(Icons.home_outlined, size: 20),
                  label: const Text('Müşteriye'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!hasCustomer) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _returnToBackupPool,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Yedek Havuzuna Gönder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFF57C00),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFF57C00)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Helpers ──
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
        Icon(icon, size: 20, color: const Color(0xFFF57C00)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ),
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
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}
