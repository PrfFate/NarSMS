import 'package:flutter/material.dart';

class DeviceImageWidget extends StatelessWidget {
  final String? deviceTypeName;
  final double size;

  const DeviceImageWidget({
    super.key,
    this.deviceTypeName,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: _buildImageOrIcon(),
    );
  }

  Widget _buildImageOrIcon() {
    if (deviceTypeName == null || deviceTypeName!.isEmpty) {
      return _buildFallbackImage();
    }

    final name = deviceTypeName!.toLowerCase();
    
    String? assetName;

    if (name.contains('müşteri') && name.contains('ekran')) {
      assetName = 'Müşteri Ekranlı Bilgisayar.avif';
    } else if (name.contains('bilgisayar') || name.contains('laptop') || name.contains('pc')) {
      assetName = 'Bilgisayar.webp';
    } else if (name.contains('okuyucu')) {
      assetName = 'Barkod Okuyucu.jpg';
    } else if (name.contains('yazıcı') || name.contains('printer')) {
      if (name.contains('barkod')) {
        assetName = 'Barkod Yazıcı.jpg';
      } else {
        assetName = 'Termal Yazıcı.jpg';
      }
    } else if (name.contains('terazi')) {
      if (name.contains('barkodlu')) {
        assetName = 'Barkodlu Terazi.webp';
      } else if (name.contains('pos')) {
        assetName = 'Terazi POS.jpg';
      } else {
        assetName = 'Hassas Terazi.png';
      }
    } else if (name.contains('ip telefon') || name.contains('telefon')) {
      assetName = 'IP Telefon.avif';
    } else if (name.contains('nb11')) {
      assetName = 'NB11.avif';
    } else if (name.contains('para') || name.contains('çekmece')) {
      assetName = 'Para Çekmecesi-5 Gözlü.webp';
    } else if (name.contains('pavo')) {
      assetName = 'Pavo.png';
    } else if (name.contains('hard disk') || name.contains('harddisk')) {
      assetName = 'Hard Disk.jpeg';
    } else if (name.contains('switch')) {
      assetName = 'Switch.jpeg';
    } else if (name.contains('ups')) {
      assetName = 'UPS.jpg';
    } else if (name.contains('monitör') || name.contains('monitor') || name.contains('dokunmatik')) {
      assetName = 'Dokunmatik Monitör.png';
    } else if (name.contains('yazarkasa') || name.contains('yazar kasa')) {
      assetName = 'Yazarkasa.webp';
    } else if (name.contains('pos')) {
      assetName = 'POS.webp';
    }

    if (assetName != null) {
      return Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      );
    }

    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      'assets/images/default-device.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // En kötü senaryoda default-device.jpg de bozuksa veya yüklenemezse ikon gösterilir
        return Center(
          child: Icon(
            Icons.devices_other,
            color: const Color(0xFFF57C00),
            size: size * 0.5,
          ),
        );
      },
    );
  }
}
