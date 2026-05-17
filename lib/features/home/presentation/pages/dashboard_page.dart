import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_response_utils.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();
  int _selectedPage = 0;
  bool _isLoading = true;
  String? _error;
  InventoryDashboardData? _data;
  /// Depodaki Cihazlar sayfasıyla aynı kaynak: canlı InStock araması.
  int? _liveInStockCount;

  Dio get _dio => getIt<DioClient>().dio;
  SharedPreferences get _prefs => getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = _prefs.getString(StorageConstants.accessToken);
      final headers = {if (token != null) 'Authorization': 'Bearer $token'};

      final results = await Future.wait([
        _dio.get(
          ApiConstants.dashboardInventory,
          queryParameters: const {'refresh': true},
          options: Options(headers: headers),
        ),
        _dio.get(
          ApiConstants.deviceSearch,
          queryParameters: const {
            'status': 'InStock',
            'page': 1,
            'pageSize': 1,
          },
          options: Options(headers: headers),
        ),
      ]);

      if (!mounted) return;

      final inventoryMap = ApiResponseUtils.asMap(results[0].data);
      final searchMap = ApiResponseUtils.asMap(results[1].data);

      int? liveInStock;
      if (searchMap != null) {
        final payload = ApiResponseUtils.unwrapPayload(searchMap);
        liveInStock = (payload['totalCount'] as num?)?.toInt();
      }

      setState(() {
        _liveInStockCount = liveInStock;
        if (inventoryMap != null) {
          _data = InventoryDashboardData.fromJson(
            ApiResponseUtils.unwrapPayload(inventoryMap),
            inStockOverride: liveInStock,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Dashboard verisi alınamadı');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _inStockCount(InventoryDashboardData data) =>
      _liveInStockCount ?? data.inStockDevices;

  void _selectPage(int index) {
    setState(() => _selectedPage = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DashboardTabButton(
                  title: 'Cihaz Durumu',
                  selected: _selectedPage == 0,
                  onTap: () => _selectPage(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardTabButton(
                  title: 'Cihaz Çeşidi',
                  selected: _selectedPage == 1,
                  onTap: () => _selectPage(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _DashboardMessageCard(
        icon: Icons.error_outline,
        message: _error!,
        actionLabel: 'Tekrar Dene',
        onAction: _loadInventory,
      );
    }

    final data = _data;
    if (data == null) {
      return _DashboardMessageCard(
        icon: Icons.dashboard_outlined,
        message: 'Dashboard verisi bulunamadı',
        actionLabel: 'Yenile',
        onAction: _loadInventory,
      );
    }

    final inStockCount = _inStockCount(data);

    return RefreshIndicator(
      onRefresh: _loadInventory,
      color: AppColors.accentDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 560,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _selectedPage = index),
                children: [
                  _DashboardPieCard(
                    title: 'Cihaz Durumu Dağılımı',
                    items: data.statusBreakdown
                        .map(
                          (item) => _PieItem(
                            label: item.status,
                            value: (item.status.toLowerCase().contains('stok')
                                    ? inStockCount
                                    : item.count)
                                .toDouble(),
                            displayValue: item.status
                                    .toLowerCase()
                                    .contains('stok')
                                ? '$inStockCount (${data.totalDevices > 0 ? (inStockCount / data.totalDevices * 100).toStringAsFixed(1) : '0.0'}%)'
                                : '${item.count} (${item.percentage.toStringAsFixed(1)}%)',
                            color: item.color,
                          ),
                        )
                        .toList(),
                  ),
                  _DashboardPieCard(
                    title: 'Stokta Bulunan Cihaz Türleri (Top 10)',
                    items: data.stockByType
                        .where((item) => item.inStock > 0)
                        .take(10)
                        .map((item) {
                      return _PieItem(
                        label: item.deviceType,
                        value: item.inStock.toDouble(),
                        displayValue: '${item.inStock} adet',
                        color: _typeColors[data.stockByType.indexOf(item) %
                            _typeColors.length],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DashboardMetricCard(
              value: _selectedPage == 0
                  ? '${data.totalDevices}'
                  : '$inStockCount',
              label: _selectedPage == 0 ? 'TOPLAM CİHAZ' : 'STOKTA OLAN CİHAZ',
              compact: true,
            ),
          const SizedBox(height: 16),
          _DashboardMetricCard(
            value: '${data.lowStockAlerts} Kalemde',
            label: 'DÜŞÜK STOK UYARISI',
            highlighted: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LowStockAlertDetailsPage(
                    items: data.lowStockItems,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _DashboardMetricCard(
            value: _formatCurrency(data.inventoryValue),
            label: 'DEPODAKİ ÜRÜN DEĞERİ',
            compact: true,
          ),
        ],
      ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlighted;
  final bool compact;
  final VoidCallback? onTap;

  const _DashboardMetricCard({
    required this.value,
    required this.label,
    this.highlighted = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: compact ? 20 : 30,
        ),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFFFFFBF7) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9E9E9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        foregroundDecoration: highlighted
            ? const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFFF9800), width: 8),
                  top: BorderSide(color: Color(0xFFFF9800), width: 6),
                ),
                borderRadius: BorderRadius.all(Radius.circular(18)),
              )
            : null,
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFF2D20),
                fontSize: compact ? 30 : 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTabButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DashboardTabButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF57C00) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFF57C00) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(selected ? 20 : 8),
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF334155),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DashboardPieCard extends StatelessWidget {
  final String title;
  final List<_PieItem> items;

  const _DashboardPieCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((item) => item.value > 0).toList();

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: visibleItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Gösterilecek veri yok',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CustomPaint(
                                painter: _PieChartPainter(visibleItems),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _PieLegend(items: visibleItems),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final List<_PieItem> items;

  const _PieLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.label}: ${item.displayValue}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<_PieItem> items;

  const _PieChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Offset.zero & size;
    var startAngle = -math.pi / 2;

    for (final item in items) {
      final sweepAngle = (item.value / total) * math.pi * 2;
      paint.color = item.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      final separator = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white;
      canvas.drawArc(rect, startAngle, sweepAngle, true, separator);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}

class _DashboardMessageCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _DashboardMessageCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFFF57C00)),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class LowStockAlertDetailsPage extends StatelessWidget {
  final List<LowStockItem> items;

  const LowStockAlertDetailsPage({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF334155)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 48),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Düşük Stok Uyarı Detayları',
          style: TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accentDark),
        ),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Düşük stok uyarısı bulunamadı',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _LowStockAlertCard(item: items[index]);
              },
            ),
    );
  }
}

