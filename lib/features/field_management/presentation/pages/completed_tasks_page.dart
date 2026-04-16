import 'package:flutter/material.dart';

import 'field_task_status_page.dart';

class CompletedTasksPage extends StatelessWidget {
  const CompletedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Completed',
      emptyIcon: Icons.check_circle,
      emptyMessage: 'Tamamlanan görev bulunamadı',
    );
  }
}
