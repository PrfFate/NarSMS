import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../features/home/presentation/bloc/home_bloc.dart';
import '../../../../features/home/presentation/bloc/home_event.dart';
import '../../../../core/widgets/device_status_badge.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../../../core/widgets/pagination_widget.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../../core/widgets/device_filter_bottom_sheet.dart';
import '../../../../core/models/device_filter_model.dart';
import '../../domain/entities/device_entity.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/get_device_types_usecase.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';
import 'backup_device_detail_page.dart';

class AssignedBackupDevicesPage extends StatefulWidget {
  const AssignedBackupDevicesPage({super.key});

  @override
  State<AssignedBackupDevicesPage> createState() =>
      _AssignedBackupDevicesPageState();
}

class _AssignedBackupDevicesPageState extends State<AssignedBackupDevicesPage> {
  int _currentPage = 1;
  static const int _pageSize = 15;
  String _searchQuery = '';
  DeviceFilterModel _activeFilter =
      const DeviceFilterModel(status: 'AssignedBackup');
  List<String> _availableDeviceTypes = [];
  final TextEditingController _searchController = TextEditingController();

  final _deviceTypesUseCase = GetIt.instance<GetDeviceTypesUseCase>();

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDevices() {
    context.read<DeviceBloc>().add(
          LoadAssignedBackupDevices(
            isReturned: false,
            serialNumber: _searchQuery.isNotEmpty ? _searchQuery : null,
            filter: _activeFilter.isEmpty ? null : _activeFilter,
            page: _currentPage,
            pageSize: _pageSize,
          ),
        );
  }

  void _onSearch(String query) {
    setState(() {
      _currentPage = 1;
      _searchQuery = query;
    });

    context.read<DeviceBloc>().add(
          LoadAssignedBackupDevices(
            isReturned: false,
            serialNumber: query.trim().isEmpty ? null : query.trim(),
            filter: _activeFilter.isEmpty ? null : _activeFilter,
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
        _activeFilter = result.copyWith(status: 'AssignedBackup');
        _currentPage = 1;
        _searchQuery = '';
        _searchController.clear();
      });

      _loadDevices();
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) {
        if (state is DeviceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve Menü Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yedek Cihaz Yönetimi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRouter.deviceAdd,
                      arguments: true, // isBackup = true
                    );
                    if (result == true) _loadDevices();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Yeni Yedek',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // İki ana menü seçeneği (Butonlar)
            Row(
              children: [
                Expanded(
                  child: _buildMenuButton(
                    title: 'Depodaki Yedekler',
                    isSelected: false,
                    icon: Icons.warehouse,
                    onTap: () => context
                        .read<HomeBloc>()
                        .add(const SelectPage(AppRouter.depotBackupDevices)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMenuButton(
                    title: 'Atanmış Yedekler',
                    isSelected: true,
                    icon: Icons.person_pin_circle,
                    onTap: () {}, // Zaten buradayız
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

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
                        color: _activeFilter.totalSelectedCount > 1
                            ? const Color(0xFFF57C00)
                            : Colors.white,
                        border: Border.all(
                            color: _activeFilter.totalSelectedCount > 1
                                ? const Color(0xFFF57C00)
                                : Colors.grey[300]!),
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
                              color: _activeFilter.totalSelectedCount > 1
                                  ? Colors.white
                                  : Colors.grey[700],
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
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<DeviceBloc, DeviceState>(
                builder: (context, state) {
                  if (state is DeviceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DeviceLoaded) {
                    final devices = state.result.items;
                    if (devices.isEmpty) return _buildEmptyState();

                    return Column(
                      children: [
                        Expanded(child: _buildDeviceList(devices)),
                        const SizedBox(height: 8),
                        PaginationWidget(
                          currentPage: state.result.page,
                          totalPages: state.result.totalPages,
                          totalItems: state.result.totalCount,
                          itemsPerPage: _pageSize,
                          onPageChanged: _onPageChanged,
                        ),
                      ],
                    );
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
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: Color(0xFF3F51B5)),
            SizedBox(height: 16),
            Text(
              'Atanmış yedek cihaz bulunmuyor',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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

  Widget _buildDeviceList(List<DeviceEntity> devices) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: devices.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final device = devices[index];

          return InkWell(
            onTap: () async {
              final bloc = context.read<DeviceBloc>();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: bloc,
                    child: BackupDeviceDetailPage(
                      device: device,
                      isAssignedView: true,
                    ),
                  ),
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
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              device.deviceSerialNumber ?? 'Seri No Yok',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            if (device.customerName != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.person,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  device.customerName!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        DeviceStatusBadge(
                          rawStatus: device.status,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
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
}
