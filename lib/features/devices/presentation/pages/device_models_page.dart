import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/pagination_widget.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../bloc/device_type_bloc.dart';
import '../bloc/device_type_event.dart';
import '../bloc/device_type_state.dart';

class DeviceModelsPage extends StatefulWidget {
  const DeviceModelsPage({super.key});

  @override
  State<DeviceModelsPage> createState() => _DeviceModelsPageState();
}

class _DeviceModelsPageState extends State<DeviceModelsPage> {
  int _currentPage = 1;
  final int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _loadDeviceTypes();
  }

  void _loadDeviceTypes() {
    context.read<DeviceTypeBloc>().add(LoadDeviceTypesPaged(
      page: _currentPage,
      pageSize: _pageSize,
    ));
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadDeviceTypes();
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Modeli Sil', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('"$name" modelini silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DeviceTypeBloc>().add(DeleteDeviceType(id));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Cihaz Modelleri', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF57C00), height: 2.0),
        ),
      ),
      body: BlocListener<DeviceTypeBloc, DeviceTypeState>(
        listener: (context, state) {
          if (state is DeviceTypeActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            _loadDeviceTypes(); // Yenile
          } else if (state is DeviceTypeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CustomRefreshButton(onPressed: _loadDeviceTypes),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, AppRouter.deviceModelAdd);
                      if (result != null) {
                        _loadDeviceTypes();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Model Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: BlocBuilder<DeviceTypeBloc, DeviceTypeState>(
                builder: (context, state) {
                  if (state is DeviceTypeLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFF57C00)));
                  }

                  if (state is DeviceTypeLoaded) {
                    final types = state.result.items;

                    if (types.isEmpty) {
                      return const Center(
                        child: Text('Kayıtlı cihaz modeli bulunamadı.', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: types.length,
                            itemBuilder: (context, index) {
                              final type = types[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  leading: DeviceImageWidget(
                                    deviceTypeName: type.name,
                                    size: 40,
                                  ),
                                  title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('ID: ${type.id}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                        tooltip: 'Düzenle',
                                        onPressed: () async {
                                          final result = await Navigator.pushNamed(
                                            context,
                                            AppRouter.deviceModelAdd,
                                            arguments: type,
                                          );
                                          if (result == true) {
                                            _loadDeviceTypes();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        tooltip: 'Sil',
                                        onPressed: () => _showDeleteDialog(type.id, type.name),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: PaginationWidget(
                            currentPage: state.result.page,
                            totalPages: state.result.totalPages,
                            onPageChanged: _onPageChanged,
                            itemsPerPage: state.result.pageSize,
                            totalItems: state.result.totalCount,
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
