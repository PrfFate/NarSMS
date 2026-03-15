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

  // Cihaz tiplerini doğrudan DI üzerinden çekeriz.
  // DeviceBloc'a hiç dokunmaz → DeviceLoaded state'i bozulmaz.
  final _deviceTypesUseCase = GetIt.instance<GetDeviceTypesUseCase>();

  @override
  void initState() {
    super.initState();
    _loadDevices(); // Sadece cihaz listesi yüklenir, başka bir event tetiklenmez.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDevices() {
    if (_activeFilter.isNotEmpty) {
      // Aktif filtre varsa filtreyi koruyarak yenile
      context.read<DeviceBloc>().add(
            FilterDevices(filter: _activeFilter, page: _currentPage, pageSize: _pageSize),
          );
    } else if (_searchQuery.isNotEmpty) {
      // Aktif arama varsa aramayı koruyarak yenile
      context.read<DeviceBloc>().add(
            SearchDevices(
              serialNumber: _searchQuery,
              page: _currentPage,
              pageSize: _pageSize,
            ),
          );
    } else {
      // Hiçbir şey yoksa normal listele
      context.read<DeviceBloc>().add(
            LoadDevices(page: _currentPage, pageSize: _pageSize),
          );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _currentPage = 1;
      _searchQuery = query;
      _activeFilter = DeviceFilterModel.empty; // Arama başlayınca filtreyi sıfırla
    });

    if (query.trim().isEmpty) {
      _loadDevices();
    } else {
      context.read<DeviceBloc>().add(
            SearchDevices(
              serialNumber: query.trim(),
              page: _currentPage,
              pageSize: _pageSize,
            ),
          );
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    if (_activeFilter.isEmpty && _searchQuery.isEmpty) {
      _loadDevices();
    } else {
      context.read<DeviceBloc>().add(
            SearchDevices(
              serialNumber: _searchQuery.isNotEmpty ? _searchQuery : null,
              filter: _activeFilter.isEmpty ? null : _activeFilter,
              page: _currentPage,
              pageSize: _pageSize,
            ),
          );
    }
  }

  Future<void> _openFilterSheet() async {
    // Cihaz tiplerini ilk açılışta bir kez çek; sonraki açılışlarda cache'den gelir.
    // DeviceBloc'a hiç dokunmaz — DeviceLoaded state bozulmaz.
    if (_availableDeviceTypes.isEmpty) {
      final result = await _deviceTypesUseCase();
      result.fold(
        (_) {}, // Hata olursa boş liste ile devam et
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
        _searchQuery = '';
        _searchController.clear();
      });
      if (_activeFilter.isEmpty) {
        _loadDevices();
      } else {
        context.read<DeviceBloc>().add(
              FilterDevices(filter: _activeFilter, page: 1, pageSize: _pageSize),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceBloc, DeviceState>(
      listener: (context, state) {
        // Sadece hata bildirimi — başka hiçbir state burada işlenmez.
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
            // 1. Üst Kısım: Başlık ve İşlem Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tüm Cihazlar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tüm Cihazlar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Cihaz ekle
                },
                icon: const Icon(Icons.add, size: 20, color: Colors.white),
                label: const Text('Yeni Cihaz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Açılır (Dropdown) İşlemler Menüsü
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: PopupMenuButton<String>(
                        tooltip: 'Diğer İşlemler',
                        icon: const Icon(Icons.more_vert, color: Colors.black54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        offset: const Offset(0, 48),
                        onSelected: (value) async {
                          if (value == 'Yeni Cihaz Ekle') {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRouter.deviceAdd,
                            );
                            if (result == true) _loadDevices(); // Geri gelince listeyi yenile
                          } else if (value == 'Toplu Cihaz Ekle') {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRouter.deviceBulkAdd,
                            );
                            if (result == true) _loadDevices();
                          } else if (value == 'Cihaz Modelleri') {
                            await Navigator.pushNamed(
                              context,
                              AppRouter.deviceModels,
                            );
                            _loadDevices();
                          } else if (value == 'Tedarikçiler') {
                            await Navigator.pushNamed(
                              context,
                              AppRouter.suppliers,
                            );
                            _loadDevices();
                          } else {
                            // TODO: Diğer menü aksiyonları buraya gelecek
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$value işlemi yakında eklenecek')),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          // Ortak tekrar kullanılan Buton (Card) görünümü yaratıcı fonksiyon
                          Widget buildMenuButton(IconData icon, String text) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF57C00).withAlpha(15), // Turuncunun hafif saydam tonu (Arka plan)
                                border: Border.all(color: const Color(0xFFF57C00).withAlpha(60)), // Hafif turuncu kenarlık
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, size: 20, color: const Color(0xFFF57C00)),
                                  const SizedBox(width: 12),
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      color: Color(0xFFF57C00),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'Yeni Cihaz Ekle',
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Dış boşluklar
                              child: buildMenuButton(Icons.add_circle_outline, 'Yeni Cihaz Ekle'),
                            ),
                            PopupMenuItem<String>(
                              value: 'Toplu Cihaz Ekle',
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: buildMenuButton(Icons.library_add_outlined, 'Toplu Cihaz Ekle'),
                            ),
                            PopupMenuItem<String>(
                              value: 'Cihaz Modelleri',
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: buildMenuButton(Icons.category_outlined, 'Cihaz Modelleri'),
                            ),
                            PopupMenuItem<String>(
                              value: 'Tedarikçiler',
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: buildMenuButton(Icons.local_shipping_outlined, 'Tedarikçiler'),
                            ),
                          ];
                        },
                      ),
                    ),
                  ],
                ),
              ],
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
                        color: _activeFilter.totalSelectedCount > 0 ? const Color(0xFFF57C00) : Colors.white,
                        border: Border.all(color: _activeFilter.totalSelectedCount > 0 ? const Color(0xFFF57C00) : Colors.grey[300]!),
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
                              color: _activeFilter.totalSelectedCount > 0 ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_activeFilter.totalSelectedCount > 0)
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
                              '${_activeFilter.totalSelectedCount}',
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
    // Bağlama göre farklı mesaj göster
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

          return InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.deviceDetail,
                arguments: device,
              );

              if (result == true) {
                _loadDevices();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.transparent, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KARTIN ÜST KISMI (Daima Görünür) ---
                  Row(
                    children: [
                      // Sol Fotoğraf / Avatar
                      DeviceImageWidget(
                        deviceTypeName: device.deviceTypeName,
                        size: 48,
                      ),
                      const SizedBox(width: 14),

                      // Başlık & Alt Başlık
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
                          ],
                        ),
                      ),
                      
                      // Durum Etiketi (Badge) ve Ok (İleri) İşareti
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DeviceStatusBadge(
                            rawStatus: device.status,
                            compact: true,
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
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
