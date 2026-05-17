import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/search_input_widget.dart';
import '../../../../core/widgets/custom_action_menu_widget.dart';
import '../../../../core/widgets/custom_list_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart' as common;
import '../../../../core/widgets/delete_confirmation_dialog.dart';
import '../../../../config/routes/app_router.dart';
import '../bloc/task_type/task_type_bloc.dart';
import '../bloc/task_type/task_type_event.dart';
import '../bloc/task_type/task_type_state.dart';
import '../../domain/entities/task_type_entity.dart';

class TaskTypeManagementPage extends StatefulWidget {
  const TaskTypeManagementPage({super.key});

  @override
  State<TaskTypeManagementPage> createState() => _TaskTypeManagementPageState();
}

class _TaskTypeManagementPageState extends State<TaskTypeManagementPage> {
  @override
  void initState() {
    super.initState();
    _loadTaskTypes();
  }

  void _loadTaskTypes() {
    context.read<TaskTypeBloc>().add(GetAllTaskTypes());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskTypeBloc, TaskTypeState>(
      listener: (context, state) {
        if (state is TaskTypeActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          _loadTaskTypes();
        } else if (state is TaskTypeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Müşteri UI uyumu
        appBar: AppBar(
          title: const Text(
            'Görev Tipi Yönetimi',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFF57C00),
              height: 2.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tanımlı Görev Tipleri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  CustomActionMenuWidget(
                    items: [
                      CustomActionMenuItem(
                        title: 'Yeni Tip Ekle',
                        icon: Icons.add_circle_outline,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                              context, AppRouter.taskTypeAdd);
                          if (result == true && context.mounted)
                            _loadTaskTypes();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<TaskTypeBloc, TaskTypeState>(
                  builder: (context, state) {
                    if (state is TaskTypeLoading)
                      return const LoadingIndicator();
                    if (state is TaskTypesLoaded) {
                      if (state.taskTypes.isEmpty) return _buildEmptyState();
                      return _buildList(state.taskTypes);
                    }
                    if (state is TaskTypeError) {
                      return common.CustomErrorWidget(
                        message: state.message,
                        onRetry: _loadTaskTypes,
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

  Widget _buildList(List<TaskTypeEntity> items) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, i) => const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final item = items[index];
          return CustomListCard(
            title: item.name,
            subtitle: item.description ?? 'Açıklama yok',
            leading: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF57C00),
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
                IconButton(
                  icon: Icon(
                    item.isActive ? Icons.visibility : Icons.visibility_off,
                    color:
                        item.isActive ? const Color(0xFFF57C00) : Colors.grey,
                  ),
                  onPressed: () {
                    context.read<TaskTypeBloc>().add(
                        UpdateTaskType(item.id!, {'isActive': !item.isActive}));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black87),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRouter.taskTypeAdd,
                      arguments: item,
                    );
                    if (result == true && context.mounted) _loadTaskTypes();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirm(item),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 64, color: Color(0xFFF57C00)),
            const SizedBox(height: 16),
            const Text(
              'Görev tipi bulunamadı',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(TaskTypeEntity item) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Görev Tipi Sil',
      itemName: item.name,
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskTypeBloc>().add(DeleteTaskType(item.id!));
    }
  }
}
