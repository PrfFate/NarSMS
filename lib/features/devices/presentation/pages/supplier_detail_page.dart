import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../domain/entities/supplier_entity.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';

class SupplierDetailPage extends StatefulWidget {
  final SupplierEntity supplier;
  const SupplierDetailPage({super.key, required this.supplier});

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  late SupplierEntity _supplier;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _supplier = widget.supplier;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tedarikçiyi Sil', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('"${_supplier.name}" adlı tedarikçiyi silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SupplierBloc>().add(DeleteSupplier(_supplier.id));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Tedarikçi Detay', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(color: const Color(0xFFF57C00), height: 2.0),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
              tooltip: 'Düzenle',
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRouter.supplierAdd, arguments: _supplier);
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _supplier = SupplierEntity(
                      id: _supplier.id,
                      name: result['name'],
                      contactPerson: result['contactPerson'],
                      phone: result['phone'],
                      email: result['email'],
                      address: result['address'],
                      deviceCount: _supplier.deviceCount,
                    );
                    _changed = true;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Sil',
              onPressed: () => _showDeleteDialog(),
            ),
          ],
        ),
        body: BlocListener<SupplierBloc, SupplierState>(
          listener: (context, state) {
            if (state is SupplierActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              if (state.message.contains('silindi')) {
                Navigator.pop(context, true);
              }
            } else if (state is SupplierError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      children: [
                         CircleAvatar(
                           radius: 30,
                           backgroundColor: const Color(0xFFF57C00).withAlpha(30),
                           child: const Icon(Icons.local_shipping, color: Color(0xFFF57C00), size: 30),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 _supplier.name,
                                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 'ID: ${_supplier.id} | Tedarikçiye Kayıtlı Cihaz: ${_supplier.deviceCount}',
                                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                               ),
                             ],
                           ),
                         ),
                      ],
                     ),
                     const SizedBox(height: 24),
                     const Divider(),
                     const SizedBox(height: 16),
                     const Text('İletişim Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                     const SizedBox(height: 16),
                     if (_supplier.contactPerson != null && _supplier.contactPerson!.isNotEmpty ||
                         _supplier.phone != null && _supplier.phone!.isNotEmpty ||
                         _supplier.email != null && _supplier.email!.isNotEmpty || 
                         _supplier.address != null && _supplier.address!.isNotEmpty) ...[
                       _buildInfoRow(Icons.person, 'İlgili Kişi', _supplier.contactPerson),
                       _buildInfoRow(Icons.phone, 'Telefon', _supplier.phone),
                       _buildInfoRow(Icons.email, 'E-posta', _supplier.email),
                       _buildInfoRow(Icons.location_on, 'Adres', _supplier.address),
                     ] else 
                       const Text('İletişim bilgisi bulunamadı', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
