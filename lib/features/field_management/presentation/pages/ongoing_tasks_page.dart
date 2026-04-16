import 'package:flutter/material.dart';

import 'field_task_status_page.dart';

class OngoingTasksPage extends StatelessWidget {
  const OngoingTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'InProgress',
      emptyIcon: Icons.autorenew,
      emptyMessage: 'Devam eden görev bulunamadı',
    );
  }
}
