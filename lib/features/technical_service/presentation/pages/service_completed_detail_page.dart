import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../domain/entities/service_request_entity.dart';

/// Tamamlanan İşlemler Detay Sayfası
/// Sadece görüntüleme amaçlıdır. Cihaz bilgileri ve işlem geçmişini listeler.
class ServiceCompletedDetailPage extends StatelessWidget {
  final ServiceRequestEntity request;

  const ServiceCompletedDetailPage({super.key, required this.request});

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
          'Tamamlanan İşlem Detayı',
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
            _buildOperationsHistoryCard(),
            const SizedBox(height: 40),
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
            deviceTypeName: request.deviceTypeName,
            size: 72,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.deviceTypeName ?? 'Bilinmeyen Cihaz',
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
                      request.deviceSerialNumber ?? '-',
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
                    color: Colors.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'TAMAMLANDI',
                    style: TextStyle(
                      color: Colors.green,
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
    // Tamamlanma tarihi, en son yapılan işlemin tarihi olarak alınabilir.
    DateTime? completedDate;
    final ops = request.serviceOperations;
    if (ops != null && ops.isNotEmpty) {
      final lastOpDate = ops.last['operationDate'] as String?;
      if (lastOpDate != null) {
        completedDate = DateTime.tryParse(lastOpDate);
      }
    }

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
            value: request.customerName ?? '-',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.business,
            title: 'Tedarikçi / Servis',
            value: request.supplierName ?? '-',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Kayıt Tarihi',
            value: request.requestDate != null
                ? DateFormat('dd.MM.yyyy HH:mm')
                    .format(request.requestDate!.toLocal())
                : '-',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.event_available_outlined,
            title: 'Tamamlanma Tarihi',
            value: completedDate != null
                ? DateFormat('dd.MM.yyyy HH:mm').format(completedDate.toLocal())
                : '-',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.report_problem_outlined,
            title: 'Arıza Açıklaması',
            value: request.faultDescription ?? 'Açıklama belirtilmemiş',
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  // ── Operations History Card (Tüm Geçmiş) ──
  Widget _buildOperationsHistoryCard() {
    final operations = request.serviceOperations;
    
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
                child: const Icon(Icons.history,
                    color: Color(0xFFF57C00), size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Tüm Servis İşlemleri Geçmişi',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          
          if (operations == null || operations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Bu servis kaydı için işlem geçmişi bulunmuyor.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: operations.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final op = operations[index];
                final dateStr = op['operationDate'] as String?;
                final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
                final desc = op['description']?.toString() ?? 'Belirtilmemiş';
                final parts = op['replacedParts']?.toString() ?? 'Parça değişimi yok';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          date != null ? DateFormat('dd.MM.yyyy HH:mm').format(date.toLocal()) : '-',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.notes,
                      title: 'İşlem Açıklaması',
                      value: desc,
                      isMultiline: true,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.settings_input_component_outlined,
                      title: 'Değiştirilen Parçalar',
                      value: parts,
                      isMultiline: true,
                    ),
                  ],
                );
              },
            ),
        ],
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
