import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../field_management/presentation/pages/field_task_status_page.dart';

class MyCompletedTasksPage extends StatelessWidget {
  const MyCompletedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Completed',
      emptyIcon: Icons.done_all_outlined,
      emptyMessage: 'Tamamlanan görev bulunamadı',
      endpoint: ApiConstants.fieldTasksMyTasks,
    );
  }
}
