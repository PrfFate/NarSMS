import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';

class SupplierAddPage extends StatefulWidget {
  final SupplierEntity? supplier; // null ise Ekle, doluysa Düzenle

  const SupplierAddPage({super.key, this.supplier});

  @override
  State<SupplierAddPage> createState() => _SupplierAddPageState();
}

class _SupplierAddPageState extends State<SupplierAddPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _contactPersonController = TextEditingController(text: widget.supplier?.contactPerson ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final data = {
        "name": name,
        "contactPerson": _contactPersonController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "address": _addressController.text.trim(),
      };

      if (widget.supplier != null) {
        context.read<SupplierBloc>().add(UpdateSupplier(widget.supplier!.id, data));
      } else {
        context.read<SupplierBloc>().add(CreateSupplier(data));
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: label.contains('*') ? (value) => value == null || value.trim().isEmpty ? 'Bu alan zorunludur' : null : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: Color(0xFFF57C00)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEdit ? 'Tedarikçiyi Düzenle' : 'Tedarikçi Ekle', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF57C00), height: 2.0),
        ),
      ),
      body: BlocListener<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierActionSuccess) {
            final returnData = {
              "name": _nameController.text.trim(),
              "contactPerson": _contactPersonController.text.trim(),
              "phone": _phoneController.text.trim(),
              "email": _emailController.text.trim(),
              "address": _addressController.text.trim(),
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, returnData);
          } else if (state is SupplierError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Firma Bilgileri',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_nameController, 'Tedarikçi Adı *', prefixIcon: Icons.business),
                        const SizedBox(height: 12),
                        _buildTextField(_contactPersonController, 'İlgili Kişi', prefixIcon: Icons.person),
                        const SizedBox(height: 12),
                        _buildTextField(_phoneController, 'Telefon', prefixIcon: Icons.phone),
                        const SizedBox(height: 12),
                        _buildTextField(_emailController, 'E-posta', prefixIcon: Icons.email),
                        const SizedBox(height: 12),
                        _buildTextField(_addressController, 'Adres', maxLines: 2, prefixIcon: Icons.location_on),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isEdit ? 'Güncelle' : 'Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
