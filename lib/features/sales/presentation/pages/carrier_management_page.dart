import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/widgets/generic_confirmation_dialog.dart';
import '../bloc/carrier_bloc.dart';
import '../bloc/carrier_event.dart';
import '../bloc/carrier_state.dart';
import '../../domain/entities/carrier_entity.dart';

class CarrierManagementPage extends StatefulWidget {
  const CarrierManagementPage({super.key});

  @override
  State<CarrierManagementPage> createState() => _CarrierManagementPageState();
}

class _CarrierManagementPageState extends State<CarrierManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CarrierBloc>().add(LoadCarriers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarrierBloc, CarrierState>(
      listener: (context, state) {
        if (state is CarrierOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is CarrierError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: CustomFormScaffold(
        title: 'Kargo Firmaları Yönetimi',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<CarrierBloc, CarrierState>(
                    builder: (context, state) {
                      int count = 0;
                      if (state is CarriersLoaded) {
                        count = state.carriers.length;
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          '$count kayıt',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.carrierAdd).then((value) {
                      if (value == true) {
                        context.read<CarrierBloc>().add(LoadCarriers());
                      }
                    }),
                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                    label: const Text('Yeni Firma'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<CarrierBloc, CarrierState>(
                  builder: (context, state) {
                    if (state is CarrierLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is CarriersLoaded) {
                      if (state.carriers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text('Kayıtlı kargo firması bulunamadı',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.carriers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final carrier = state.carriers[index];
                          return _CarrierCard(
                            carrier: carrier,
                            onEdit: () => Navigator.pushNamed(context, AppRouter.carrierAdd, arguments: carrier).then((value) {
                              if (value == true) {
                                context.read<CarrierBloc>().add(LoadCarriers());
                              }
                            }),
                            onDelete: () => _showDeleteConfirm(context, carrier),
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
      ),
    );
  }



  void _showDeleteConfirm(BuildContext context, CarrierEntity carrier) {
    GenericConfirmationDialog.show(
      context: context,
      title: 'Firmayı Sil',
      message: 'Kargo firmasını silmek istediğinize emin misiniz?',
      itemName: carrier.name,
      confirmLabel: 'Sil',
      accentColor: Colors.red,
      onConfirm: () {
        context.read<CarrierBloc>().add(DeleteCarrier(carrier.id));
      },
    );
  }
}

class _CarrierCard extends StatelessWidget {
  final CarrierEntity carrier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CarrierCard({
    required this.carrier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                carrier.name.isNotEmpty ? carrier.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFFF57C00),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              carrier.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.navy,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 22, color: AppColors.navy),
            tooltip: 'Düzenle',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 22, color: Colors.red),
            tooltip: 'Sil',
          ),
        ],
      ),
    );
  }
}
