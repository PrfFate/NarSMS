import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/turkey_cities.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

/// Page for adding a new customer.
/// Uses a form with validation and submits via [CustomerBloc].
class CustomerAddPage extends StatefulWidget {
  const CustomerAddPage({super.key});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _uniqueIdController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;

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
      // Eger backend tarafinda il/ilce ayri tutulacaksa burasi degistirilebilir.
      String finalAddress = _addressController.text.trim();
      if (_selectedCity != null && _selectedDistrict != null) {
        finalAddress = '$_selectedDistrict, $_selectedCity\n$finalAddress'.trim();
      } else if (_selectedCity != null) {
        finalAddress = '$_selectedCity\n$finalAddress'.trim();
      }

      context.read<CustomerBloc>().add(
            CreateCustomer(
              name: _nameController.text.trim(),
              email: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : null,
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              address: finalAddress.isNotEmpty ? finalAddress : null,
              uniqueId: _uniqueIdController.text.trim().isNotEmpty
                  ? _uniqueIdController.text.trim()
                  : null,
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
          Navigator.of(context).pop(true);
        } else if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          return CustomFormScaffold(
            title: 'Yeni Müşteri Ekle',
            bottomButtonText: 'Ekle',
            isLoading: state is CustomerLoading,
            onBottomButtonPressed: _onSubmit,
            body: Form(
              key: _formKey,
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
          );
        },
      ),
    );
  }
}
