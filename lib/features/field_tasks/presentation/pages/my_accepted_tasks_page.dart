import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../field_management/presentation/pages/field_task_status_page.dart';

class MyAcceptedTasksPage extends StatelessWidget {
  const MyAcceptedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Accepted',
      emptyIcon: Icons.thumb_up_outlined,
      emptyMessage: 'Kabul edilen görev bulunamadı',
      endpoint: ApiConstants.fieldTasksMyTasks,
    );
  }
}
