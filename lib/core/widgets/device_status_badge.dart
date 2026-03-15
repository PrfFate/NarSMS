import 'package:flutter/material.dart';
import '../enums/device_status.dart';

/// Cihaz durumunu gösteren yeniden kullanılabilir renkli badge.
/// Hem liste satırında hem detay sayfasında kullanılır.
class DeviceStatusBadge extends StatelessWidget {
  /// Backend'den gelen ham String durum değeri ('InStock', 'Sold' vb.)
  final String? rawStatus;

  /// Badge boyutu — compact: liste satırı, normal: detay sayfası
  final bool compact;

  const DeviceStatusBadge({
    super.key,
    required this.rawStatus,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = DeviceStatus.fromString(rawStatus);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.foregroundColor.withAlpha(60)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: status.foregroundColor,
        ),
      ),
    );
  }
}
