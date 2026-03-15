import 'package:flutter/material.dart';

/// Cihaz durum enum'u — tüm UI bileşenleri buradan beslenir.
/// Backend değerleri (String) → Türkçe etiket + renk tek noktadan yönetilir.
enum DeviceStatus {
  inStock,
  returned,
  maintenance,
  sold,
  pendingSale,
  assignedBackup,
  approvedSale,
  unknown;

  /// Backend'den gelen ham String → enum dönüşümü.
  static DeviceStatus fromString(String? value) {
    switch (value) {
      case 'InStock':        return DeviceStatus.inStock;
      case 'Returned':       return DeviceStatus.returned;
      case 'Maintenance':    return DeviceStatus.maintenance;
      case 'Sold':           return DeviceStatus.sold;
      case 'PendingSale':    return DeviceStatus.pendingSale;
      case 'AssignedBackup': return DeviceStatus.assignedBackup;
      case 'ApprovedSale':   return DeviceStatus.approvedSale;
      default:               return DeviceStatus.unknown;
    }
  }

  /// Kullanıcıya gösterilecek Türkçe etiket.
  String get label {
    switch (this) {
      case DeviceStatus.inStock:        return 'Depoda';
      case DeviceStatus.returned:       return 'Yedek';
      case DeviceStatus.maintenance:    return 'Servis';
      case DeviceStatus.sold:           return 'Satış';
      case DeviceStatus.pendingSale:    return 'Onay Bekleyen Satış';
      case DeviceStatus.assignedBackup: return 'Atanmış Yedek';
      case DeviceStatus.approvedSale:   return 'Onaylanmış Satış';
      case DeviceStatus.unknown:        return 'Bilinmiyor';
    }
  }

  /// Badge arka plan rengi (hafif ton).
  Color get backgroundColor {
    switch (this) {
      case DeviceStatus.inStock:        return const Color(0xFFDCFCE7); // yeşil
      case DeviceStatus.returned:       return const Color(0xFFFFF7ED); // turuncu
      case DeviceStatus.maintenance:    return const Color(0xFFFFF7ED); // turuncu
      case DeviceStatus.sold:           return const Color(0xFFEFF6FF); // mavi
      case DeviceStatus.pendingSale:    return const Color(0xFFFEF9C3); // sarı
      case DeviceStatus.assignedBackup: return const Color(0xFFF3E8FF); // mor
      case DeviceStatus.approvedSale:   return const Color(0xFFECFDF5); // açık yeşil
      case DeviceStatus.unknown:        return const Color(0xFFF1F5F9); // gri
    }
  }

  /// Badge yazı + border rengi.
  Color get foregroundColor {
    switch (this) {
      case DeviceStatus.inStock:        return const Color(0xFF16A34A);
      case DeviceStatus.returned:       return const Color(0xFFEA580C);
      case DeviceStatus.maintenance:    return const Color(0xFFD97706);
      case DeviceStatus.sold:           return const Color(0xFF2563EB);
      case DeviceStatus.pendingSale:    return const Color(0xFFCA8A04);
      case DeviceStatus.assignedBackup: return const Color(0xFF7C3AED);
      case DeviceStatus.approvedSale:   return const Color(0xFF059669);
      case DeviceStatus.unknown:        return const Color(0xFF94A3B8);
    }
  }
}
