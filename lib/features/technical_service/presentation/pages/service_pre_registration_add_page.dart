import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../devices/domain/entities/device_entity.dart';
import '../../../devices/domain/repositories/device_repository.dart';
import '../../../home/presentation/pages/barcode_scanner_page.dart';
import '../bloc/technical_service_bloc.dart';
import '../bloc/technical_service_event.dart';
import '../bloc/technical_service_state.dart';

class ServicePreRegistrationAddPage extends StatefulWidget {
  const ServicePreRegistrationAddPage({super.key});

  @override
  State<ServicePreRegistrationAddPage> createState() =>
      _ServicePreRegistrationAddPageState();
}

class _ServicePreRegistrationAddPageState
    extends State<ServicePreRegistrationAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  final _faultDescriptionController = TextEditingController();

  String? _selectedSupplier;
  List<String> _suppliers = [];
  bool _isLoadingSuppliers = true;

  DeviceEntity? _selectedDevice;
  List<DeviceEntity> _searchResults = [];
  bool _isSearchingDevice = false;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _serialNumberController.dispose();
    _faultDescriptionController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isNotEmpty) {
        _searchDevice(trimmedQuery);
      } else {
        setState(() {
          _searchResults = [];
          _removeOverlay();
        });
      }
    });
  }

  Future<void> _fetchSuppliers() async {
    final result = await getIt<DeviceRepository>().getSuppliers();
    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isLoadingSuppliers = false);
          _showError('Tedarikçiler yüklenemedi: ${failure.message}');
        }
      },
      (suppliers) {
        if (mounted) {
          setState(() {
            _suppliers = suppliers;
            _isLoadingSuppliers = false;
          });
        }
      },
    );
  }

  Future<void> _searchDevice(String query) async {
    if (!mounted) return;

    // Previous search cleanup
    setState(() {
      _isSearchingDevice = true;
      _searchResults = [];
    });
    _removeOverlay();

    final result = await getIt<DeviceRepository>().searchDevices(
      serialNumber: query,
      pageSize: 50, // Get more results for better dropdown (as specified)
    );

    // Check if the query has changed during the async call
    if (!mounted || _serialNumberController.text.trim() != query) return;

    result.fold(
      (failure) {
        setState(() => _isSearchingDevice = false);
        // Display small error under input or via snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama hatası: ${failure.message}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (paginated) {
        setState(() {
          _isSearchingDevice = false;
          _searchResults = paginated.items;
        });
        if (_searchResults.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      },
    );
  }

  void _showOverlay() {
    if (!mounted) return;
    _removeOverlay();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 85),
          child: Material(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final device = _searchResults[index];
                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(device.deviceSerialNumber ?? 'N/A',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    subtitle: Text(
                        '${device.deviceTypeName} - ${device.status}',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    onTap: () {
                      _debounce
                          ?.cancel(); // Cancel any pending search immediately
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _selectedDevice = device;
                        _serialNumberController.text =
                            device.deviceSerialNumber ?? '';
                        _searchResults = [];
                      });
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  void _submit() {
    _removeOverlay();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDevice == null) {
      _showError('Lütfen listeden bir cihaz seçin.');
      return;
    }
    if (_selectedSupplier == null) {
      _showError('Lütfen bir tedarikçi seçin.');
      return;
    }

    final data = {
      'deviceSerialNumber': _serialNumberController.text.trim(),
      'faultDescription': _faultDescriptionController.text.trim(),
      'requestDate': DateTime.now().toUtc().toIso8601String(),
      'status': 'Pending',
      'supplierName': _selectedSupplier,
    };

    context.read<TechnicalServiceBloc>().add(CreateServiceRequest(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TechnicalServiceBloc, TechnicalServiceState>(
      listener: (context, state) {
        if (state is TechnicalServiceCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Servis ön kaydı başarıyla oluşturuldu'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is TechnicalServiceError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Yeni Servis Ön Kaydı',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFF57C00),
              height: 2.0,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: _isLoadingSuppliers
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GestureDetector(
                    onTap: () => _removeOverlay(),
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Cihaz Bilgileri'),
                            const SizedBox(height: 12),

                            CompositedTransformTarget(
                              link: _layerLink,
                              child: CustomTextField(
                                controller: _serialNumberController,
                                label: 'Cihaz Seri Numarası',
                                hint: 'Seri numarasına göre ara...',
                                onChanged:
                                    _onSearchQueryChanged, // Manual triggers only!
                                // Prefix icon removed
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isSearchingDevice)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFF57C00))),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.qr_code_scanner,
                                          color: Color(0xFFF57C00)),
                                      tooltip: 'Barkod Okut',
                                      onPressed: () async {
                                        _removeOverlay();
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BarcodeScannerPage(),
                                          ),
                                        );
                                        if (result != null &&
                                            result is String) {
                                          setState(() {
                                            _serialNumberController.text =
                                                result;
                                          });
                                          _searchDevice(result);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Seri numarası zorunludur'
                                    : null,
                              ),
                            ),

                            if (_selectedDevice != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFF57C00)
                                            .withAlpha(50)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withAlpha(5),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2))
                                    ]),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline,
                                        color: Color(0xFFF57C00), size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Seçili Cihaz: ${_selectedDevice!.deviceTypeName}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                                fontSize: 13),
                                          ),
                                          Text(
                                            'SN: ${_selectedDevice!.deviceSerialNumber} - Durum: ${_selectedDevice!.status}',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 18, color: Colors.grey),
                                      onPressed: () => setState(
                                          () => _selectedDevice = null),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),
                            _buildSectionTitle('Servis Detayları'),
                            const SizedBox(height: 12),

                            CustomTextField(
                              controller: _faultDescriptionController,
                              label: 'Arıza Açıklaması',
                              hint: 'Cihazdaki sorunu detaylandırın...',
                              maxLines: 3,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Arıza açıklaması zorunludur'
                                  : null,
                            ),

                            const SizedBox(height: 16),
                            _buildLabel('Tedarikçi'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedSupplier,
                              decoration: _dropdownDecoration(
                                  'Tedarikçi Seçiniz', Icons.local_shipping),
                              items: _suppliers
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedSupplier = v),
                              validator: (v) => v == null
                                  ? 'Lütfen bir tedarikçi seçin'
                                  : null,
                            ),
                            const SizedBox(
                                height: 100), // Bottom spacer for button
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sticky bottom button
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
                            color: Colors.black
                                .withAlpha(10), // Shadow fixed to matched theme
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: BlocBuilder<TechnicalServiceBloc,
                          TechnicalServiceState>(
                        builder: (context, state) {
                          bool isLoading = state is TechnicalServiceLoading;
                          return ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF57C00),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Ön Kayıt Oluştur',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

extension ContextExtension on BuildContext {
  RenderBox findRenderBox() => findRenderObject() as RenderBox;
}
