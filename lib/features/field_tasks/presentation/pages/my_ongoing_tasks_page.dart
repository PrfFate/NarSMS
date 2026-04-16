import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../field_management/presentation/pages/field_task_status_page.dart';

class MyOngoingTasksPage extends StatelessWidget {
  const MyOngoingTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'InProgress',
      emptyIcon: Icons.autorenew,
      emptyMessage: 'Devam eden görev bulunamadı',
      endpoint: ApiConstants.fieldTasksMyTasks,
    );
  }
}
