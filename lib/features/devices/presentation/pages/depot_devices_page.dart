import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/models/device_filter_model.dart';
import '../../../../core/widgets/device_filter_bottom_sheet.dart';
import '../../../../core/widgets/device_status_badge.dart';
import '../../../../core/widgets/pagination_widget.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../../../config/routes/app_router.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/get_device_types_usecase.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';

class DepotDevicesPage extends StatefulWidget {
  const DepotDevicesPage({super.key});

  @override
  State<DepotDevicesPage> createState() => _DepotDevicesPageState();
}

class _DepotDevicesPageState extends State<DepotDevicesPage> {
  int _currentPage = 1;
  static const int _pageSize = 15;
  String _searchQuery = '';
  static const String _status = 'InStock'; // Bu sayfa her zaman depodaki cihazları gösterir
  DeviceFilterModel _activeFilter = const DeviceFilterModel(status: _status);
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
          LoadDevices(
            status: _status,
            page: _currentPage,
            pageSize: _pageSize,
          ),
        );
  }

  void _onSearch(String query) {
    setState(() {
      _currentPage = 1;
      _searchQuery = query;
      // Status'u koruyarak filtreyi sıfırla
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

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    context.read<DeviceBloc>().add(
          SearchDevices(
            serialNumber: _searchQuery.isNotEmpty ? _searchQuery : null,
            status: _status,
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
        // Gelen filtreye her zaman status=InStock ekliyoruz
        _activeFilter = result.copyWith(status: _status);
        _currentPage = 1;
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
            // 1. Üst Kısım: Başlık
            const Text(
              'Depodaki Cihazlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

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
                // Filtre Butonu
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        // Sadece extra filtreler (status hariç) varsa turuncu yap
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
              ],
            ),
            const SizedBox(height: 16),

            // 3. Tablo / Kart Listesi ve Sayfalama
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

  Widget _buildEmptyState() {
    final String message;
    final IconData icon;

    if (_searchQuery.isNotEmpty) {
      message = '"$_searchQuery" için sonuç bulunamadı';
      icon = Icons.search_off;
    } else if (_activeFilter.totalSelectedCount > 1) {
      message = 'Seçilen filtrelere uygun cihaz bulunamadı';
      icon = Icons.filter_list_off;
    } else {
      message = 'Depoda kayıtlı cihaz bulunmuyor';
      icon = Icons.warehouse_rounded;
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

          return Container(
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.saleAdd,
                      arguments: device,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Satışa Çıkar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
