import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasarim_app/core/theme/app_colors.dart';
import 'package:tasarim_app/core/widgets/custom_form_scaffold.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_bloc.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_event.dart';
import 'package:tasarim_app/features/sales/presentation/bloc/approval_state.dart';
import 'package:tasarim_app/features/sales/domain/entities/approval_workflow_entity.dart';

class WorkflowCreatePage extends StatefulWidget {
  const WorkflowCreatePage({super.key});

  @override
  State<WorkflowCreatePage> createState() => _WorkflowCreatePageState();
}

class _WorkflowCreatePageState extends State<WorkflowCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final String _entityType = 'Sale'; // Her zaman Sale
  final List<Map<String, dynamic>> _steps = [];
  List<Map<String, dynamic>> _availableRoles = [];
  List<ApprovalWorkflowEntity> _existingWorkflows = [];

  @override
  void initState() {
    super.initState();
    context.read<ApprovalBloc>().add(LoadRoles());
    context.read<ApprovalBloc>().add(LoadWorkflows());
  }

  void _addStep() {
    setState(() {
      _steps.add({
        'id': 0, // Backend expects id, 0 for new
        'stepOrder': _steps.length + 1, // 1'den başlıyor (user örneğine göre)
        'stepName': '',
        'roleId': _availableRoles.isNotEmpty
            ? _availableRoles.first['id']
            : 1, // Default to first role or 1
      });
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Re-order
      for (int i = 0; i < _steps.length; i++) {
        _steps[i]['stepOrder'] = i + 1;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir onay adımı ekleyin')),
      );
      return;
    }

    // Mevcut Sale akışı var mı kontrol et
    final existingSaleWorkflow =
        _existingWorkflows.cast<ApprovalWorkflowEntity?>().firstWhere(
              (w) => w?.entityType == _entityType,
              orElse: () => null,
            );

    if (existingSaleWorkflow != null) {
      // Versiyon güncelleme için payload (id ve version içermemeli)
      final versionData = {
        'name': _nameController.text,
        'entityType': _entityType,
        'isActive': true,
        'steps': _steps.map((step) {
          final s = Map<String, dynamic>.from(step);
          s.remove('id'); // Adım id'si de yeni versiyonda 0 veya olmamalı
          return s;
        }).toList(),
      };
      context
          .read<ApprovalBloc>()
          .add(UpdateWorkflowVersion(existingSaleWorkflow.id, versionData));
    } else {
      // Yeni oluşturma için payload
      final createData = {
        'id': 0,
        'name': _nameController.text,
        'entityType': _entityType,
        'version': 0,
        'isActive': true,
        'steps': _steps,
      };
      context.read<ApprovalBloc>().add(CreateWorkflow(createData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovalBloc, ApprovalState>(
      listener: (context, state) {
        if (state is ApprovalSuccess) {
          Navigator.pop(
              context, true); // Başarılıysa geri dön ve listeyi yenile
        } else if (state is ApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is RolesLoaded) {
          setState(() {
            _availableRoles = state.roles;
            // Eğer rol yoksa varsayılan adım ekleme işlemi yapılabilir
          });
        } else if (state is WorkflowsLoaded) {
          setState(() {
            _existingWorkflows = state.workflows;
          });
        }
      },
      child: CustomFormScaffold(
        title: 'Yeni Onay Mekanizması',
        bottomButtonText: 'Kaydet',
        onBottomButtonPressed: _submit,
        isLoading: context.watch<ApprovalBloc>().state is ApprovalLoading,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Mekanizma Adı',
                  hintText: 'Örn: Standart Satış Onayı',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.primary, width: 2)),
                  floatingLabelStyle: TextStyle(color: AppColors.primary),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Onay Adımları',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text('Adım Ekle'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_steps.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Henüz adım eklenmedi.\n"Adım Ekle" butonuna basın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ...List.generate(
                  _steps.length, (index) => _buildStepField(index)),
              const SizedBox(height: 100), // Buton için boşluk
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepField(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _steps[index]['stepName'],
                    decoration: const InputDecoration(
                      labelText: 'Adım Adı (Örn: Finans Onayı)',
                      border: UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2)),
                      floatingLabelStyle: TextStyle(color: AppColors.primary),
                    ),
                    onChanged: (val) => _steps[index]['stepName'] = val,
                    validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () => _removeStep(index),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Onaylayacak Rol',
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2)),
                floatingLabelStyle: TextStyle(color: AppColors.primary),
              ),
              value: _steps[index]['roleId'],
              items: _availableRoles.map((role) {
                return DropdownMenuItem<int>(
                  value: role['id'],
                  child: Text(role['name'] ?? role['roleName'] ?? 'Bilinmiyor'),
                );
              }).toList(),
              onChanged: (val) =>
                  setState(() => _steps[index]['roleId'] = val!),
            ),
          ],
        ),
      ),
    );
  }
}
