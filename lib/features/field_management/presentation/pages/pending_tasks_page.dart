import 'package:flutter/material.dart';

import 'field_task_status_page.dart';

class PendingTasksPage extends StatelessWidget {
  const PendingTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Pending',
      emptyIcon: Icons.pending_actions,
      emptyMessage: 'Bekleyen görev bulunamadı',
      showPendingActions: true,
    );
  }
}
