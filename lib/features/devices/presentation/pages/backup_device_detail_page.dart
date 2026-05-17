import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/device_entity.dart';
import '../../../../core/widgets/device_status_badge.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../../../config/routes/app_router.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';

String _translateShipmentStatus(String status) {
  switch (status) {
    case 'Pending': return 'Beklemede';
    case 'InTransit': return 'Yolda';
    case 'Delivered': return 'Teslim Edildi';
    case 'Failed': return 'Başarısız';
    default: return status;
  }
}

class BackupDeviceDetailPage extends StatelessWidget {
  final DeviceEntity device;
  final bool isAssignedView;

  const BackupDeviceDetailPage({
    super.key,
    required this.device,
    this.isAssignedView = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is DeviceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is DeviceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Yedek Cihaz Detayı',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFF57C00),
              height: 2.0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Üst Kart
              _buildInfoCard(
                child: Row(
                  children: [
                    DeviceImageWidget(
                      deviceTypeName: device.deviceTypeName,
                      size: 80,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.deviceTypeName ?? 'Bilinmeyen Model',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SN: ${device.deviceSerialNumber ?? '---'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          DeviceStatusBadge(rawStatus: device.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Teknik Özellikler
              _buildSectionTitle('Teknik Özellikler'),
              const SizedBox(height: 8),
              _buildInfoCard(
                child: Column(
                  children: [
                    if (!isAssignedView) ...[
                      _buildDetailRow(
                          'Tedarikçi', device.supplierName ?? '---'),
                      _buildDetailRow(
                          'Alış Fiyatı', '${device.purchasePrice ?? 0} ₺'),
                      _buildDetailRow(
                        'Satın Alma Tarihi',
                        device.purchaseDate != null
                            ? DateFormat('dd.MM.yyyy')
                                .format(device.purchaseDate!)
                            : '---',
                      ),
                    ],
                    if (device.features != null &&
                        device.features!.isNotEmpty &&
                        device.features![0].featureName != 'No Properties') ...[
                      if (!isAssignedView) const Divider(height: 24),
                      ...device.features!.map((f) => _buildDetailRow(
                            f.featureName ?? 'Özellik',
                            f.featureValue ?? '---',
                          )),
                    ] else ...[
                      if (isAssignedView)
                        const Align(
                          alignment: Alignment.center,
                          child: Text('Özellik Yok',
                              style: TextStyle(color: Colors.grey)),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Atama Bilgileri (sadece Atanmışlar ekranında)
              if (isAssignedView) ...[
                _buildSectionTitle('Atama Bilgileri'),
                const SizedBox(height: 8),
                _buildInfoCard(
                  child: Column(
                    children: [
                      _buildDetailRow('Müşteri', device.customerName ?? '---'),
                      _buildDetailRow(
                        'Atama Tarihi',
                        device.assignmentDate != null
                            ? DateFormat('dd.MM.yyyy HH:mm')
                                .format(device.assignmentDate!.toLocal())
                            : '---',
                      ),
                      if (device.notes != null && device.notes!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildDetailRow('Notlar', device.notes!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Teslimat Durumu
              if (device.shipmentStatus != null) ...[
                _buildSectionTitle('Teslimat Durumu'),
                const SizedBox(height: 8),
                _buildInfoCard(
                  child: Column(
                    children: [
                      _buildDetailRow(
                          'Sevkiyat No', '#${device.shipmentId ?? '---'}'),
                      _buildDetailRow(
                        'Durum',
                        _translateShipmentStatus(device.shipmentStatus!),
                        valueColor: device.shipmentStatus == 'InTransit'
                            ? Colors.blue
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // 5. Aksiyon Butonları
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Atanmış Yedekler ekranından gelindiyse:
    // - Cihaz hâlâ kargodaysa (InTransit) → Teslimatı Onayla
    // - Teslim edildiyse (Delivered / null) → Geri Al
    if (isAssignedView) {
      if (device.shipmentStatus == 'InTransit') {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // Teslimat onaylama API yakında eklenecek
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Teslimat onaylama yakında eklenecek.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Teslimatı Onayla',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              final assignmentId = device.assignmentId;
              if (assignmentId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Atama ID bulunamadı.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              context.read<DeviceBloc>().add(
                    ReturnBackupAssignment(assignmentId: assignmentId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.settings_backup_restore),
            label: const Text('Cihazı Geri Al',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
    }

    // Depodaki Yedek Cihazlar'dan gelindiyse → InTransit: Onayla, değilse: Müşteriye Ata
    if (device.shipmentStatus == 'InTransit') {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Teslimat onaylama yakında eklenecek.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Teslimatı Onayla',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRouter.backupAssignmentAssign,
              arguments: device,
            );
            if (result == true) {
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Müşteriye Ata',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
  }
}
