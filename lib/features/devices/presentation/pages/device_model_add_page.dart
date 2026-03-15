import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/device_type_entity.dart';
import '../bloc/device_type_bloc.dart';
import '../bloc/device_type_event.dart';
import '../bloc/device_type_state.dart';

class DeviceModelAddPage extends StatefulWidget {
  final DeviceTypeEntity? deviceModel; // null ise Ekle, doluysa Düzenle

  const DeviceModelAddPage({super.key, this.deviceModel});

  @override
  State<DeviceModelAddPage> createState() => _DeviceModelAddPageState();
}

class _DeviceModelAddPageState extends State<DeviceModelAddPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.deviceModel?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final text = _nameController.text.trim();
      if (widget.deviceModel != null) {
        context.read<DeviceTypeBloc>().add(UpdateDeviceType(widget.deviceModel!.id, text));
      } else {
        context.read<DeviceTypeBloc>().add(CreateDeviceType(text));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.deviceModel != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEdit ? 'Modeli Düzenle' : 'Cihaz Modeli Ekle', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
      body: BlocListener<DeviceTypeBloc, DeviceTypeState>(
        listener: (context, state) {
          if (state is DeviceTypeActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is DeviceTypeError) {
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
                          'Model Bilgileri',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Bu alan zorunludur' : null,
                          decoration: InputDecoration(
                            labelText: 'Model Adı *',
                            floatingLabelStyle: const TextStyle(color: Color(0xFFF57C00)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFF57C00), width: 2),
                            ),
                            prefixIcon: const Icon(Icons.devices, color: Colors.grey),
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
