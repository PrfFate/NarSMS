import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../domain/entities/service_request_entity.dart';

/// Devam Eden İşlem Detay Sayfası
///
/// Servis kaydının detaylarını gösterir.
/// "Tamamla" butonu → Bottom Sheet açılır →
/// POST /api/ServiceOperation ile servisi tamamlar.
class ServiceOngoingDetailPage extends StatefulWidget {
  final ServiceRequestEntity request;

  const ServiceOngoingDetailPage({super.key, required this.request});

  @override
  State<ServiceOngoingDetailPage> createState() =>
      _ServiceOngoingDetailPageState();
}

class _ServiceOngoingDetailPageState extends State<ServiceOngoingDetailPage> {
  // Shipment detail data
  Map<String, dynamic>? _shipmentData;
  bool _isLoadingShipment = false;

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

  void _showCompleteSheet() {
    final descController = TextEditingController();
    final partsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Servisi Tamamla',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Read-only: Cihaz Seri No
                        _buildReadOnlyField(
                          icon: Icons.qr_code,
                          label: 'Cihaz Seri No',
                          value: widget.request.deviceSerialNumber ?? '-',
                        ),
                        const SizedBox(height: 12),

                        // Read-only: Arıza Açıklaması
                        _buildReadOnlyField(
                          icon: Icons.report_problem_outlined,
                          label: 'Arıza Açıklaması',
                          value: widget.request.faultDescription ??
                              'Açıklama yok',
                        ),
                        const SizedBox(height: 20),

                        // Editable: Yapılan İşlem Açıklaması
                        TextFormField(
                          controller: descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Yapılan İşlem Açıklaması *',
                            hintText: 'Yapılan işlemi detaylı açıklayın',
                            prefixIcon: const Icon(Icons.build_outlined,
                                color: Color(0xFFF57C00)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFF57C00), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Editable: Değiştirilen Parçalar
                        TextFormField(
                          controller: partsController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Değiştirilen Parçalar *',
                            hintText: 'Değiştirilen parçaları yazın',
                            prefixIcon: const Icon(Icons.settings_outlined,
                                color: Color(0xFFF57C00)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFF57C00), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bu alan zorunludur';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    setSheetState(() => isSubmitting = true);

                                    final success = await _submitComplete(
                                      description: descController.text.trim(),
                                      replacedParts:
                                          partsController.text.trim(),
                                    );

                                    if (success && mounted) {
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Servis işlemi başarıyla tamamlandı'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.of(context).pop(true);
                                    } else {
                                      setSheetState(
                                          () => isSubmitting = false);
                                    }
                                  },
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              isSubmitting ? 'Gönderiliyor...' : 'Tamamla',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF57C00),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFF57C00).withAlpha(128),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReadOnlyField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _submitComplete({
    required String description,
    required String replacedParts,
  }) async {
    try {
      final dioClient = GetIt.instance<DioClient>();

      final data = {
        'serviceRequestId': widget.request.id,
        'operationDate': DateTime.now().toUtc().toIso8601String(),
        'description': description,
        'replacedParts': replacedParts,
      };

      final response = await dioClient.dio.post(
        ApiConstants.serviceOperation,
        data: data,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.data?['message'] ?? 'İşlem tamamlanamadı';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red),
        );
      }
      return false;
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
          'İşlem Detayı',
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
            if (_shipmentData != null || _isLoadingShipment) ...[
              const SizedBox(height: 16),
              _buildShipmentCard(),
            ],
            const SizedBox(height: 24),
            _buildCompleteButton(),
          ],
        ),
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
                    'İŞLEMDE',
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

    if (_shipmentData == null) return const SizedBox.shrink();

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
          width: 110,
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

  // ── Tamamla Butonu ──
  Widget _buildCompleteButton() {
    final isInProgress =
        widget.request.status?.toLowerCase() == 'inprogress';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isInProgress ? _showCompleteSheet : null,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Servisi Tamamla',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF57C00),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
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
