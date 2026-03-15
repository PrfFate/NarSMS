import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasarim_app/config/routes/app_router.dart';
import 'package:tasarim_app/core/theme/app_colors.dart';
import 'package:tasarim_app/core/widgets/generic_confirmation_dialog.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_event.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_state.dart';
import 'package:tasarim_app/features/sales/domain/entities/approval_workflow_entity.dart';

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
          _load(); // Başarı durumunda listeyi tekrar çek
        } else if (state is ApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Onay Adımları',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final res = await Navigator.pushNamed(
                      context,
                      AppRouter.workflowCreate,
                    );
                    if (res == true) _load();
                  },
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label: const Text('Yeni Akış'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ApprovalBloc, ApprovalState>(
                builder: (context, state) {
                  if (state is ApprovalLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is WorkflowsLoaded) {
                    final workflows = state.workflows;
                    if (workflows.isEmpty) {
                      return _buildEmpty();
                    }

                    // Aktif olanı başa al
                    final sortedWorkflows = List.from(workflows);
                    sortedWorkflows.sort((a, b) {
                      if (a.isActive && !b.isActive) return -1;
                      if (!a.isActive && b.isActive) return 1;
                      return 0;
                    });

                    return ListView.builder(
                      itemCount: sortedWorkflows.length,
                      itemBuilder: (context, index) {
                        return _WorkflowCard(
                          workflow: sortedWorkflows[index],
                          onToggle: (id, currentStatus) =>
                              _showToggleConfirm(context, id, currentStatus),
                          onDelete: (id) => _showDeleteConfirm(context, id),
                        );
                      },
                    );
                  }
                  if (state is ApprovalError) {
                    return _buildError(state.message);
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.approval_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz bir onay akışı oluşturulmamış',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  void _showToggleConfirm(BuildContext context, int id, bool currentStatus) {
    final newStatus = !currentStatus;
    final actionText = newStatus ? 'Aktifleştirmek' : 'Devre Dışı Bırakmak';

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

  void _showDeleteConfirm(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => GenericConfirmationDialog(
        title: 'Akışı Sil',
        message: 'Bu onay akışını silmek istediğinizden emin misiniz?',
        confirmLabel: 'Sil',
        cancelLabel: 'Vazgeç',
        onConfirm: () {
          context.read<ApprovalBloc>().add(DeleteWorkflow(id));
        },
        accentColor: Colors.red,
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final ApprovalWorkflowEntity workflow;
  final Function(int, bool) onToggle;
  final Function(int) onDelete;

  const _WorkflowCard({
    required this.workflow,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(
              color: Color(0xFFF57C00), // Her zaman turuncu çizgi
              width: 6,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workflow.name ?? 'İsimsiz Akış',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(isActive: workflow.isActive),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Entity: ${workflow.entityType ?? "Bilinmiyor"}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Adım Sayısı: ${workflow.steps?.length ?? 0}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => onDelete(workflow.id),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    label:
                        const Text('Sil', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => onToggle(workflow.id, workflow.isActive),
                    icon: Icon(
                      workflow.isActive ? Icons.toggle_off : Icons.toggle_on,
                      size: 20,
                    ),
                    label: Text(
                        workflow.isActive ? 'Devre Dışı Bırak' : 'Aktifleştir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: workflow.isActive
                          ? Colors.grey[200]
                          : Colors.green, // Aktifleştir butonu tam yeşil
                      foregroundColor: workflow.isActive
                          ? Colors.grey[800]
                          : Colors.white, // Beyaz yazı
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        isActive ? 'AKTİF' : 'PASİF',
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.grey[600],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
