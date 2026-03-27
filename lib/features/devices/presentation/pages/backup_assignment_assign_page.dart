import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../sales/domain/entities/carrier_entity.dart';
import '../../../sales/data/models/carrier_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/device_entity.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';

class BackupAssignmentAssignPage extends StatefulWidget {
  final DeviceEntity device;

  const BackupAssignmentAssignPage({super.key, required this.device});

  @override
  State<BackupAssignmentAssignPage> createState() =>
      _BackupAssignmentAssignPageState();
}

class _BackupAssignmentAssignPageState
    extends State<BackupAssignmentAssignPage> {
  CustomerModel? _selectedCustomer;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _trackingNumberController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now();

  bool _isCarrierMode = true;
  CarrierEntity? _selectedCarrier;
  UserEntity? _selectedFielder;

  List<CarrierEntity> _carriers = [];
  List<UserEntity> _fielders = [];
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _trackingNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final dio = GetIt.instance<DioClient>();
      final prefs = GetIt.instance<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);
      final options = Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'});

      final carrierRes = await dio.get(
        ApiConstants.carrierAll,
        queryParameters: {'page': 1, 'pageSize': 100},
        options: options,
      );
      if (carrierRes.statusCode == 200) {
        final dynamic cData = carrierRes.data;
        List<dynamic> cList = [];
        if (cData is List) cList = cData;
        else if (cData is Map<String, dynamic> && cData['value'] is List) cList = cData['value'];
        else if (cData is Map<String, dynamic> && cData['items'] is List) cList = cData['items'];
        
        _carriers = cList.map((e) => CarrierModel.fromJson(e)).toList();
      }

      final fielderRes = await dio.get(
        ApiConstants.userByRoleFielder,
        options: options,
      );
      if (fielderRes.statusCode == 200) {
        final dynamic fData = fielderRes.data;
        List<dynamic> fList = [];
        if (fData is List) fList = fData;
        else if (fData is Map<String, dynamic> && fData['value'] is List) fList = fData['value'];
        else if (fData is Map<String, dynamic> && fData['items'] is List) fList = fData['items'];
        
        _fielders = fList.map((e) => UserModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Seçenekleri yüklerken hata: $e');
    } finally {
      if (mounted) setState(() => _isLoadingOptions = false);
    }
  }

  Future<Iterable<CustomerModel>> _searchCustomers(String query) async {
    if (query.isEmpty) return const Iterable<CustomerModel>.empty();
    try {
      final dio = GetIt.instance<DioClient>();
      final prefs = GetIt.instance<SharedPreferences>();
      final token = prefs.getString(StorageConstants.accessToken);

      final response = await dio.get(
        ApiConstants.customerSearch,
        queryParameters: {'page': 1, 'pageSize': 20, 'searchQuery': query},
        options: Options(
            headers: {if (token != null) 'Authorization': 'Bearer $token'}),
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

  void _submit() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen bir müşteri seçin'),
          backgroundColor: Colors.red));
      return;
    }
    if (_isCarrierMode && _selectedCarrier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen bir kargo firması seçin'),
          backgroundColor: Colors.red));
      return;
    }
    if (!_isCarrierMode && _selectedFielder == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen bir saha ekibi personeli seçin'),
          backgroundColor: Colors.red));
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;

    final requestData = <String, dynamic>{
      "customerId": _selectedCustomer!.id,
      "price": price,
      "shipmentDate": _selectedDate.toUtc().toIso8601String(),
    };

    if (_isCarrierMode) {
      requestData["carrierId"] = _selectedCarrier!.id;
      requestData["trackingNumber"] = _trackingNumberController.text;
    } else {
      // Web projesinde Saha Ekibi ID'si 6 olarak hardcode edilmiş.
      requestData["carrierId"] = 6;
      requestData["fieldTeamUserId"] = _selectedFielder!.id;
    }

    context.read<DeviceBloc>().add(AssignBackupAssignment(
          deviceId: widget.device.id,
          requestData: requestData,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormScaffold(
      title: 'Müşteriye Ata',
      bottomButtonText: 'Ata',
      onBottomButtonPressed: _submit,
      body: BlocListener<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is DeviceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: _isLoadingOptions
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Cihaz: ${widget.device.deviceTypeName ?? 'Bilinmiyor'}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                              'Seri No: ${widget.device.deviceSerialNumber ?? 'Yok'}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFieldTemplate(
                      label: 'Müşteri Seçin',
                      child: Autocomplete<CustomerModel>(
                        optionsBuilder: (textEditingValue) =>
                            _searchCustomers(textEditingValue.text),
                        displayStringForOption: (option) => option.name,
                        onSelected: (selection) =>
                            setState(() => _selectedCustomer = selection),
                        fieldViewBuilder: (context, controller, focusNode,
                            onEditingComplete) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              hintText: 'Müşteri ara...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldTemplate(
                      label: 'Fiyat',
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldTemplate(
                      label: 'Gönderim Tarihi',
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd.MM.yyyy')
                                  .format(_selectedDate)),
                              const Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Kargo / Gönderim Tipi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isCarrierMode = true),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: _isCarrierMode
                                    ? const Color(0xFFF57C00)
                                    : Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFF57C00)),
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Text('Kargo',
                                  style: TextStyle(
                                      color: _isCarrierMode
                                          ? Colors.white
                                          : const Color(0xFFF57C00),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isCarrierMode = false;
                              if (_carriers.isNotEmpty) {
                                _selectedCarrier = _carriers.firstWhere(
                                  (c) => c.name.toLowerCase().contains('saha'),
                                  orElse: () => _carriers.first,
                                );
                              }
                            }),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: !_isCarrierMode
                                    ? const Color(0xFFF57C00)
                                    : Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFF57C00)),
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Text('Saha Ekibi',
                                  style: TextStyle(
                                      color: !_isCarrierMode
                                          ? Colors.white
                                          : const Color(0xFFF57C00),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isCarrierMode) ...[
                      _buildFieldTemplate(
                        label: 'Kargo Firması',
                        child: Autocomplete<CarrierEntity>(
                          displayStringForOption: (c) => c.name,
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) return _carriers;
                            return _carriers.where((c) => c.name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (val) =>
                              setState(() => _selectedCarrier = val),
                          fieldViewBuilder: (context, controller, focusNode,
                              onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                  labelText: 'Kargo Seç',
                                  border: OutlineInputBorder()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldTemplate(
                        label: 'Kargo Takip Numarası',
                        child: TextFormField(
                          controller: _trackingNumberController,
                          decoration: const InputDecoration(
                              labelText: 'Takip No',
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ] else ...[
                      _buildFieldTemplate(
                        label: 'Saha Ekibi Çalışanı',
                        child: Autocomplete<UserEntity>(
                          displayStringForOption: (u) =>
                              u.username ?? 'Bilinmeyen Kullanıcı',
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) return _fielders;
                            return _fielders.where((u) => (u.username ?? '')
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (val) =>
                              setState(() => _selectedFielder = val),
                          fieldViewBuilder: (context, controller, focusNode,
                              onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                  labelText: 'Saha Ekibi Personeli Seç',
                                  border: OutlineInputBorder()),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFieldTemplate({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