class _LowStockAlertCard extends StatelessWidget {
  final LowStockItem item;

  const _LowStockAlertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final severityText =
        item.severity.toLowerCase() == 'critical' ? 'KRİTİK' : item.severity;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFFD64550), width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              _assetForDeviceType(item.deviceType),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/default-device.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.deviceType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mevcut Stok: ${item.currentStock}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Minimum: ${item.minimumThreshold}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD64550),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    severityText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
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
}

class InventoryDashboardData {
  final int totalDevices;
  final int inStockDevices;
  final int lowStockAlerts;
  final double inventoryValue;
  final List<StockByTypeItem> stockByType;
  final List<StatusBreakdownItem> statusBreakdown;
  final List<LowStockItem> lowStockItems;

  const InventoryDashboardData({
    required this.totalDevices,
    required this.inStockDevices,
    required this.lowStockAlerts,
    required this.inventoryValue,
    required this.stockByType,
    required this.statusBreakdown,
    required this.lowStockItems,
  });

  factory InventoryDashboardData.fromJson(
    Map<String, dynamic> json, {
    int? inStockOverride,
  }) {
    final totalDevices = (json['totalDevices'] as num?)?.toInt() ?? 0;
    final inStockDevices =
        inStockOverride ?? (json['inStockDevices'] as num?)?.toInt() ?? 0;

    var statusBreakdown = (json['statusBreakdown'] as List? ?? const [])
        .map((e) =>
            StatusBreakdownItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    if (inStockOverride != null && totalDevices > 0) {
      statusBreakdown = statusBreakdown
          .map(
            (item) => item.status.toLowerCase().contains('stok')
                ? StatusBreakdownItem(
                    status: item.status,
                    count: inStockOverride,
                    percentage: inStockOverride / totalDevices * 100,
                    color: item.color,
                  )
                : item,
          )
          .toList();
    }

    return InventoryDashboardData(
      totalDevices: totalDevices,
      inStockDevices: inStockDevices,
      lowStockAlerts: (json['lowStockAlerts'] as num?)?.toInt() ?? 0,
      inventoryValue: (json['inventoryValue'] as num?)?.toDouble() ?? 0,
      stockByType: (json['stockByType'] as List? ?? const [])
          .map((e) =>
              StockByTypeItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      statusBreakdown: statusBreakdown,
      lowStockItems: (json['lowStockItems'] as List? ?? const [])
          .map(
              (e) => LowStockItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class LowStockItem {
  final String deviceType;
  final int currentStock;
  final int minimumThreshold;
  final String severity;

  const LowStockItem({
    required this.deviceType,
    required this.currentStock,
    required this.minimumThreshold,
    required this.severity,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      deviceType: json['deviceType'] as String? ?? '-',
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      minimumThreshold: (json['minimumThreshold'] as num?)?.toInt() ?? 0,
      severity: json['severity'] as String? ?? 'Critical',
    );
  }
}

class StockByTypeItem {
  final String deviceType;
  final int inStock;
  final int total;

  const StockByTypeItem({
    required this.deviceType,
    required this.inStock,
    required this.total,
  });

  factory StockByTypeItem.fromJson(Map<String, dynamic> json) {
    return StockByTypeItem(
      deviceType: json['deviceType'] as String? ?? '-',
      inStock: (json['inStock'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class StatusBreakdownItem {
  final String status;
  final int count;
  final double percentage;
  final Color color;

  const StatusBreakdownItem({
    required this.status,
    required this.count,
    required this.percentage,
    required this.color,
  });

  factory StatusBreakdownItem.fromJson(Map<String, dynamic> json) {
    return StatusBreakdownItem(
      status: json['status'] as String? ?? '-',
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      color: _parseColor(json['color'] as String?),
    );
  }
}

class _PieItem {
  final String label;
  final double value;
  final String displayValue;
  final Color color;

  const _PieItem({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.color,
  });
}

Color _parseColor(String? hex) {
  final value = hex?.replaceFirst('#', '');
  if (value == null || value.length != 6) return const Color(0xFFF57C00);
  return Color(int.parse('FF$value', radix: 16));
}

const List<Color> _typeColors = [
  Color(0xFFF44336),
  Color(0xFF6AA84F),
  Color(0xFF4A90E2),
  Color(0xFFF2A33A),
  Color(0xFF8E2BB8),
  Color(0xFFE74C3C),
  Color(0xFF50B7C8),
  Color(0xFFD4E157),
  Color(0xFF795548),
  Color(0xFF607D8B),
];

String _formatCurrency(double value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final reverseIndex = rounded.length - i;
    buffer.write(rounded[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return '\$${buffer.toString()}';
}

String _assetForDeviceType(String deviceType) {
  final normalized = deviceType.toLowerCase().trim();
  const assets = {
    'hard disk': 'assets/images/Hard Disk.jpeg',
    'dokunmatik monitör': 'assets/images/Dokunmatik Monitör.png',
    'dokunmatik monitor': 'assets/images/Dokunmatik Monitör.png',
    'switch': 'assets/images/Switch.jpeg',
    'pos': 'assets/images/POS.webp',
    'bilgisayar': 'assets/images/Bilgisayar.webp',
    'barkod okuyucu': 'assets/images/Barkod Okuyucu.jpg',
    'barkod yazıcı': 'assets/images/Barkod Yazıcı.jpg',
    'barkod yazici': 'assets/images/Barkod Yazıcı.jpg',
    'yazarkasa': 'assets/images/Yazarkasa.webp',
    'ups': 'assets/images/UPS.jpg',
    'para çekmecesi': 'assets/images/Para Çekmecesi-5 Gözlü.webp',
    'para cekmecesi': 'assets/images/Para Çekmecesi-5 Gözlü.webp',
  };
  return assets[normalized] ?? 'assets/images/default-device.png';
}
