import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/carrier_entity.dart';
import '../bloc/carrier_bloc.dart';
import '../bloc/carrier_event.dart';
import '../bloc/carrier_state.dart';

class CarrierAddPage extends StatefulWidget {
  final CarrierEntity? carrier; // null ise Ekle, doluysa Düzenle

  const CarrierAddPage({super.key, this.carrier});

  @override
  State<CarrierAddPage> createState() => _CarrierAddPageState();
}

class _CarrierAddPageState extends State<CarrierAddPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.carrier?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final text = _nameController.text.trim();
      if (widget.carrier != null) {
        context.read<CarrierBloc>().add(UpdateCarrier(widget.carrier!.id, text));
      } else {
        context.read<CarrierBloc>().add(CreateCarrier(text));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.carrier != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEdit ? 'Firmayı Düzenle' : 'Yeni Kargo Firması Ekle', 
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
      body: BlocListener<CarrierBloc, CarrierState>(
        listener: (context, state) {
          if (state is CarrierOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is CarrierError) {
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
                        TextFormField(
                          controller: _nameController,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Bu alan zorunludur' : null,
                          decoration: InputDecoration(
                            labelText: 'Firma Adı *',
                            floatingLabelStyle: const TextStyle(color: Color(0xFFF57C00)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                            ),
                            prefixIcon: const Icon(Icons.local_shipping, color: Colors.grey),
                          ),
                        ),
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
