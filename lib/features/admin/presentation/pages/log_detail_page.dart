import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/detail_section_card.dart';
import '../models/movement_log_item.dart';

class LogDetailPage extends StatelessWidget {
  final MovementLogItem item;

  const LogDetailPage({
    super.key,
    required this.item,
  });

  String _format(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(date.toLocal());
  }

  static const Map<String, String> _movementTypeLabels = {
    'Purchase': 'Satın Alma',
    'Sale': 'Satış',
    'SalePending': 'Satış (Onay Bekliyor)',
    'SaleCancelled': 'Satış (İptal)',
    'Return': 'İade',
    'Shipment': 'Sevkiyat',
    'Delivery': 'Teslimat',
    'BackupAssignment': 'Yedek Atama',
    'BackupAssign': 'Yedek Atama',
    'BackupReturn': 'Yedek İade',
    'ReturnToBackupPool': 'Yedek Havuzuna İade',
    'Service': 'Servise Gönderim',
    'ServiceReturn': 'Servisten Dönüş',
    'ServiceDispatch': 'Servis Sevkiyatı',
    'ReturnToCustomer': 'Müşteriye İade',
    'BackupRegistration': 'Yedek Kayıt',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: const Text(
          'Log Detayı',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: AppColors.accentDark,
            height: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DetailSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hareket Bilgisi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.devices_other_outlined,
                title: 'Cihaz Türü',
                value: item.deviceTypeName,
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.confirmation_number_outlined,
                title: 'Seri No',
                value: item.deviceSerialNumber,
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.swap_horiz,
                title: 'Hareket Tipi',
                value:
                    _movementTypeLabels[item.movementType] ?? item.movementType,
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.person_outline,
                title: 'Kullanıcı',
                value: item.username,
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.business_outlined,
                title: 'Müşteri',
                value: item.customerName ?? '-',
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.event_outlined,
                title: 'Hareket Tarihi',
                value: _format(item.movementDate),
              ),
              const SizedBox(height: 16),
              DetailInfoRow(
                icon: Icons.schedule_outlined,
                title: 'Kayıt Tarihi',
                value: _format(item.createdDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
