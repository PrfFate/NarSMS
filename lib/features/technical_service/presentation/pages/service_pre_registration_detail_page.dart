import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../domain/entities/service_request_entity.dart';
import '../bloc/technical_service_bloc.dart';
import '../bloc/technical_service_event.dart';
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
  // Shipment detail data
  Map<String, dynamic>? _shipmentData;
  bool _isLoadingShipment = false;
  String? _shipmentError;

  @override
  void initState() {
    super.initState();
    _loadShipmentDetail();
  }

  Future<void> _loadShipmentDetail() async {
    final shipmentId = widget.request.shipmentId;
    if (shipmentId == null) return;

    setState(() {
      _isLoadingShipment = true;
      _shipmentError = null;
    });

    try {
      final dioClient = GetIt.instance<DioClient>();
      final prefs = GetIt.instance<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);

      final response = await dioClient.dio.get(
        ApiConstants.shipmentById(shipmentId),
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
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

        if (mounted) {
          setState(() {
            _shipmentData = shipment;
            _isLoadingShipment = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingShipment = false);
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingShipment = false;
          if (e.response?.statusCode != 404) {
            _shipmentError = 'Kargo bilgisi yüklenemedi';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingShipment = false;
          _shipmentError = 'Kargo bilgisi yüklenemedi';
        });
      }
    }
  }

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
    if (widget.request.shipmentId != null) {
      context.read<TechnicalServiceBloc>().add(
        ConfirmDelivery(shipmentId: widget.request.shipmentId!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kargo bilgisi bulunamadı.')),
      );
    }
  }

  bool get _isPending => widget.request.status?.toLowerCase() == 'pending';

  bool get _isInTransit =>
      widget.request.shipmentStatus?.toLowerCase() == 'intransit';

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
        } else if (state is TechnicalServiceDeliveryConfirmSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teslimat başarıyla onaylandı'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
          titleSpacing: 0,
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
              const SizedBox(height: 16),
              _buildShipmentCard(),
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
      case 'pending':
        color = Colors.orange;
        label = 'BEKLEMEDE';
        break;
      case 'failed':
        color = Colors.red;
        label = 'BAŞARISIZ';
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

  // ── Kargo Bilgisi Kartı ──
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

    if (_shipmentError != null) {
      return _buildCard(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 32),
              const SizedBox(height: 8),
              Text(_shipmentError!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadShipmentDetail,
                child: const Text('Tekrar Dene',
                    style: TextStyle(color: Color(0xFFF57C00))),
              ),
            ],
          ),
        ),
      );
    }

    if (_shipmentData == null) {
      return _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_shipping_outlined,
                      color: Colors.grey, size: 22),
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
            Center(
              child: Text(
                'Henüz kargo kaydı oluşturulmamış.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      );
    }

    final d = _shipmentData!;
    final carrierName = d['carrierName'] as String? ?? '-';
    final trackingNumber = d['trackingNumber'] as String? ?? '-';
    final statusText = d['statusText'] as String? ?? d['typeText'] as String? ?? '-';
    final createdByUserName = d['createdByUserName'] as String? ?? '-';

    String shipmentDateStr = '-';
    if (d['shipmentDate'] != null) {
      try {
        final date = DateTime.parse(d['shipmentDate']).toLocal();
        shipmentDateStr = DateFormat('dd.MM.yyyy').format(date);
      } catch (_) {
        shipmentDateStr = d['shipmentDate'].toString();
      }
    }

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
          const SizedBox(height: 20),
          _buildShipmentInfoRow(
            icon: Icons.business_outlined,
            title: 'Kargo Firması',
            value: carrierName,
          ),
          const SizedBox(height: 14),
          _buildShipmentInfoRow(
            icon: Icons.tag,
            title: 'Takip Numarası',
            value: trackingNumber,
          ),
          const SizedBox(height: 14),
          _buildShipmentInfoRow(
            icon: Icons.calendar_month_outlined,
            title: 'Kargo Tarihi',
            value: shipmentDateStr,
          ),
          const SizedBox(height: 14),
          _buildShipmentInfoRow(
            icon: Icons.info_outline,
            title: 'Durum',
            value: statusText,
          ),
          const SizedBox(height: 14),
          _buildShipmentInfoRow(
            icon: Icons.person_outline,
            title: 'Kargolayan',
            value: createdByUserName,
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
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500])),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

    // shipmentStatus null → Gönder butonları
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _onShipToSupplier,
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text('Servise Gönder',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
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
            onPressed: _onShipToCustomer,
            icon: const Icon(Icons.person_pin_circle_outlined),
            label: const Text('Müşteriye Gönder',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF57C00),
              side: const BorderSide(
                  color: Color(0xFFF57C00),
                  width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
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
