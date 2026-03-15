import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';
import '../../data/models/create_device_request_model.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../home/presentation/pages/barcode_scanner_page.dart';

class DeviceBulkAddPage extends StatefulWidget {
  const DeviceBulkAddPage({super.key});

  @override
  State<DeviceBulkAddPage> createState() => _DeviceBulkAddPageState();
}

class _DeviceBulkAddPageState extends State<DeviceBulkAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _purchasePriceController = TextEditingController();
  final List<TextEditingController> _serialNumberControllers = [TextEditingController()];

  String? _selectedDeviceType;
  String? _selectedSupplier;
  bool _isPastDate = false;
  DateTime? _selectedDate;

  // Features
  String? _selectedHafiza;
  String? _selectedRam;
  String? _selectedEkran;
  String? _selectedIslemci;
  String? _selectedHardDiskHafiza;
  String? _selectedPort;
  String? _selectedUpsGuc;

  // Options
  final hafizaOptions = ['128GB', '256GB'];
  final ramOptions = ['8GB', '16GB'];
  final ekranOptions = ['15.6', '18.5'];
  final islemciOptions = [
    'i-5 (5.Nesil)',
    'i-5 (6.Nesil)',
    'i-5 (7.Nesil)',
    'i-5 (10.Nesil)',
    'i-7 (4.Nesil)'
  ];
  final hardDiskHafizaOptions = ['128GB', '256GB', '512GB'];
  final portOptions = ['8', '16', '24'];
  final upsGucOptions = ['600kVA', '650kVA'];

  @override
  void initState() {
    super.initState();
    context.read<DeviceBloc>().add(LoadDeviceOptions());
  }

  @override
  void dispose() {
    for (var controller in _serialNumberControllers) {
      controller.dispose();
    }
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF57C00),
              onPrimary: Colors.white,
              onSurface: Colors.black,
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

  void _addSerialNumberField() {
    setState(() {
      _serialNumberControllers.add(TextEditingController());
    });
  }

  void _removeSerialNumberField(int index) {
    if (_serialNumberControllers.length > 1) {
      setState(() {
        _serialNumberControllers[index].dispose();
        _serialNumberControllers.removeAt(index);
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDeviceType == null) {
        _showError('Cihaz Modeli seçiniz.');
        return;
      }
      if (_selectedSupplier == null) {
        _showError('Tedarikçi seçiniz.');
        return;
      }
      if (_isPastDate && _selectedDate == null) {
        _showError('Lütfen satın alma tarihini seçiniz.');
        return;
      }

      final serialNumbers = _serialNumberControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (serialNumbers.isEmpty) {
        _showError('En az 1 adet geçerli seri numarası giriniz.');
        return;
      }

      final features = <Map<String, dynamic>>[];
      final dt = _selectedDeviceType!.toLowerCase();
      
      if (dt.contains('bilgisayar')) {
        if (_selectedRam != null) features.add({"featureName": "RAM", "featureValue": _selectedRam});
        if (_selectedHafiza != null) features.add({"featureName": "Hafıza", "featureValue": _selectedHafiza});
        if (_selectedEkran != null) features.add({"featureName": "Ekran", "featureValue": _selectedEkran});
        if (_selectedIslemci != null) features.add({"featureName": "İşlemci", "featureValue": _selectedIslemci});
      } else if (dt.contains('hard disk') || dt.contains('harddisk')) {
        if (_selectedHardDiskHafiza != null) features.add({"featureName": "Hafıza", "featureValue": _selectedHardDiskHafiza});
      } else if (dt.contains('switch')) {
        if (_selectedPort != null) features.add({"featureName": "Port", "featureValue": _selectedPort});
      } else if (dt.contains('ups')) {
        if (_selectedUpsGuc != null) features.add({"featureName": "Güç", "featureValue": _selectedUpsGuc});
      }
      
      if (features.isEmpty) {
        features.add({"featureName": "No Properties", "featureValue": null});
      }

      final purchaseDate = _isPastDate ? _selectedDate! : DateTime.now();
      final double purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;

      final devicesList = serialNumbers.map((sn) {
        return CreateDeviceRequestModel(
          deviceSerialNumber: sn,
          deviceTypeName: _selectedDeviceType!,
          supplierName: _selectedSupplier!,
          status: 'InStock',
          purchaseDate: purchaseDate,
          purchasePrice: purchasePrice,
          features: features,
        ).toJson();
      }).toList();

      final request = {
        'devices': devicesList,
        'stopOnFirstError': true,
      };

      context.read<DeviceBloc>().add(BulkCreateDevices(request));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Toplu Cihaz Ekle', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF57C00),
            height: 2.0,
          ),
        ),
      ),
      body: BlocConsumer<DeviceBloc, DeviceState>(
        listener: (context, state) {
          if (state is DeviceActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is DeviceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is DeviceLoading;
          List<String> deviceTypes = [];
          List<String> suppliers = [];

          if (state is DeviceOptionsLoaded) {
             deviceTypes = state.deviceTypes;
             suppliers = state.suppliers;
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Temel Bilgiler'),
                      const SizedBox(height: 12),
                      
                      // CİHAZ MODELLERİ (DeviceType)
                      DropdownButtonFormField<String>(
                        value: _selectedDeviceType,
                        decoration: _dropdownDecoration('Cihaz Modeli', Icons.devices),
                        items: deviceTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDeviceType = val;
                            // reset features
                            _selectedHafiza = null;
                            _selectedRam = null;
                            _selectedEkran = null;
                            _selectedIslemci = null;
                            _selectedHardDiskHafiza = null;
                            _selectedPort = null;
                            _selectedUpsGuc = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // TEDARİKÇİLER (Supplier)
                      DropdownButtonFormField<String>(
                        value: _selectedSupplier,
                        decoration: _dropdownDecoration('Tedarikçi', Icons.local_shipping),
                        items: suppliers.map((sup) {
                          return DropdownMenuItem(value: sup, child: Text(sup));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSupplier = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _purchasePriceController,
                        label: 'Alış Fiyatı (\$)',
                        hint: 'Örn: 15000',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money),
                        validator: (value) => value == null || value.isEmpty ? 'Kayıt için alış fiyatı giriniz' : null,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Cihaz Özellikleri (Ortak)'),
                      const SizedBox(height: 12),

                      // DİNAMİK ÖZELLİK LİSTESİ (Cihaza göre)
                      if (_selectedDeviceType != null) ..._buildDynamicFeatures(),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle('Kayıt Tarihi (Ortak)'),
                      const SizedBox(height: 8),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Geçmiş Tarihli Cihaz Kaydı', style: TextStyle(fontSize: 14)),
                        activeColor: const Color(0xFFF57C00),
                        value: _isPastDate,
                        onChanged: (val) {
                          setState(() {
                            _isPastDate = val ?? false;
                            if (!_isPastDate) _selectedDate = null;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (_isPastDate) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate == null 
                                      ? 'Tarih Seçiniz' 
                                      : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                                  style: TextStyle(
                                    color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      _buildSectionTitle('Seri Numaraları'),
                      const SizedBox(height: 8),
                      const Text(
                        'Eklemek istediğiniz cihazların seri numaralarını tek tek aşağıya giriniz.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _serialNumberControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _serialNumberControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'Cihaz ${index + 1} Seri No',
                                      prefixIcon: const Icon(Icons.numbers, color: Colors.grey),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFF57C00)),
                                        tooltip: 'Barkod Okut',
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const BarcodeScannerPage(),
                                            ),
                                          );
                                          if (result != null && result is String) {
                                            setState(() {
                                              _serialNumberControllers[index].text = result;
                                            });
                                          }
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      // Yeni satır açmak için kolaylık
                                      if (index == _serialNumberControllers.length - 1) {
                                        _addSerialNumberField();
                                      }
                                    },
                                    validator: (value) => value == null || value.isEmpty ? 'Gereklidir' : null,
                                  ),
                                ),
                                if (_serialNumberControllers.length > 1) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                    onPressed: () => _removeSerialNumberField(index),
                                  ),
                                ]
                              ],
                            ),
                          );
                        },
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addSerialNumberField,
                          icon: const Icon(Icons.add_circle, color: Color(0xFFF57C00)),
                          label: const Text('Yeni Seri Numarası Ekle', style: TextStyle(color: Color(0xFFF57C00), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Bottom button spacer
                    ],
                  ),
                ),
              ),

              // Bottom Button Sticky
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('${_serialNumberControllers.length} Cihazı Toplu Kaydet', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),

              if (isLoading && state is! DeviceOptionsLoaded)
                Container(
                  color: Colors.black.withAlpha(50),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
     return InputDecoration(
       labelText: label,
       floatingLabelStyle: const TextStyle(color: Color(0xFFF57C00)),
       prefixIcon: Icon(icon, color: Colors.grey[600]),
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey[300]!),
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey[300]!),
       ),
       focusedBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
       ),
       filled: true,
       fillColor: Colors.white,
       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
     );
  }

  List<Widget> _buildDynamicFeatures() {
     final dt = _selectedDeviceType!.toLowerCase();
     if (dt.contains('bilgisayar')) {
        return [
           // RAM
           DropdownButtonFormField<String>(
             value: _selectedRam,
             decoration: _dropdownDecoration('RAM Seçimi', Icons.memory),
             items: ramOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedRam = val),
           ),
           const SizedBox(height: 12),
           // HAFIZA
           DropdownButtonFormField<String>(
             value: _selectedHafiza,
             decoration: _dropdownDecoration('Hafıza Seçimi', Icons.storage),
             items: hafizaOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedHafiza = val),
           ),
           const SizedBox(height: 12),
           // EKRAN
           DropdownButtonFormField<String>(
             value: _selectedEkran,
             decoration: _dropdownDecoration('Ekran Boyutu', Icons.desktop_windows),
             items: ekranOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedEkran = val),
           ),
           const SizedBox(height: 12),
           // İşlemci
           DropdownButtonFormField<String>(
             value: _selectedIslemci,
             decoration: _dropdownDecoration('İşlemci Seçimi', Icons.developer_board),
             items: islemciOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedIslemci = val),
           ),
        ];
     } else if (dt.contains('hard disk') || dt.contains('harddisk')) {
        return [
           DropdownButtonFormField<String>(
             value: _selectedHardDiskHafiza,
             decoration: _dropdownDecoration('Hard Disk Kapasitesi', Icons.save),
             items: hardDiskHafizaOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedHardDiskHafiza = val),
           ),
        ];
     } else if (dt.contains('switch')) {
        return [
           DropdownButtonFormField<String>(
             value: _selectedPort,
             decoration: _dropdownDecoration('Port Sayısı', Icons.settings_ethernet),
             items: portOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedPort = val),
           ),
        ];
     } else if (dt.contains('ups')) {
        return [
           DropdownButtonFormField<String>(
             value: _selectedUpsGuc,
             decoration: _dropdownDecoration('UPS Gücü', Icons.battery_charging_full),
             items: upsGucOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
             onChanged: (val) => setState(() => _selectedUpsGuc = val),
           ),
        ];
     }

     return [
       const Padding(
         padding: EdgeInsets.only(top: 8.0),
         child: Text('Bu cihaz modeli özel ek donanım bilgisi gerektirmiyor.', style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
       )
     ];
  }
}
