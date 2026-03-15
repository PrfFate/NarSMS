import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/generic_confirmation_dialog.dart';
import '../bloc/carrier_bloc.dart';
import '../bloc/carrier_event.dart';
import '../bloc/carrier_state.dart';
import '../../domain/entities/carrier_entity.dart';

class CarrierManagementDialog extends StatefulWidget {
  const CarrierManagementDialog({super.key});

  @override
  State<CarrierManagementDialog> createState() => _CarrierManagementDialogState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => getIt<CarrierBloc>()..add(LoadCarriers()),
        child: const CarrierManagementDialog(),
      ),
    );
  }
}

class _CarrierManagementDialogState extends State<CarrierManagementDialog> {
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
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kargo Firmaları Yönetimi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                ],
              ),
              const Divider(color: AppColors.primary, thickness: 2),
              const SizedBox(height: 16),
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
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count kayıt',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Kargo Firması Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        return const Center(
                          child: Text('Kayıtlı kargo firması bulunamadı',
                              style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.carriers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final carrier = state.carriers[index];
                          return _CarrierCard(
                            carrier: carrier,
                            onEdit: () => _showAddEditDialog(context, carrier: carrier),
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

  void _showAddEditDialog(BuildContext context, {CarrierEntity? carrier}) {
    final controller = TextEditingController(text: carrier?.name);
    final isEdit = carrier != null;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(isEdit ? 'Firmayı Düzenle' : 'Yeni Firma Ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Firma Adı',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (isEdit) {
                  context.read<CarrierBloc>().add(UpdateCarrier(carrier.id, name));
                } else {
                  context.read<CarrierBloc>().add(CreateCarrier(name));
                }
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Güncelle' : 'Ekle'),
          ),
        ],
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                carrier.name.isNotEmpty ? carrier.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
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
                color: AppColors.navy,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20, color: AppColors.navy),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
