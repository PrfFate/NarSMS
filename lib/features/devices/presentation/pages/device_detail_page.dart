import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../../../core/widgets/device_status_badge.dart';
import '../../../../config/routes/app_router.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/device_movement_entity.dart';
import '../../domain/usecases/get_device_movements_usecase.dart';
import '../../../../core/di/injection.dart';

String _translateMovementType(String type) {
  switch (type) {
    case 'Purchase': return 'Satın Alma';
    case 'Sale': return 'Satış';
    case 'SalePending': return 'Satış (Onay Bekliyor)';
    case 'SaleCancelled': return 'Satış (İptal)';
    case 'Return': return 'İade';
    case 'Shipment': return 'Sevkiyat';
    case 'Delivery': return 'Teslimat';
    case 'BackupAssignment': return 'Yedek Atama';
    case 'BackupAssign': return 'Yedek Atama';
    case 'BackupReturn': return 'Yedek İade';
    case 'ReturnToBackupPool': return 'Yedek Havuzuna İade';
    case 'Service': return 'Servis';
    case 'ServiceReturn': return 'Servisten Dönüş';
    case 'ServiceDispatch': return 'Servis Sevkiyatı';
    case 'ReturnToCustomer': return 'Müşteriye İade';
    case 'BackupRegistration': return 'Yedek Kayıt';
    default: return type;
  }
}

class DeviceDetailPage extends StatelessWidget {
  final DeviceEntity device;

  const DeviceDetailPage({super.key, required this.device});

  void _showDeleteDialog(BuildContext context) {
    var bloc = context.read<DeviceBloc>();
    showDialog(
      context: context,
      builder: (BuildContext dContext) {
        return AlertDialog(
          title: const Text('Silme İşlemi',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: const Text(
              'Bu cihazı sistemsel olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dContext).pop(),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(dContext).pop();
                bloc.add(DeleteDevice(device.id));
              },
              child: const Text('Evet, Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is DeviceActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Liste yenilenecek şekilde geri dön
        } else if (state is DeviceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
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
              'Cihaz Detay',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.deviceEdit,
                          arguments: device)
                      .then((value) {
                    if (value == true) {
                      if (context.mounted) {
                        Navigator.pop(context,
                            true); // Eğer düzenlendiyse çıkarken ana listeye sinyal ver
                      }
                    }
                  });
                },
                tooltip: 'Cihazı Düzenle',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _showDeleteDialog(context),
                tooltip: 'Cihazı Sil',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                  color: const Color(0xFFF57C00),
                  height: 2.0), // Cihaz sayfaları için turuncu şerit
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Temel Bilgiler Kartı (Profil misali)
                _buildCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DeviceImageWidget(
                        deviceTypeName: device.deviceTypeName,
                        size: 72,
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
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seri Numarası: ${device.deviceSerialNumber ?? '-'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cihaz Durumu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                DeviceStatusBadge(rawStatus: device.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Satın Alma ve Tedarikçi Kartı
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Satın Alma ve Tedarik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.local_shipping_outlined,
                        title: 'Tedarikçi',
                        value: device.supplierName ??
                            (device.supplierId != null
                                ? 'Tedarikçi ID: ${device.supplierId}'
                                : '-'),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        title: 'Satın Alma Tarihi',
                        value: device.purchaseDate != null
                            ? DateFormat('dd.MM.yyyy')
                                .format(device.purchaseDate!)
                            : '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Özellikler Kartı
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cihaz Özellikleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (device.features != null &&
                          device.features!.isNotEmpty) ...[
                        ...device.features!.map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildInfoRow(
                              icon: Icons.memory,
                              title: feature.featureName ?? '-',
                              value: feature.featureValue ?? '-',
                              iconColor: const Color(0xFFF57C00),
                            ),
                          );
                        }),
                      ] else ...[
                        _buildInfoRow(
                          icon: Icons.sim_card_alert_outlined,
                          title: 'Özellik',
                          value: 'Ek donanım özelliği bulunmuyor',
                          iconColor: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cihaz Hareketleri
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cihaz Hareketleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future:
                            getIt<GetDeviceMovementsUseCase>().call(device.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFF57C00)));
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                  'Hareketler yüklenirken bir hata oluştu.',
                                  style: TextStyle(color: Colors.red)),
                            );
                          }

                          final result = snapshot.data;
                          if (result == null) {
                            return const Center(
                                child: Text('Kayıt bulunamadı.'));
                          }

                          return result.fold(
                            (failure) => Center(
                                child: Text(failure.message,
                                    style: const TextStyle(color: Colors.red))),
                            (movements) {
                              if (movements.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                        'Cihaza ait hareket kaydı bulunmuyor.',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: movements.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 24),
                                itemBuilder: (context, index) {
                                  final mov = movements[index];
                                  return _buildMovementRow(mov);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovementRow(DeviceMovementEntity mov) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF57C00).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.compare_arrows,
                  size: 16, color: Color(0xFFF57C00)),
            ),
            Container(
              width: 2,
              height: 40,
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mov.movementType != null ? _translateMovementType(mov.movementType!) : 'Bilinmeyen Hareket',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                "${mov.fromLocation ?? "-"} ➔ ${mov.toLocation ?? "-"}",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              if (mov.customerName != null && mov.customerName!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('Müşteri: ${mov.customerName!}',
                    style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
              const SizedBox(height: 2),
              Text(
                mov.movementDate != null
                    ? DateFormat('dd.MM.yyyy HH:mm').format(mov.movementDate!)
                    : '-',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        if (mov.username != null)
          Text(
            mov.username!,
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontStyle: FontStyle.italic),
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
            offset: const Offset(0, 4),
          ),
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
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFFF57C00)).withAlpha(26),
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, size: 20, color: iconColor ?? const Color(0xFFF57C00)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
