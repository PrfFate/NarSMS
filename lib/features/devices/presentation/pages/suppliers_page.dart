import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../bloc/supplier_bloc.dart';
import '../bloc/supplier_event.dart';
import '../bloc/supplier_state.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  void _loadSuppliers() {
    context.read<SupplierBloc>().add(LoadSuppliers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tedarikçiler', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF57C00), height: 2.0),
        ),
      ),
      body: BlocListener<SupplierBloc, SupplierState>(
        listener: (context, state) {
          if (state is SupplierActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            _loadSuppliers();
          } else if (state is SupplierError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CustomRefreshButton(onPressed: _loadSuppliers),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, AppRouter.supplierAdd);
                      if (result != null) {
                        _loadSuppliers();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Tedarikçi Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: BlocBuilder<SupplierBloc, SupplierState>(
                builder: (context, state) {
                  if (state is SupplierLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFF57C00)));
                  }

                  if (state is SupplierLoaded) {
                    final suppliers = state.suppliers;

                    if (suppliers.isEmpty) {
                      return const Center(
                        child: Text('Kayıtlı tedarikçi bulunamadı.', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF57C00).withAlpha(30),
                              child: const Icon(Icons.local_shipping, color: Color(0xFFF57C00)),
                            ),
                            title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('ID: ${supplier.id} | Cihaz Sayısı: ${supplier.deviceCount}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                AppRouter.supplierDetail,
                                arguments: supplier,
                              );
                              if (result == true) {
                                _loadSuppliers();
                              }
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
