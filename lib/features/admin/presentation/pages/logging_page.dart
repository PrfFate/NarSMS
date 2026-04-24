import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../models/movement_log_item.dart';
import 'log_detail_page.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key});

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  static const int _pageSize = 15;
  static const List<String> _movementTypes = [
    'Sale',
    'Shipment',
    'Return',
    'BackupReturn',
    'BackupAssign',
  ];
  static const Map<String, String> _movementTypeLabels = {
    'Sale': 'Satış',
    'Shipment': 'Sevkiyat',
    'Return': 'İade',
    'Purchase': 'Satın Alma',
    'BackupReturn': 'Yedek İade',
    'BackupAssign': 'Yedek Atama',
  };

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<MovementLogItem> _logs = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _showScrollToTop = false;

  String _searchQuery = '';
  String _resolvedUsername = '';
  String? _selectedMovementType;
  DateTime? _startDate;
  DateTime? _endDate;

  Dio get _dio => getIt<DioClient>().dio;
  SharedPreferences get _prefs => getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadLogs();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Options _authOptions() {
    final token = _prefs.getString(StorageConstants.accessToken);
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  void _onScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }

    if (!_scrollController.hasClients ||
        !_hasMore ||
        _isLoading ||
        _isLoadingMore) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadLogs(loadMore: true);
    }
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is List) return {'items': raw, 'totalCount': raw.length};
    if (raw is Map<String, dynamic>) {
      if (raw['items'] is List) return raw;
      final nested = raw['data'] ?? raw['result'] ?? raw['value'];
      if (nested is Map<String, dynamic>) return nested;
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return raw;
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final direct = raw['items'];
      if (direct is List) return direct;
      final nested = raw['data'] ?? raw['result'] ?? raw['value'];
      if (nested is List) return nested;
      if (nested is Map<String, dynamic> && nested['items'] is List) {
        return nested['items'] as List;
      }
    }
    return const [];
  }

  Future<String> _resolveUsername(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return '';

    try {
      final response = await _dio.get(
        ApiConstants.userSearch,
        queryParameters: {
          'page': 1,
          'pageSize': 10,
          'username': trimmed,
        },
        options: _authOptions(),
      );

      final usernames = _extractList(response.data)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((e) => (e['username'] as String?)?.trim() ?? '')
          .where((u) => u.isNotEmpty)
          .toList();

      if (usernames.isEmpty) return trimmed;

      final exact =
          usernames.where((u) => u.toLowerCase() == trimmed.toLowerCase());
      if (exact.isNotEmpty) return exact.first;
      if (usernames.length == 1) return usernames.first;
      return trimmed;
    } catch (_) {
      return trimmed;
    }
  }

  Future<void> _loadLogs({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      setState(() {
        _isLoadingMore = true;
        _currentPage += 1;
      });
    } else {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final response = await _dio.get(
        ApiConstants.deviceMovementsPaged,
        queryParameters: {
          'page': _currentPage,
          'pageSize': _pageSize,
          if (_selectedMovementType != null)
            'movementType': _selectedMovementType,
          if (_resolvedUsername.trim().isNotEmpty)
            'username': _resolvedUsername.trim(),
          if (_startDate != null)
            'startDate': DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
            ).toUtc().toIso8601String(),
          if (_endDate != null)
            'endDate': DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              23,
              59,
              59,
              999,
            ).toUtc().toIso8601String(),
        },
        options: _authOptions(),
      );

      final json = _extractMap(response.data);
      final items = _extractList(response.data)
          .map((e) =>
              MovementLogItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (!mounted) return;
      setState(() {
        _totalCount = (json['totalCount'] as num?)?.toInt() ?? items.length;
        _logs = loadMore ? [..._logs, ...items] : items;
        _hasMore = _logs.length < _totalCount;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      if (loadMore) _currentPage = (_currentPage - 1).clamp(1, _currentPage);
      final status = e.response?.statusCode;
      final message =
          e.response?.data?.toString() ?? e.message ?? 'Bilinmeyen hata';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loglar alınamadı ($status): $message'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (loadMore) _currentPage = (_currentPage - 1).clamp(1, _currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loglar alınamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      _resolvedUsername = await _resolveUsername(query);
      if (mounted) _loadLogs();
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_LogFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? tempMovement = _selectedMovementType;
        DateTime? tempStart = _startDate;
        DateTime? tempEnd = _endDate;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedCount = (tempMovement == null ? 0 : 1) +
                (tempStart == null ? 0 : 1) +
                (tempEnd == null ? 0 : 1);

            return FilterBottomSheetScaffold(
              title: 'Log Filtreleri',
              selectedCount: selectedCount,
              maxHeightFraction: 0.9,
              onClear: () {
                setSheetState(() {
                  tempMovement = null;
                  tempStart = null;
                  tempEnd = null;
                });
              },
              onApply: () => Navigator.pop(
                context,
                _LogFilterResult(
                  movementType: tempMovement,
                  startDate: tempStart,
                  endDate: tempEnd,
                ),
              ),
              applyLabel:
                  selectedCount > 0 ? 'Uygula ($selectedCount)' : 'Uygula',
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  DropdownButtonFormField<String?>(
                    value: tempMovement,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: 'Hareket Tipi',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tümü'),
                      ),
                      ..._movementTypes.map(
                        (type) => DropdownMenuItem<String?>(
                          value: type,
                          child: Text(_movementTypeLabels[type] ?? type),
                        ),
                      ),
                    ],
                    onChanged: (val) => setSheetState(() => tempMovement = val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempStart ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              helpText: 'Başlangıç Tarihi',
                            );
                            if (picked == null) return;
                            setSheetState(() {
                              tempStart = picked;
                              if (tempEnd != null &&
                                  tempEnd!.isBefore(tempStart!)) {
                                tempEnd = tempStart;
                              }
                            });
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tempStart == null
                                        ? 'Başlangıç'
                                        : '${tempStart!.day.toString().padLeft(2, '0')}.${tempStart!.month.toString().padLeft(2, '0')}.${tempStart!.year}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  tempEnd ?? tempStart ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              helpText: 'Bitiş Tarihi',
                            );
                            if (picked == null) return;
                            setSheetState(() => tempEnd = picked);
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tempEnd == null
                                        ? 'Bitiş'
                                        : '${tempEnd!.day.toString().padLeft(2, '0')}.${tempEnd!.month.toString().padLeft(2, '0')}.${tempEnd!.year}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      _selectedMovementType = result.movementType;
      _startDate = result.startDate;
      _endDate = result.endDate;
    });
    _loadLogs();
  }

  Widget _buildFilterButton() {
    final selectedCount = (_selectedMovementType == null ? 0 : 1) +
        (_startDate == null ? 0 : 1) +
        (_endDate == null ? 0 : 1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selectedCount > 0 ? AppColors.primary : Colors.white,
            border: Border.all(
              color:
                  selectedCount > 0 ? AppColors.primary : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openFilterSheet,
              child: Center(
                child: Icon(
                  Icons.filter_list,
                  color:
                      selectedCount > 0 ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ),
        if (selectedCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$selectedCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final bool hasFilter = _selectedMovementType != null ||
        _startDate != null ||
        _endDate != null ||
        _searchQuery.trim().isNotEmpty;

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? Icons.search_off : Icons.article_outlined,
              size: 64,
              color: const Color(0xFFF57C00),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'Seçilen kriterlere uygun log bulunamadı'
                  : 'Henüz log kaydı bulunmuyor',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _logs.length + 1,
        separatorBuilder: (context, index) => index < _logs.length - 1
            ? const Divider(height: 1)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == _logs.length) {
            if (_isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (!_hasMore && _logs.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Tüm ${_logs.length} log listelendi',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final item = _logs[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LogDetailPage(item: item),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.article_outlined,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.deviceTypeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SN: ${item.deviceSerialNumber}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _movementTypeLabels[item.movementType] ??
                              item.movementType,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  );
                }
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Başa Dön',
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CustomRefreshButton(onPressed: _loadLogs),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchInputWidget(
                    hintText: 'Kullanıcıya göre ara...',
                    onSearch: _onSearch,
                    controller: _searchController,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading && _logs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? _buildEmptyState()
                      : _buildLogList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogFilterResult {
  final String? movementType;
  final DateTime? startDate;
  final DateTime? endDate;

  const _LogFilterResult({
    this.movementType,
    this.startDate,
    this.endDate,
  });
}
