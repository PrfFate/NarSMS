import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../field_management/presentation/pages/field_task_status_page.dart';

class MyAssignedTasksPage extends StatelessWidget {
  const MyAssignedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Pending',
      emptyIcon: Icons.assignment_outlined,
      emptyMessage: 'Atanan görev bulunamadı',
      endpoint: ApiConstants.fieldTasksMyTasks,
      enableAcceptActionInDetail: true,
    );
  }
}
