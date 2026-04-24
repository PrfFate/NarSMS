import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasarim_app/config/routes/app_router.dart';
import 'package:tasarim_app/core/widgets/custom_action_menu_widget.dart';
import 'package:tasarim_app/core/widgets/custom_list_card.dart';
import 'package:tasarim_app/core/widgets/error_widget.dart' as common;
import 'package:tasarim_app/core/widgets/generic_confirmation_dialog.dart';
import 'package:tasarim_app/core/widgets/loading_indicator.dart';
import 'package:tasarim_app/features/sales/domain/entities/approval_workflow_entity.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_event.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_state.dart';

class ApprovalWorkflowsPage extends StatefulWidget {
  const ApprovalWorkflowsPage({super.key});

  @override
  State<ApprovalWorkflowsPage> createState() => _ApprovalWorkflowsPageState();
}

class _ApprovalWorkflowsPageState extends State<ApprovalWorkflowsPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<ApprovalBloc>().add(LoadWorkflows());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovalBloc, ApprovalState>(
      listener: (context, state) {
        if (state is ApprovalSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          _load();
        } else if (state is ApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: ColoredBox(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tanımlı Onay Akışları',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  CustomActionMenuWidget(
                    items: [
                      CustomActionMenuItem(
                        title: 'Yeni Akış Ekle',
                        icon: Icons.add_circle_outline,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRouter.workflowCreate,
                          );
                          if (result == true && context.mounted) {
                            _load();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<ApprovalBloc, ApprovalState>(
                  builder: (context, state) {
                    if (state is ApprovalLoading) {
                      return const LoadingIndicator();
                    }
                    if (state is WorkflowsLoaded) {
                      if (state.workflows.isEmpty) return _buildEmptyState();

                      final workflows =
                          List<ApprovalWorkflowEntity>.from(state.workflows)
                            ..sort((a, b) {
                              if (a.isActive && !b.isActive) return -1;
                              if (!a.isActive && b.isActive) return 1;
                              return a.name
                                  .toLowerCase()
                                  .compareTo(b.name.toLowerCase());
                            });

                      return _buildList(workflows);
                    }
                    if (state is ApprovalError) {
                      return common.CustomErrorWidget(
                        message: state.message,
                        onRetry: _load,
                      );
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<ApprovalWorkflowEntity> workflows) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: workflows.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final workflow = workflows[index];
          return CustomListCard(
            title: workflow.name,
            subtitle:
                '${workflow.entityType} • ${workflow.steps.length} adım • v${workflow.version}',
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    workflow.isActive ? const Color(0xFFF57C00) : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusChip(isActive: workflow.isActive),
                const SizedBox(width: 4),
                IconButton.filled(
                  tooltip:
                      workflow.isActive ? 'Devre Dışı Bırak' : 'Aktifleştir',
                  style: IconButton.styleFrom(
                    backgroundColor: workflow.isActive
                        ? const Color(0xFFF57C00)
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(34, 34),
                    fixedSize: const Size(34, 34),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showToggleConfirm(
                    context,
                    workflow.id,
                    workflow.isActive,
                  ),
                ),
                IconButton(
                  tooltip: 'Sil',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirm(context, workflow),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.approval_outlined, size: 64, color: Color(0xFFF57C00)),
            SizedBox(height: 16),
            Text(
              'Onay akışı bulunamadı',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showToggleConfirm(BuildContext context, int id, bool currentStatus) {
    final newStatus = !currentStatus;
    final actionText = newStatus ? 'aktifleştirmek' : 'devre dışı bırakmak';

    showDialog(
      context: context,
      builder: (_) => GenericConfirmationDialog(
        title: 'Durum Değişikliği',
        message: 'Bu onay akışını $actionText istediğinizden emin misiniz?',
        confirmLabel: newStatus ? 'Aktifleştir' : 'Devre Dışı Bırak',
        cancelLabel: 'İptal',
        onConfirm: () {
          context.read<ApprovalBloc>().add(ToggleWorkflowStatus(id, newStatus));
        },
        accentColor: Colors.orange,
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, ApprovalWorkflowEntity workflow) {
    showDialog(
      context: context,
      builder: (_) => GenericConfirmationDialog(
        title: 'Onay Akışı Sil',
        message:
            '${workflow.name} onay akışını silmek istediğinizden emin misiniz?',
        confirmLabel: 'Sil',
        cancelLabel: 'Vazgeç',
        onConfirm: () {
          context.read<ApprovalBloc>().add(DeleteWorkflow(workflow.id));
        },
        accentColor: Colors.red,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
