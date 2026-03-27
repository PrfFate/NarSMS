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
import '../../../../features/home/presentation/bloc/home_bloc.dart';
import '../../../../features/home/presentation/bloc/home_event.dart';
import 'backup_device_detail_page.dart';

class DepotBackupDevicesPage extends StatefulWidget {
  const DepotBackupDevicesPage({super.key});

  @override
  State<DepotBackupDevicesPage> createState() => _DepotBackupDevicesPageState();
}

class _DepotBackupDevicesPageState extends State<DepotBackupDevicesPage> {
  int _currentPage = 1;
  static const int _pageSize = 15;
  String _searchQuery = '';
  static const String _status = 'Returned'; // Depodaki yedek cihazlar için status her zaman Returned
  DeviceFilterModel _activeFilter = const DeviceFilterModel(status: _status);
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
            status: _status,
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            activeFilter: _activeFilter.isEmpty ? null : _activeFilter,
          ),
        );
  }

  void _loadDevices() {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });
    context.read<DeviceBloc>().add(
          SearchDevices(
            status: _status,
            filter: _activeFilter.isEmpty ? null : _activeFilter,
            page: _currentPage,
            pageSize: _pageSize,
            serialNumber: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
        );
  }

  void _onSearch(String query) {
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
      _searchQuery = query;
      _activeFilter = const DeviceFilterModel(status: _status);
    });

    context.read<DeviceBloc>().add(
          SearchDevices(
            serialNumber: query.trim().isEmpty ? null : query.trim(),
            status: _status,
            page: _currentPage,
            pageSize: _pageSize,
          ),
        );
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
        _activeFilter = result.copyWith(status: _status);
        _currentPage = 1;
        _isLoadingMore = false;
        _searchQuery = '';
        _searchController.clear();
      });
      
      context.read<DeviceBloc>().add(
            SearchDevices(
              status: _status,
              filter: _activeFilter,
              page: 1,
              pageSize: _pageSize,
            ),
          );
    }
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
            Row(
              children: [
                Expanded(
                  child: _buildMenuButton(
                    title: 'Depodaki Yedekler',
                    isSelected: true,
                    icon: Icons.warehouse,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuButton(
                    title: 'Atanmış Yedekler',
                    isSelected: false,
                    icon: Icons.person_pin_circle,
                    onTap: () => context.read<HomeBloc>().add(const SelectPage(AppRouter.assignedBackupDevices)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Arama ve Filtre
            Row(
              children: [
                CustomRefreshButton(
                  onPressed: _loadDevices,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchInputWidget(
                    hintText: 'Seri numarasına göre ara...',
                    onSearch: _onSearch,
                    controller: _searchController,
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _activeFilter.totalSelectedCount > 1 ? const Color(0xFFF57C00) : Colors.white,
                        border: Border.all(color: _activeFilter.totalSelectedCount > 1 ? const Color(0xFFF57C00) : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openFilterSheet(),
                          child: Center(
                            child: Icon(
                              Icons.filter_list,
                              color: _activeFilter.totalSelectedCount > 1 ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_activeFilter.totalSelectedCount > 1)
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
                              '${_activeFilter.totalSelectedCount - 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                _buildActionsMenu(context),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Liste ve Sayfalama (Infinite Scroll)
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
                        backgroundColor: Colors.red,
                      ),
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

                    return _buildDeviceList(devices, state.hasMore, state.isLoadingMore);
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

  Widget _buildMenuButton({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF57C00) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFF57C00) : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF57C00).withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final String message;
    final IconData icon;

    if (_searchQuery.isNotEmpty) {
      message = '"$_searchQuery" için sonuç bulunamadı';
      icon = Icons.search_off;
    } else if (_activeFilter.totalSelectedCount > 1) {
      message = 'Seçilen filtrelere uygun ürün bulunamadı';
      icon = Icons.filter_list_off;
    } else {
      message = 'Depoda kayıtlı yedek cihaz bulunmuyor';
      icon = Icons.inventory_2_outlined;
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
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
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
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDevices,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<DeviceEntity> devices, bool hasMore, bool isLoadingMore) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: devices.length + 1,
        separatorBuilder: (context, index) => index < devices.length - 1
            ? const Divider(height: 1)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == devices.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BackupDeviceDetailPage(device: device),
                ),
              );
              if (result == true) {
                _loadDevices();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  DeviceImageWidget(
                    deviceTypeName: device.deviceTypeName,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.deviceTypeName ?? 'Bilinmeyen Model',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.deviceSerialNumber ?? 'Seri No Yok',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        DeviceStatusBadge(
                          rawStatus: device.status,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  // Yedek cihazlar için "Detay" butonu veya sadece ok ikonu olabilir
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
          if (value == 'Yeni Yedek Ekle') {
            final result = await Navigator.pushNamed(
              context,
              AppRouter.deviceAdd,
              arguments: true, // isBackup = true
            );
            if (result == true) _loadDevices();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$value işlemi yakında eklenecek')),
            );
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'Yeni Yedek Ekle',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: menuItem(Icons.add_circle_outline, 'Yeni Yedek Ekle'),
          ),
        ],
      ),
    );
  }
}
