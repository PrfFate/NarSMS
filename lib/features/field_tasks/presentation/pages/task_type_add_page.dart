import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_form_scaffold.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/task_type/task_type_bloc.dart';
import '../bloc/task_type/task_type_event.dart';
import '../bloc/task_type/task_type_state.dart';
import '../../domain/entities/task_type_entity.dart';

class TaskTypeAddPage extends StatefulWidget {
  final TaskTypeEntity? taskType;
  const TaskTypeAddPage({super.key, this.taskType});

  @override
  State<TaskTypeAddPage> createState() => _TaskTypeAddPageState();
}

class _TaskTypeAddPageState extends State<TaskTypeAddPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _displayOrderController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.taskType?.name);
    _descriptionController =
        TextEditingController(text: widget.taskType?.description);
    _displayOrderController = TextEditingController(
        text: widget.taskType?.displayOrder.toString() ?? '0');
    _isActive = widget.taskType?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (widget.taskType == null) {
        final taskType = TaskTypeEntity(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
          isActive: _isActive,
        );
        context.read<TaskTypeBloc>().add(CreateTaskType(taskType));
      } else {
        context.read<TaskTypeBloc>().add(UpdateTaskType(widget.taskType!.id!, {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'displayOrder': int.tryParse(_displayOrderController.text) ?? 0,
          'isActive': _isActive,
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskTypeBloc, TaskTypeState>(
      listener: (context, state) {
        if (state is TaskTypeActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is TaskTypeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return CustomFormScaffold(
          title: widget.taskType == null
              ? 'Yeni Görev Tipi Ekle'
              : 'Görevi Tipi Düzenle',
          bottomButtonText: widget.taskType == null ? 'Ekle' : 'Güncelle',
          onBottomButtonPressed: _onSave,
          isLoading: state is TaskTypeLoading,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Görev Tipi Adı',
                    hint: 'örn: Yerinde Eğitim',
                    controller: _nameController,
                    isRequired: true,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Lütfen ad giriniz' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Açıklama',
                    hint: 'Görev tipi hakkında kısa açıklama',
                    controller: _descriptionController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _isActive,
                          activeColor: const Color(0xFFF57C00),
                          onChanged: (val) =>
                              setState(() => _isActive = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Aktif',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
