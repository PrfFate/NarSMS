import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/models/device_filter_model.dart';
import '../../../../core/widgets/device_filter_bottom_sheet.dart';
import '../../../../core/widgets/device_status_badge.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../../../config/routes/app_router.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/get_device_types_usecase.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  int _currentPage = 1;
  static const int _pageSize = 15;
  String _searchQuery = '';
  DeviceFilterModel _activeFilter = DeviceFilterModel.empty;
  List<String> _availableDeviceTypes = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;
  bool _showScrollToTop = false;

  final _deviceTypesUseCase = GetIt.instance<GetDeviceTypesUseCase>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollListener);
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollListener() {
    _onScroll();
    _updateFabVisibility();
  }

  void _updateFabVisibility() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadNextPage();
    }
  }

  void _loadNextPage() {
    final state = context.read<DeviceBloc>().state;
    if (state is! DeviceLoaded) return;
    if (!state.hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    context.read<DeviceBloc>().add(
          LoadMoreDevices(
            nextPage: _currentPage,
            existingDevices: state.devices,
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            activeFilter: _activeFilter.isNotEmpty ? _activeFilter : null,
          ),
        );
  }

  void _loadDevices() {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });
    if (_activeFilter.isNotEmpty) {
      context.read<DeviceBloc>().add(
            FilterDevices(filter: _activeFilter, page: 1, pageSize: _pageSize),
          );
    } else if (_searchQuery.isNotEmpty) {
      context.read<DeviceBloc>().add(
            SearchDevices(
                serialNumber: _searchQuery, page: 1, pageSize: _pageSize),
          );
    } else {
      context.read<DeviceBloc>().add(LoadDevices(page: 1, pageSize: _pageSize));
    }
  }

  void _onSearch(String query) {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
      _searchQuery = query;
      _activeFilter = DeviceFilterModel.empty;
    });

    if (query.trim().isEmpty) {
      _loadDevices();
    } else {
      context.read<DeviceBloc>().add(
            SearchDevices(
                serialNumber: query.trim(), page: 1, pageSize: _pageSize),
          );
    }
  }

  Future<void> _openFilterSheet() async {
    if (_availableDeviceTypes.isEmpty) {
      final result = await _deviceTypesUseCase();
      result.fold(
        (_) {},
        (types) {
          if (mounted) setState(() => _availableDeviceTypes = types);
        },
      );
    }

    if (!mounted) return;

    final result = await DeviceFilterBottomSheet.show(
      context: context,
      currentFilter: _activeFilter,
      availableDeviceTypes: _availableDeviceTypes,
    );
    if (result != null) {
      setState(() {
        _activeFilter = result;
        _currentPage = 1;
        _isLoadingMore = false;
        _searchQuery = '';
        _searchController.clear();
      });
      if (_activeFilter.isEmpty) {
        _loadDevices();
      } else {
        if (mounted) {
          context.read<DeviceBloc>().add(
                FilterDevices(filter: _activeFilter, page: 1, pageSize: _pageSize),
              );
        }
      }
    }
  }

  // ────────────────────────────────────
  // BUILD
  // ────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Scroll-to-top FAB: 200px+ scroll'da görünür
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              tooltip: 'Başa Dön',
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Toolbar: Yenile | Arama | ⋮Menü | Filtre ──
            Row(
              children: [
                CustomRefreshButton(onPressed: _loadDevices),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchInputWidget(
                    hintText: 'Seri numarasına göre ara...',
                    onSearch: _onSearch,
                    controller: _searchController,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 8),
                _buildFilterButton(),
                const SizedBox(width: 8),
                _buildActionsMenu(context),
              ],
            ),
            const SizedBox(height: 12),

            // ── Liste (Infinite Scroll) ──
            Expanded(
              child: BlocConsumer<DeviceBloc, DeviceState>(
                listener: (context, state) {
                  if (state is DeviceLoaded && !state.isLoadingMore) {
                    setState(() => _isLoadingMore = false);
                  }
                  if (state is DeviceError) {
                    setState(() => _isLoadingMore = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is DeviceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is DeviceLoaded) {
                    final devices = state.devices;
                    if (devices.isEmpty) return _buildEmptyState();
                    return _buildDeviceList(
                        devices, state.hasMore, state.isLoadingMore);
                  }
                  if (state is DeviceError) {
                    return _buildErrorState(state.message);
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────

  /// ⋮ İşlemler açılır menüsü
  Widget _buildActionsMenu(BuildContext context) {
    Widget menuItem(IconData icon, String text) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF57C00).withAlpha(15),
          border: Border.all(color: const Color(0xFFF57C00).withAlpha(60)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFF57C00)),
            const SizedBox(width: 12),
            Text(text,
                style: const TextStyle(
                    color: Color(0xFFF57C00),
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Diğer İşlemler',
        icon: const Icon(Icons.more_vert, color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, 48),
        onSelected: (value) async {
          if (value == 'Yeni Cihaz Ekle') {
            final result =
                await Navigator.pushNamed(context, AppRouter.deviceAdd);
            if (result == true) _loadDevices();
          } else if (value == 'Toplu Cihaz Ekle') {
            final result =
                await Navigator.pushNamed(context, AppRouter.deviceBulkAdd);
            if (result == true) _loadDevices();
          } else if (value == 'Cihaz Modelleri') {
            await Navigator.pushNamed(context, AppRouter.deviceModels);
            _loadDevices();
          } else if (value == 'Tedarikçiler') {
            await Navigator.pushNamed(context, AppRouter.suppliers);
            _loadDevices();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value işlemi yakında eklenecek')),
            );
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'Yeni Cihaz Ekle',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: menuItem(Icons.add_circle_outline, 'Yeni Cihaz Ekle'),
          ),
          PopupMenuItem<String>(
            value: 'Toplu Cihaz Ekle',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: menuItem(Icons.library_add_outlined, 'Toplu Cihaz Ekle'),
          ),
          PopupMenuItem<String>(
            value: 'Cihaz Modelleri',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: menuItem(Icons.category_outlined, 'Cihaz Modelleri'),
          ),
          PopupMenuItem<String>(
            value: 'Tedarikçiler',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: menuItem(Icons.local_shipping_outlined, 'Tedarikçiler'),
          ),
        ],
      ),
    );
  }

  /// Filtre butonu (badge ile)
  Widget _buildFilterButton() {
    final count = _activeFilter.totalSelectedCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: count > 0 ? const Color(0xFFF57C00) : Colors.white,
            border: Border.all(
                color: count > 0 ? const Color(0xFFF57C00) : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openFilterSheet,
              child: Center(
                child: Icon(Icons.filter_list,
                    color: count > 0 ? Colors.white : Colors.grey[700]),
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
              child: Center(
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final String message;
    final IconData icon;

    if (_searchQuery.isNotEmpty) {
      message = '"$_searchQuery" için sonuç bulunamadı';
      icon = Icons.search_off;
    } else if (_activeFilter.isNotEmpty) {
      message = 'Seçilen filtrelere uygun cihaz bulunamadı';
      icon = Icons.filter_list_off;
    } else {
      message = 'Henüz kayıtlı cihaz bulunmuyor';
      icon = Icons.devices_other;
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFF57C00)),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDevices,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  foregroundColor: Colors.white),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(
      List<DeviceEntity> devices, bool hasMore, bool isLoadingMore) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: devices.length + 1,
        separatorBuilder: (context, index) =>
            index < devices.length - 1
                ? const Divider(height: 1)
                : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          // Alt gösterge
          if (index == devices.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (!hasMore && devices.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Tüm ${devices.length} cihaz listelendi',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final device = devices[index];
          return InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.deviceDetail,
                arguments: device,
              );
              if (result == true) _loadDevices();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  DeviceImageWidget(
                      deviceTypeName: device.deviceTypeName, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.deviceTypeName ?? 'Bilinmeyen Model',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.deviceSerialNumber ?? 'Seri No Yok',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DeviceStatusBadge(
                          rawStatus: device.status, compact: true),
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
}
