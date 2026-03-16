import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../devices/data/models/device_model.dart';
import '../../../devices/domain/entities/device_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import '../../data/models/sale_create_request.dart';
import '../../../../core/widgets/device_image_widget.dart';

class SelectedDevice {
  final DeviceEntity device;
  final TextEditingController priceController;

  SelectedDevice({required this.device, required double initialPrice})
      : priceController = TextEditingController(text: initialPrice.toString());

  void dispose() {
    priceController.dispose();
  }
}

class SaleAddPage extends StatefulWidget {
  final DeviceEntity? initialDevice;

  const SaleAddPage({super.key, this.initialDevice});

  @override
  State<SaleAddPage> createState() => _SaleAddPageState();
}

class _SaleAddPageState extends State<SaleAddPage> {
  CustomerModel? _selectedCustomer;
  final List<SelectedDevice> _selectedDevices = [];
  TextEditingController _deviceSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialDevice != null) {
      _selectedDevices.add(
        SelectedDevice(
          device: widget.initialDevice!,
          initialPrice: widget.initialDevice!.purchasePrice ?? 0.0,
        ),
      );
    }
  }
  
  void _updateInternalController(TextEditingController controller) {
    _deviceSearchController = controller;
  }
  
  bool _isPastSaled = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _deviceSearchController.dispose();
    for (var sd in _selectedDevices) {
      sd.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF57C00),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Widget _buildFieldTemplate({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Future<Iterable<CustomerModel>> _searchCustomers(String query) async {
    if (query.isEmpty) return const Iterable<CustomerModel>.empty();
    try {
      final dio = getIt<DioClient>();
      final prefs = getIt<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);
      final response = await dio.get(
        ApiConstants.customerSearch,
        queryParameters: {'page': 1, 'pageSize': 50, 'name': query},
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((e) => CustomerModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Müşteri arama hatası: $e');
    }
    return const Iterable<CustomerModel>.empty();
  }

  Future<Iterable<DeviceModel>> _searchDevices(String query) async {
    if (query.isEmpty) return const Iterable<DeviceModel>.empty();
    try {
      final dio = getIt<DioClient>();
      final prefs = getIt<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);
      final response = await dio.get(
        ApiConstants.deviceSearch,
        queryParameters: {
          'status': 'InStock',
          'page': 1,
          'pageSize': 50,
          'deviceSerialNumber': query,
        },
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((e) => DeviceModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Cihaz arama hatası: $e');
    }
    return const Iterable<DeviceModel>.empty();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormScaffold(
      title: 'Yeni Satış Ekle',
      bottomButtonText: 'Ekle',
      onBottomButtonPressed: () {
        if (_selectedCustomer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen bir müşteri seçin'), backgroundColor: Colors.red),
          );
          return;
        }
        if (_selectedDevices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen en az bir cihaz ekleyin'), backgroundColor: Colors.red),
          );
          return;
        }

        final request = SaleCreateRequest(
          customerId: _selectedCustomer!.id ?? 0,
          isPastSaled: _isPastSaled,
          saleDate: _isPastSaled ? _selectedDate.toIso8601String() : null,
          items: _selectedDevices.map((sd) => SaleCreateItemRequest(
            deviceId: sd.device.id,
            price: double.tryParse(sd.priceController.text) ?? 0.0,
          )).toList(),
        );

        context.read<SaleBloc>().add(CreateSale(request));
      },
      body: BlocListener<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state is SaleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Satış başarıyla oluşturuldu'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is SaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Müşteri Autocomplete
              _buildFieldTemplate(
                label: 'Müşteri',
                child: Row(
                  children: [
                    Expanded(
                      child: Autocomplete<CustomerModel>(
                        optionsBuilder: (TextEditingValue textEditingValue) => _searchCustomers(textEditingValue.text),
                        displayStringForOption: (CustomerModel option) => option.name,
                        onSelected: (CustomerModel selection) {
                          setState(() {
                            _selectedCustomer = selection;
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Müşteri adı ile ara...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFF57C00)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.customerAdd);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF57C00), // Turuncu artı butonu
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Geçmiş Tarihli Satış Checkbox
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isPastSaled,
                      activeColor: const Color(0xFFF57C00),
                      side: BorderSide(color: Colors.grey.shade400, width: 2),
                      onChanged: (value) {
                        setState(() {
                          _isPastSaled = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPastSaled = !_isPastSaled;
                      });
                    },
                    child: const Text(
                      'Geçmiş Tarihli Satış Ekle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_isPastSaled) ...[
                const SizedBox(height: 16),
                _buildFieldTemplate(
                  label: 'Satış Tarihi',
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _isPastSaled ? AppColors.accentDark : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.calendar_today, size: 20, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),

              // Cihaz Autocomplete
              _buildFieldTemplate(
                label: 'Cihaz Ekle',
                child: Row(
                  children: [
                    Expanded(
                      child: Autocomplete<DeviceModel>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const Iterable<DeviceModel>.empty();
                          return _searchDevices(textEditingValue.text).then((items) {
                            // Zaten eklenmiş olanları listeden çıkar
                            final selectedIds = _selectedDevices.map((sd) => sd.device.id).toSet();
                            return items.where((d) => !selectedIds.contains(d.id));
                          });
                        },
                        displayStringForOption: (DeviceModel option) => 
                          '${option.deviceTypeName} (${option.deviceSerialNumber})',
                        onSelected: (DeviceModel selection) {
                          setState(() {
                            _selectedDevices.add(SelectedDevice(
                              device: selection, 
                              initialPrice: selection.purchasePrice ?? 0.0,
                            ));
                          });
                          // Autocomplete'in seçilen metni kutuya yazmasını engellemek için
                          // bir sonraki frame'de temizliyoruz.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _deviceSearchController.clear();
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          // Dahili controller'ı kendi controller'ımıza bağlıyoruz
                          if (_deviceSearchController != controller) {
                            // Sadece bir kez veya referans değişince atama yapıyoruz
                            // Ama dikkat: dispose etmemek gerekebilir çünkü Autocomplete yönetiyor.
                            _updateInternalController(controller);
                          }
                          
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Seri numarasına göre ara...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFF57C00)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, AppRouter.deviceAdd);
                        if (result == true) {
                           // Opsiyonel: Yeni cihaz eklendikten sonra bir işlem yapılabilir
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF57C00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Seçilen Cihazlar Listesi
              if (_selectedDevices.isNotEmpty) ...[
                const Text(
                  'Seçilen Cihazlar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedDevices.length,
                  itemBuilder: (context, index) {
                    final selectedDevice = _selectedDevices[index];
                    final device = selectedDevice.device;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Cihaz Görseli
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[50],
                                child: DeviceImageWidget(
                                  deviceTypeName: device.deviceTypeName,
                                  size: 60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Cihaz Bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.deviceTypeName ?? 'Bilinmeyen Model',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SN: ${device.deviceSerialNumber}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Fiyat Inputu
                            SizedBox(
                              width: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Fiyat (\$)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slate)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: selectedDevice.priceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    onChanged: (_) => setState(() {}), // Toplamı güncellemek için
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sil Butonu
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _selectedDevices[index].dispose();
                                  _selectedDevices.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Özet Alanı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.navy.withAlpha(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Toplam Cihaz', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                          Text('${_selectedDevices.length} Adet', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Toplam Tutar', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                          Text(
                            '${_selectedDevices.fold(0.0, (sum, item) => sum + (double.tryParse(item.priceController.text) ?? 0.0)).toStringAsFixed(2)} \$', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF57C00)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


