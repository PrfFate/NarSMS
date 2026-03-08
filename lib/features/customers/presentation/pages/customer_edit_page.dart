import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/turkey_cities.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

/// Page for editing an existing customer.
/// Receives the [CustomerEntity] via route arguments and pre-fills the form.
class CustomerEditPage extends StatefulWidget {
  final CustomerEntity customer;

  const CustomerEditPage({super.key, required this.customer});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _uniqueIdController;

  String? _selectedCity;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _emailController = TextEditingController(text: widget.customer.email ?? '');
    _phoneController = TextEditingController(text: widget.customer.phone ?? '');
    _addressController =
        TextEditingController(text: widget.customer.address ?? '');
    _uniqueIdController =
        TextEditingController(text: widget.customer.uniqueId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _uniqueIdController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Adres alanına il ve ilçe bilgisini de ekleyerek birleştiriyoruz.
      String finalAddress = _addressController.text.trim();
      if (_selectedCity != null && _selectedDistrict != null) {
        finalAddress = '$_selectedDistrict, $_selectedCity\n$finalAddress'.trim();
      } else if (_selectedCity != null) {
        finalAddress = '$_selectedCity\n$finalAddress'.trim();
      }

      context.read<CustomerBloc>().add(
            UpdateCustomer(
              id: widget.customer.id!,
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              address: finalAddress,
              uniqueId: _uniqueIdController.text.trim(),
            ),
          );
    }
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return _buildFieldTemplate(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
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
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<String> items,
    String? value,
    required void Function(String?) onChanged,
  }) {
    return _buildFieldTemplate(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
        decoration: InputDecoration(
          hintText: hint,
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
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true); // return true to refresh list
        } else if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Çok açık gri arkaplan
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.black54),
          title: const Text(
            'Müşteri Bilgileri Güncelle',
            style: TextStyle(
              color: Color(0xFF1E293B), // Koyu lacivert/siyah
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: const Color(0xFFEF4444), // Kırmızı alt çizgi
              height: 2.0,
            ),
          ),
        ),
        body: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            label: 'Müşteri Id',
                            hint: 'Müşteri ID girin',
                            controller: _uniqueIdController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Ad',
                            hint: 'İsim girin',
                            controller: _nameController,
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Müşteri adı zorunludur' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Email',
                            hint: 'Email girin',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Telefon',
                            hint: '(5__) _ _ _ _',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'İl',
                            hint: 'İl seçin',
                            items: TurkeyCities.cities,
                            value: _selectedCity,
                            onChanged: (val) {
                              setState(() {
                                _selectedCity = val;
                                _selectedDistrict = null; // İlçe seçimini sıfırla
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'İlçe',
                            hint: 'İlçe seçin',
                            items: _selectedCity != null ? TurkeyCities.getDistricts(_selectedCity!) : [],
                            value: _selectedDistrict,
                            onChanged: (val) {
                              setState(() {
                                _selectedDistrict = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Adres',
                            hint: 'Adres girin',
                            controller: _addressController,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sabit Alt Buton Alanı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state is CustomerLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00), // Ana turuncu renk
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: state is CustomerLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Güncelle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
