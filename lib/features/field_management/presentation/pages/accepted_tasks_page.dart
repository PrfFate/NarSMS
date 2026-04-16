import 'package:flutter/material.dart';

import 'field_task_status_page.dart';

class AcceptedTasksPage extends StatelessWidget {
  const AcceptedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FieldTaskStatusPage(
      status: 'Accepted',
      emptyIcon: Icons.task_alt,
      emptyMessage: 'Kabul edilen görev bulunamadı',
    );
  }
}
