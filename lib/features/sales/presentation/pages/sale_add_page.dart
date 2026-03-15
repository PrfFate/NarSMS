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

class SaleAddPage extends StatefulWidget {
  const SaleAddPage({super.key});

  @override
  State<SaleAddPage> createState() => _SaleAddPageState();
}

class _SaleAddPageState extends State<SaleAddPage> {
  CustomerModel? _selectedCustomer;
  Map<String, dynamic>? _selectedDevice;
  
  bool _isPastSaled = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
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

  Future<Iterable<Map<String, dynamic>>> _searchDevices(String query) async {
    if (query.isEmpty) return const Iterable<Map<String, dynamic>>.empty();
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
        return items.cast<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      debugPrint('Cihaz arama hatası: $e');
    }
    return const Iterable<Map<String, dynamic>>.empty();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormScaffold(
      title: 'Yeni Satış Ekle',
      bottomButtonText: 'Ekle',
      onBottomButtonPressed: () {
        // TODO: API Kayıt İşlemi
        debugPrint('Kayıt için seçilen Müşteri ID: ${_selectedCustomer?.id}');
        debugPrint('Kayıt için seçilen Cihaz SN: ${_selectedDevice?['serialNumber']}');
        Navigator.pop(context, true);
      },
      body: SingleChildScrollView(
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
              label: 'Cihaz',
              child: Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) => _searchDevices(textEditingValue.text),
                displayStringForOption: (Map<String, dynamic> option) => option['serialNumber'] ?? 'Bilinmeyen Seri No',
                onSelected: (Map<String, dynamic> selection) {
                  setState(() {
                    _selectedDevice = selection;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
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
          ],
        ),
      ),
    );
  }
}


